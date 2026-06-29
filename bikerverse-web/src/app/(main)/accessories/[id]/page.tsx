import type { Metadata } from 'next';
import { AccessoryDetailContent } from './AccessoryDetailContent';

export const metadata: Metadata = { title: 'Accessory Details — Bikerverse' };

export default function AccessoryDetailPage() {
  return <AccessoryDetailContent />;
}
