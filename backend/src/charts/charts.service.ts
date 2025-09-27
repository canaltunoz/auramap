import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChartsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(
    userId: string,
    data: { name: string; birthDatetime: string; timezone?: string | null },
  ) {
    const birth = new Date(data.birthDatetime);
    return this.prisma.chart.create({
      data: {
        userId,
        name: data.name,
        birthDatetime: birth,
        timezone: data.timezone ?? null,
      },
    });
  }

  async listMine(userId: string) {
    return this.prisma.chart.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listAll() {
    return this.prisma.chart.findMany({ orderBy: { createdAt: 'desc' } });
  }
}
