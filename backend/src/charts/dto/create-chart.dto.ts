import {
  IsISO8601,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  IsDateString,
  IsNumber,
  Min,
  Max,
} from 'class-validator';

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

export class CreateChartFlowDto {
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  name!: string;

  @IsDateString()
  birthDate!: string; // YYYY-MM-DD format

  @IsNumber()
  @Min(0)
  @Max(23)
  birthHour!: number;

  @IsNumber()
  @Min(0)
  @Max(59)
  birthMinute!: number;

  @IsString()
  @MinLength(1)
  @MaxLength(200)
  birthLocation!: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsOptional()
  @IsString()
  timezone?: string;
}
