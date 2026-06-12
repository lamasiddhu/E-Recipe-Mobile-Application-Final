import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors({ origin: config.get('CORS_ORIGIN'), credentials: true });

  await app.listen(config.get('PORT', 3000), '0.0.0.0');
  console.log(` ERecipe Backend running on http://localhost:${config.get('PORT')}/api/v1`);
}
bootstrap();