import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { Role } from '@prisma/client';

interface JwtPayload {
  sub: string;
  email: string;
  role: Role;
}

function parseDurationMs(input: string): number {
  const match = /^([0-9]+)([smhd])$/.exec(input);
  if (!match) return 0;
  const value = parseInt(match[1], 10);
  const unit = match[2];
  const mult: Record<string, number> = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
  return value * mult[unit];
}

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(email: string, password: string) {
    const existing = await this.users.findByEmail(email);
    if (existing) throw new UnauthorizedException('Email already in use');
    return this.users.createUser({ email, password });
  }

  async validateUser(email: string, password: string) {
    const user = await this.users.findByEmail(email);
    if (!user) throw new UnauthorizedException('Invalid credentials');
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    return user;
  }

  private async signTokens(userId: string, email: string, role: Role) {
    const accessTtl = this.config.get<string>('JWT_ACCESS_TOKEN_TTL', '900s');
    const refreshTtl = this.config.get<string>('JWT_REFRESH_TOKEN_TTL', '30d');
    const accessSecret = this.config.get<string>('JWT_SECRET', 'dev-secret');
    const refreshSecret = this.config.get<string>('JWT_REFRESH_SECRET', 'dev-refresh');

    const payload: JwtPayload = { sub: userId, email, role };

    const accessToken = await this.jwt.signAsync(payload, {
      secret: accessSecret,
      expiresIn: accessTtl,
    });
    const refreshToken = await this.jwt.signAsync(payload, {
      secret: refreshSecret,
      expiresIn: refreshTtl,
    });

    // store hashed refresh token with expiry
    const expiresAt = new Date(Date.now() + parseDurationMs(refreshTtl));
    const hashed = await bcrypt.hash(refreshToken, 10);
    await this.prisma.refreshToken.create({
      data: { userId: userId, hashedToken: hashed, expiresAt },
    });

    return { accessToken, refreshToken };
  }

  async login(email: string, password: string) {
    const user = await this.validateUser(email, password);
    const tokens = await this.signTokens(user.id, user.email, user.role);
    return { user: { id: user.id, email: user.email, role: user.role }, ...tokens };
  }

  async refresh(refreshToken: string) {
    const refreshSecret = this.config.get<string>('JWT_REFRESH_SECRET', 'dev-refresh');
    let payload: JwtPayload;
    try {
      payload = await this.jwt.verifyAsync<JwtPayload>(refreshToken, { secret: refreshSecret });
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

    // rotate: clear old tokens for user (simple strategy)
    await this.prisma.refreshToken.deleteMany({ where: { userId: payload.sub } });

    return this.signTokens(payload.sub, payload.email, payload.role);
  }

  async logout(userId: string) {
    await this.prisma.refreshToken.deleteMany({ where: { userId } });
    return { ok: true };
  }
}

