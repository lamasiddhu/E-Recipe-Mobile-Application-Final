import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';

export type UserDocument = User & Document & {
  getSignedJwtToken(): string;
  matchPassword(enteredPassword: string): Promise<boolean>;
};

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true }) firstName!: string;
  @Prop({ required: true, trim: true }) lastName!: string;
  @Prop({ required: true, unique: true, lowercase: true, trim: true }) email!: string;
  @Prop({ required: true, trim: true }) phone!: string;
  @Prop({ required: true, minlength: 6, select: false }) password!: string;
  @Prop({ default: 'default-profile.png' }) profilePicture!: string;
  @Prop({ default: 'user' }) role!: string;
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

UserSchema.methods.getSignedJwtToken = function (): string {
  return jwt.sign({ id: this._id }, process.env.JWT_SECRET!, {
    expiresIn: process.env.JWT_EXPIRE,
  } as any);
};

UserSchema.methods.matchPassword = async function (entered: string): Promise<boolean> {
  return bcrypt.compare(entered, this.password);
};