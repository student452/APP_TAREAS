import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,            // Elimina automáticamente propiedades no definidas en los DTOs
      forbidNonWhitelisted: true, // Lanza error si se envían campos no permitidos
    }),
  );

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
