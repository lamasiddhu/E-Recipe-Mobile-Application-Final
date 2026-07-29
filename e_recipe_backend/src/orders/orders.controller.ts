import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get('my')
  async findMine(@CurrentUser() user: any) {
    return {
      success: true,
      data: await this.ordersService.findMine(user._id.toString()),
    };
  }

  @Post()
  async purchase(@CurrentUser() user: any, @Body() dto: CreateOrderDto) {
    return {
      success: true,
      data: await this.ordersService.purchase(user._id.toString(), dto),
    };
  }
}
