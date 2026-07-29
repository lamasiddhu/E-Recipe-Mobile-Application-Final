import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type MealDocument = Meal & Document;

@Schema({ timestamps: true })
export class Meal {
  @Prop({ required: true }) mealName!: string;
  @Prop({ required: true }) calories!: number;
  @Prop({ required: true }) protein!: number;
  @Prop({ required: true }) carbs!: number;
  @Prop({ required: true }) fats!: number;
  @Prop({ type: Types.ObjectId, ref: 'User', required: true }) userId!: Types.ObjectId;
  @Prop({ type: Date, default: Date.now }) eatenAt!: Date;
}

export const MealSchema = SchemaFactory.createForClass(Meal);