import type { Metadata } from 'next';
import { WizardShell } from '@/components/forms/WizardShell';
import { SellAccessoryWizard } from '@/components/forms/SellAccessoryWizard';

export const metadata: Metadata = {
  title: 'Sell Gear & Accessories — Bikerverse',
  description: 'List your riding gear, helmets, jackets and accessories on Bikerverse.',
};

export default function SellAccessoryPage() {
  return (
    <WizardShell
      title="SELL YOUR GEAR"
      subtitle="List helmets, jackets, boots and accessories in minutes."
    >
      <SellAccessoryWizard />
    </WizardShell>
  );
}
