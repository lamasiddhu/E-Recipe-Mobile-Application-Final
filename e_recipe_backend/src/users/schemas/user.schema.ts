import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';

export type UserDocument = User &
  Document & {
    getSignedJwtToken(): string;
    matchPassword(enteredPassword: string): Promise<boolean>;
  };

@Schema({ timestamps: true, strict: false })
export class User {
  @Prop({ trim: true }) firstName?: string;
  @Prop({ trim: true }) lastName?: string;
  @Prop({ trim: true }) fullName?: string;
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email!: string;
  @Prop({ required: true, trim: true }) phone!: string;
  @Prop({ required: true, minlength: 6, select: false }) password!: string;
  @Prop({ sparse: true, unique: true }) googleId?: string;
  @Prop({ default: 'password' }) authProvider!: string;
  @Prop({ default: 'default-profile.png' }) profilePicture!: string;
  @Prop() avatarUrl?: string;
  @Prop({ default: '', maxlength: 240 }) bio!: string;
  @Prop({ default: 'user' }) role!: string;
  @Prop({ default: false }) isPro!: boolean;
  @Prop({ default: true }) recipeUpdatesEnabled!: boolean;
  @Prop({ default: true }) proOffersEnabled!: boolean;
  @Prop() recipeUpdatesEnabledAt?: Date;
  @Prop() proOffersEnabledAt?: Date;
  @Prop({ type: [Types.ObjectId], ref: 'Recipe', default: [] })
  purchasedRecipeIds!: Types.ObjectId[];
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

UserSchema.methods.matchPassword = async function (
  entered: string,
): Promise<boolean> {
  return bcrypt.compare(entered, this.password);
};
