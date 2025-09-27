import { IsISO8601, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateChartDto {
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  name!: string;

  @IsISO8601()
  birthDatetime!: string;

  @IsOptional()
  @IsString()
  timezone?: string;
}

