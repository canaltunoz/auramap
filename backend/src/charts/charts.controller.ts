import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ChartsService } from './charts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';

class CreateChartDto {
  name!: string;
  birthDatetime!: string;
  timezone?: string;
}

@UseGuards(JwtAuthGuard)
@Controller('charts')
export class ChartsController {
  constructor(private readonly charts: ChartsService) {}

  @Get()
  async list(@GetUser() user: any) {
    return this.charts.listMine(user.sub);
  }

  @Post()
  async create(@GetUser() user: any, @Body() dto: CreateChartDto) {
    return this.charts.create(user.sub, dto);
  }
}
