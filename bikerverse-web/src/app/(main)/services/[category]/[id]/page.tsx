import type { Metadata } from 'next';
import { ServiceDetailContent } from './ServiceDetailContent';

export const metadata: Metadata = { title: 'Service Details — Bikerverse' };

export default function ServiceDetailPage() {
  return <ServiceDetailContent />;
}
