import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PasswordResetDocument = PasswordReset & Document;

@Schema({ timestamps: true })
export class PasswordReset {
  @Prop({ required: true, lowercase: true, index: true, unique: true })
  email!: string;

  @Prop({ required: true, select: false })
  otpHash!: string;

  @Prop({ required: true, index: { expires: 0 } })
  expiresAt!: Date;

  @Prop({ default: 0 })
  attempts!: number;

  @Prop()
  lastSentAt!: Date;

  @Prop({ select: false })
  resetTokenHash?: string;

  @Prop()
  verifiedAt?: Date;
}

export const PasswordResetSchema =
  SchemaFactory.createForClass(PasswordReset);
