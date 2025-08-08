import { IsNotEmpty, IsEnum, IsOptional, IsString } from 'class-validator';
import { TaskStatus } from '@prisma/client';

export class CreateTaskDto {
  @IsNotEmpty()
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsEnum(TaskStatus, { message: 'Status must be PENDING, COMPLETED or IN_PROCESS' })
  status: TaskStatus;
}
