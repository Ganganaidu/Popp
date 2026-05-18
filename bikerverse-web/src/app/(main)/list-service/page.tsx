import type { Metadata } from 'next';
import { WizardShell } from '@/components/forms/WizardShell';
import { ListServiceWizard } from '@/components/forms/ListServiceWizard';

export const metadata: Metadata = {
  title: 'List Your Service — Bikerverse',
  description: 'List your workshop, tyre shop or accessory store on Bikerverse and reach local riders.',
};

export default function ListServicePage() {
  return (
    <WizardShell
      title="LIST YOUR SERVICE"
      subtitle="Put your workshop, tyre shop or accessory store in front of local riders."
    >
      <ListServiceWizard />
    </WizardShell>
  );
}
