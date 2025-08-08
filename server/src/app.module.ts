import { Module, MiddlewareConsumer, RequestMethod } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { TaskModule } from './task/task.module';
import { JwtAuthMiddleware } from './auth/jwt-auth.middleware';

@Module({
  imports: [AuthModule, PrismaModule, TaskModule],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(JwtAuthMiddleware)
      .forRoutes({ path: 'task', method: RequestMethod.ALL }); // protege todas las rutas de /task
  }
}
//Permite que las rutas del módulo Task estén protegidas por JWT
//El middleware JwtAuthMiddleware se aplica a todas las rutas del controlador TaskController