import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GoogleLoginDto {
  @ApiProperty({
    description: 'Google server auth code from Google Sign-In v7',
    example: '4/0AX4XfWjYZ1234567890abcdef...',
  })
  @IsString()
  @IsNotEmpty()
  serverAuthCode: string;
}
