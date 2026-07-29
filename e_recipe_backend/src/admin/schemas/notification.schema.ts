import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type NotificationDocument = Notification & Document;

@Schema({ timestamps: true, strict: false })
export class Notification {
  createdAt!: Date;
  updatedAt!: Date;

  @Prop({ type: Types.ObjectId, ref: 'User', index: true })
  userId?: Types.ObjectId;

  @Prop({ default: false })
  broadcast!: boolean;

  @Prop({ required: true, trim: true })
  message!: string;

  @Prop({ default: 'info' })
  type!: string;

  @Prop()
  action?: string;

  @Prop()
  resetToken?: string;

  @Prop({ type: Types.ObjectId, ref: 'Recipe' })
  recipeId?: Types.ObjectId;

  @Prop({ default: false })
  read!: boolean;

  @Prop({ type: [Types.ObjectId], ref: 'User', default: [] })
  readBy!: Types.ObjectId[];

  @Prop({ type: [Types.ObjectId], ref: 'User', default: [] })
  dismissedBy!: Types.ObjectId[];
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
