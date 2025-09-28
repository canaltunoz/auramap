import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { Role, Prisma } from '@prisma/client';

// Define the exact return type for user queries
type UserSelectResult = {
  id: string;
  email: string;
  passwordHash: string | null;
  name: string | null;
  picture: string | null;
  googleId: string | null;
  role: Role;
  createdAt: Date;
  updatedAt: Date;
};

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email: string): Promise<UserSelectResult | null> {
    return this.prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        email: true,
        passwordHash: true,
        name: true,
        picture: true,
        googleId: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async findById(id: string): Promise<UserSelectResult | null> {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        passwordHash: true,
        name: true,
        picture: true,
        googleId: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async createUser(params: {
    email: string;
    password: string;
    role?: Role;
  }): Promise<{
    id: string;
    email: string;
    role: Role;
    createdAt: Date;
  }> {
    const passwordHash = await bcrypt.hash(params.password, 10);
    return this.prisma.user.create({
      data: {
        email: params.email,
        passwordHash,
        role: params.role ?? 'USER',
      },
      select: { id: true, email: true, role: true, createdAt: true },
    });
  }

  async createGoogleUser(params: {
    email: string;
    name: string;
    picture?: string;
    googleId?: string;
  }): Promise<UserSelectResult> {
    return this.prisma.user.create({
      data: {
        email: params.email,
        name: params.name,
        picture: params.picture,
        googleId: params.googleId,
        role: 'USER',
        // No password hash for OAuth users
      },
      select: {
        id: true,
        email: true,
        passwordHash: true,
        name: true,
        picture: true,
        googleId: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    }) as Promise<UserSelectResult>;
  }
}
