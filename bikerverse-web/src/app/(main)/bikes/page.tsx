import type { Metadata } from 'next';
import { BikesContent } from './BikesContent';

export const metadata: Metadata = {
  title: 'Premium Bikes — Bikerverse',
  description: 'Browse pre-owned premium motorcycles across India. Filter by brand, budget, KM driven and more.',
};

export default function BikesPage() {
  return <BikesContent />;
}
