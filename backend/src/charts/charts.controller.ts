import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ChartsService } from './charts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { CreateChartDto } from './dto/create-chart.dto';
import { Roles } from '../common/decorators/roles.decorator';
import { RolesGuard } from '../common/guards/roles.guard';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

@ApiTags('charts')
@ApiBearerAuth()
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

  @Get('admin/all')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  async listAll() {
    return this.charts.listAll();
  }
}
