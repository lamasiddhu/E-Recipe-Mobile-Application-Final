import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type WorkoutDocument = Workout & Document;

@Schema({ timestamps: true })
export class Workout {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId!: Types.ObjectId;

  @Prop({ required: true })
  exerciseName!: string;

  @Prop({ required: true })
  sets!: number;

  @Prop({ required: true })
  reps!: number;

  @Prop()
  weight?: number;

  @Prop({ type: Date, default: Date.now })
  date!: Date;
}

export const WorkoutSchema = SchemaFactory.createForClass(Workout);