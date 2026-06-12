import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal Server Error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const resData = exception.getResponse();
      message = typeof resData === 'string' ? resData : (resData as any).message || exception.message;
    } else if (exception instanceof Error) {
      const e = exception as any;
      if (e.code === 11000) {
        status = HttpStatus.BAD_REQUEST;
        message = `${Object.keys(e.keyValue || {})[0]} already exists`;
      } else if (e.name === 'ValidationError') {
        status = HttpStatus.BAD_REQUEST;
        message = Object.values(e.errors).map((v: any) => v.message).join(', ');
      } else if (e.name === 'JsonWebTokenError') {
        status = HttpStatus.UNAUTHORIZED; message = 'Invalid token';
      } else if (e.name === 'TokenExpiredError') {
        status = HttpStatus.UNAUTHORIZED; message = 'Token expired';
      } else { message = e.message; }
    }

    res.status(status).json({ success: false, message: Array.isArray(message) ? message.join(', ') : message });
  }
}