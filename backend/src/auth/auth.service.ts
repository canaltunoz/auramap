// auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { Role } from '@prisma/client';

interface JwtPayload {
  sub: string;
  email: string;
  role: Role;
}

function parseDurationMs(input: string): number {
  const m = /^(\d+)([smhd])$/.exec(input);
  if (!m) return 0;
  const v = parseInt(m[1], 10);
  const mult = { s: 1_000, m: 60_000, h: 3_600_000, d: 86_400_000 } as const;
  return v * mult[m[2] as keyof typeof mult];
}

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;

  constructor(
    private readonly users: UsersService,
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {
    // v7 icin: WEB CLIENT kimlikleri + redirectUri='postmessage'
    const clientId = this.config.get<string>('GOOGLE_WEB_CLIENT_ID', '');
    const clientSecret = this.config.get<string>(
      'GOOGLE_WEB_CLIENT_SECRET',
      '',
    );
    if (!clientId || !clientSecret) {
      // env eksikse erken hata ver
      throw new Error(
        'GOOGLE_WEB_CLIENT_ID / GOOGLE_WEB_CLIENT_SECRET missing',
      );
    }
    this.googleClient = new OAuth2Client(
      clientId,
      clientSecret,
      // No redirect URI - let Google handle it automatically
    );
  }

  async register(email: string, password: string) {
    const existing = await this.users.findByEmail(email);
    if (existing) throw new UnauthorizedException('Email already in use');
    return this.users.createUser({ email, password });
  }

  async validateUser(email: string, password: string) {
    const user = await this.users.findByEmail(email);
    if (!user || !user.passwordHash)
      throw new UnauthorizedException('Invalid credentials');
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    return user;
  }

  private async signTokens(userId: string, email: string, role: Role) {
    const accessTtl = this.config.get<string>('JWT_ACCESS_TOKEN_TTL', '900s');
    const refreshTtl = this.config.get<string>('JWT_REFRESH_TOKEN_TTL', '30d');
    const accessSecret = this.config.get<string>('JWT_SECRET', 'dev-secret');
    const refreshSecret = this.config.get<string>(
      'JWT_REFRESH_SECRET',
      'dev-refresh',
    );

    const payload: JwtPayload = { sub: userId, email, role };

    const accessToken = await this.jwt.signAsync(payload, {
      secret: accessSecret,
      expiresIn: accessTtl,
    });
    const refreshToken = await this.jwt.signAsync(payload, {
      secret: refreshSecret,
      expiresIn: refreshTtl,
    });

    const expiresAt = new Date(Date.now() + parseDurationMs(refreshTtl));
    const hashed = await bcrypt.hash(refreshToken, 10);
    await this.prisma.refreshToken.create({
      data: { userId, hashedToken: hashed, expiresAt },
    });

    return { accessToken, refreshToken };
  }

  async login(email: string, password: string) {
    const user = await this.validateUser(email, password);
    const tokens = await this.signTokens(user.id, user.email, user.role);
    return {
      user: { id: user.id, email: user.email, role: user.role },
      ...tokens,
    };
  }

  /**
   * v7 mobilden gelen serverAuthCode'u takas eder:
   * - redirect_uri: 'postmessage'
   * - Web client (ID+SECRET) kullanir
   */
  async googleLogin(serverAuthCode: string) {
    try {
      if (!serverAuthCode) {
        throw new UnauthorizedException('Missing serverAuthCode');
      }

      // 1) Auth code -> Token takasi
      const { tokens } = await this.googleClient.getToken(serverAuthCode);

      const idToken = tokens.id_token;
      if (!idToken) {
        // Ilk giriste refresh_token olmayabilir; sorun degil. Ama id_token mutlaka olmali.
        throw new UnauthorizedException('No ID token received from Google');
      }

      // 2) ID token dogrula
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: this.config.get<string>('GOOGLE_WEB_CLIENT_ID'),
      });
      const payload = ticket.getPayload();
      if (!payload?.email) {
        throw new UnauthorizedException('Invalid Google token');
      }
      if (payload.email_verified === false) {
        throw new UnauthorizedException('Email is not verified');
      }

      const email = payload.email;
      const name = payload.name ?? email.split('@')[0];
      const picture = payload.picture;
      const googleId = payload.sub; // Google user ID

      // 3) Kullanici upsert
      let user = await this.users.findByEmail(email);
      if (!user) {
        user = await this.users.createGoogleUser({
          email,
          name,
          picture,
          googleId,
        });
      }

      // Ensure user is not null (should never happen after createGoogleUser)
      if (!user) {
        throw new UnauthorizedException('Failed to create or find user');
      }

      // 4) Uygulama JWT'leri
      const tokensOut = await this.signTokens(user.id, user.email, user.role);

      return {
        user: { id: user.id, email: user.email, role: user.role },
        ...tokensOut,
      };
    } catch (err) {
      // token/code loglama YAPMA
      const msg =
        err instanceof UnauthorizedException
          ? err.message
          : ((err as Error)?.message ?? 'Google authentication failed');

      console.error('Google login failed:', msg);
      throw new UnauthorizedException('Google authentication failed');
    }
  }

  async refresh(refreshToken: string) {
    const refreshSecret = this.config.get<string>(
      'JWT_REFRESH_SECRET',
      'dev-refresh',
    );
    let payload: JwtPayload;
    try {
      payload = await this.jwt.verifyAsync<JwtPayload>(refreshToken, {
        secret: refreshSecret,
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokens = await this.prisma.refreshToken.findMany({
      where: { userId: payload.sub },
      orderBy: { createdAt: 'desc' },
      take: 5,
    });

    const valid = await Promise.any(
      tokens.map(async (t) => {
        if (t.expiresAt < new Date()) return false;
        return bcrypt.compare(refreshToken, t.hashedToken);
      }),
    ).catch(() => false);

    if (!valid) throw new UnauthorizedException('Refresh token not recognized');

    // Basit rotation: eski refreshleri temizle
    await this.prisma.refreshToken.deleteMany({
      where: { userId: payload.sub },
    });

    return this.signTokens(payload.sub, payload.email, payload.role);
  }

  async logout(userId: string) {
    await this.prisma.refreshToken.deleteMany({ where: { userId } });
    return { ok: true };
  }
}
