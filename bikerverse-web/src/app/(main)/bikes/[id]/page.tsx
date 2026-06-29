import type { Metadata } from 'next';
import { BikeDetailContent } from './BikeDetailContent';

export const metadata: Metadata = { title: 'Bike Details — Bikerverse' };

export default function BikeDetailPage() {
  return <BikeDetailContent />;
}
