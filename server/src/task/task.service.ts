import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

@Injectable()
export class TaskService {
  constructor(private prisma: PrismaService) {}

  async create(createTaskDto: CreateTaskDto, userId: string) {
    return this.prisma.task.create({
      data: {
        title: createTaskDto.title,
        description: createTaskDto.description ?? null, // evitar undefined
        status: createTaskDto.status,
        userid: userId,
      },
    });
  }

  async findAll(userId: string) {
    return this.prisma.task.findMany({
      where: { userid: userId },
      orderBy: { createdat: 'desc' },
    });
  }

  async findOne(id: string, userId: string) {
    const task = await this.prisma.task.findFirst({
      where: { id, userid: userId },
    });

    if (!task) throw new NotFoundException('Task not found');
    return task;
  }

  async update(id: string, updateTaskDto: UpdateTaskDto, userId: string) {
    await this.findOne(id, userId); // valida existencia y propiedad

    return this.prisma.task.update({
      where: { id },
      data: {
        title: updateTaskDto.title ?? undefined,
        description: updateTaskDto.description ?? undefined,
        status: updateTaskDto.status ?? undefined,
      },
    });
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);

    return this.prisma.task.delete({
      where: { id },
    });
  }
}
