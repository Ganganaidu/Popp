import type { Metadata } from 'next';
import { WizardShell } from '@/components/forms/WizardShell';
import { SellBikeWizard } from '@/components/forms/SellBikeWizard';

export const metadata: Metadata = {
  title: 'Sell Your Bike — Bikerverse',
  description: 'List your pre-owned motorcycle on Bikerverse. Reach thousands of verified buyers.',
};

export default function SellBikePage() {
  return (
    <WizardShell
      title="SELL YOUR BIKE"
      subtitle="List your motorcycle in under 5 minutes. Reach thousands of verified buyers across India."
    >
      <SellBikeWizard />
    </WizardShell>
  );
}
