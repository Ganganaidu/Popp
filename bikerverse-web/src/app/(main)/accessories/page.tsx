import type { Metadata } from 'next';
import { AccessoriesContent } from './AccessoriesContent';

export const metadata: Metadata = {
  title: 'Accessories & Gear — Bikerverse',
  description: 'Shop pre-owned riding gear, helmets, jackets and accessories from trusted sellers.',
};

export default function AccessoriesPage() {
  return <AccessoriesContent />;
}
