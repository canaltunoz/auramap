import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import type { CreateChartFlowDto } from './dto/create-chart.dto';

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

  async countUserCharts(userId: string) {
    return this.prisma.chart.count({
      where: { userId },
    });
  }

  async createFromFlow(userId: string, data: CreateChartFlowDto) {
    // Combine date and time into a single datetime
    const birthDatetime = new Date(
      `${data.birthDate}T${data.birthHour.toString().padStart(2, '0')}:${data.birthMinute.toString().padStart(2, '0')}:00`,
    );

    return this.prisma.chart.create({
      data: {
        userId,
        name: data.name,
        birthDatetime,
        timezone: data.timezone ?? null,
        // Note: We could extend the schema to store location, lat/lng separately if needed
      },
    });
  }

  async listAll() {
    return this.prisma.chart.findMany({ orderBy: { createdAt: 'desc' } });
  }
}
