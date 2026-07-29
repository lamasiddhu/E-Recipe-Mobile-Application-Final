import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type RecipeDocument = Recipe & Document;

@Schema({ timestamps: true, strict: false })
export class Recipe {
  @Prop({ required: true, trim: true })
  title!: string;

  @Prop({ required: true })
  description!: string;

  @Prop({ type: [String], default: [] })
  ingredients!: string[];

  @Prop({ type: [String], default: [] })
  instructions!: string[];

  @Prop({ type: [Object], default: [] })
  steps!: Array<{ title?: string; description?: string }>;

  @Prop({ required: true })
  category!: string;

  @Prop()
  prepTime?: number;

  @Prop()
  cookTime?: number;

  @Prop()
  totalTime?: number;

  @Prop()
  difficulty!: string;

  @Prop({ default: 'default-recipe.png' })
  image!: string;

  @Prop()
  imageUrl?: string;

  @Prop()
  videoUrl?: string;

  @Prop({ default: 'Free' })
  badge!: string;

  @Prop({ default: 0, min: 0 })
  price!: number;

  @Prop()
  duration?: string;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  createdBy!: Types.ObjectId;
}

export const RecipeSchema = SchemaFactory.createForClass(Recipe);
