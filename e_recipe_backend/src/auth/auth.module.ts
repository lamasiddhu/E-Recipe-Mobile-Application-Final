import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtStrategy } from './strategies/jwt.strategy';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({ secret: config.get('JWT_SECRET'), signOptions: { expiresIn: config.get('JWT_EXPIRE') } }),
      inject: [ConfigService],
    }),
    UsersModule,
  ],
  providers: [JwtStrategy],
  exports: [JwtStrategy],
})
export class AuthModule {}