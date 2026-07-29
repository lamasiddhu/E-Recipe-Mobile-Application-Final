import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ProgressDocument = Progress & Document;

@Schema({ timestamps: true })
export class Progress {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  weight!: number;

  @Prop()
  bodyFat?: number;

  @Prop()
  muscleMass?: number;

  @Prop({ type: Date, default: Date.now })
  date!: Date;
}

export const ProgressSchema = SchemaFactory.createForClass(Progress);