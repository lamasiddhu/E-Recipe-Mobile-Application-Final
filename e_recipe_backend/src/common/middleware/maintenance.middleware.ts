import { Injectable, NestMiddleware } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectConnection } from '@nestjs/mongoose';
import type { NextFunction, Request, Response } from 'express';
import * as jwt from 'jsonwebtoken';
import { Connection, Types } from 'mongoose';

@Injectable()
export class MaintenanceMiddleware implements NestMiddleware {
  constructor(
    @InjectConnection() private readonly connection: Connection,
    private readonly config: ConfigService,
  ) {}

  async use(request: Request, response: Response, next: NextFunction) {
    const settings = await this.connection
      .collection('appsettings')
      .findOne({ key: 'global' });
    if (!settings?.maintenanceMode) return next();

    const path = request.originalUrl;
    if (
      path.includes('/users/login') ||
      path.includes('/admin/')
    ) {
      return next();
    }

    const token = request.headers.authorization?.replace(/^Bearer\s+/i, '');
    if (token) {
      try {
        const payload = jwt.verify(
          token,
          this.config.get<string>('JWT_SECRET')!,
        ) as { id?: string };
        if (payload.id && Types.ObjectId.isValid(payload.id)) {
          const user = await this.connection
            .collection('users')
            .findOne({ _id: new Types.ObjectId(payload.id) });
          if (user?.role === 'admin') return next();
        }
      } catch {
        // Invalid authentication is handled by the normal JWT guard.
      }
    }

    return response.status(503).json({
      success: false,
      message: 'E-Recipe is temporarily under maintenance. Please try again later.',
    });
  }
}
