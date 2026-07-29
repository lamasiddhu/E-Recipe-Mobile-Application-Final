import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type AppSettingDocument = AppSetting & Document;

@Schema({ timestamps: true, collection: 'appsettings' })
export class AppSetting {
  @Prop({ default: 'global', unique: true })
  key!: string;

  @Prop({ default: false })
  maintenanceMode!: boolean;

  @Prop({ default: '' })
  announcement!: string;

  @Prop()
  cacheClearedAt?: Date;
}

export const AppSettingSchema = SchemaFactory.createForClass(AppSetting);
