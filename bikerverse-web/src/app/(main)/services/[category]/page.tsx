import type { Metadata } from 'next';
import { ServiceListContent } from './ServiceListContent';

export const metadata: Metadata = { title: 'Services — Bikerverse' };

export default function ServiceCategoryPage() {
  return <ServiceListContent />;
}
