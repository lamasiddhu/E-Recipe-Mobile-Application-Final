import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type OrderDocument = Order & Document;

@Schema({ _id: false })
export class OrderItem {
  @Prop({ type: Types.ObjectId, ref: 'Recipe', required: true })
  recipeId!: Types.ObjectId;

  @Prop({ required: true })
  title!: string;

  @Prop({ default: 1, min: 1 })
  quantity!: number;

  @Prop({ required: true, min: 0 })
  unitPrice!: number;
}

const OrderItemSchema = SchemaFactory.createForClass(OrderItem);

@Schema({ timestamps: true, strict: false })
export class Order {
  @Prop({ required: true, unique: true })
  orderNumber!: string;

  @Prop({ required: true })
  customer!: string;

  @Prop({ required: true })
  item!: string;

  @Prop({ type: [OrderItemSchema], default: [] })
  items!: OrderItem[];

  @Prop({ required: true, min: 0 })
  price!: number;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ default: 'digital' })
  format!: string;

  @Prop({ type: [Types.ObjectId], ref: 'Recipe', default: [] })
  recipeIds!: Types.ObjectId[];

  @Prop({ default: 'Completed' })
  status!: string;

  @Prop({ default: 'e-Sewa' })
  paymentMethod!: string;

  @Prop()
  paymentAccountMasked?: string;
}

export const OrderSchema = SchemaFactory.createForClass(Order);
OrderSchema.index({ userId: 1, recipeIds: 1 });
