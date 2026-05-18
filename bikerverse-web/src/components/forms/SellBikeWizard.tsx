'use client';

import { useState } from 'react';
import { StepBar } from './StepBar';
import { WizardFooter } from './WizardFooter';
import { FormField } from './FormField';
import { FormSelect } from './FormSelect';
import { PhotoUpload } from './PhotoUpload';
import { ListingPreview } from './ListingPreview';
import styles from './Wizard.module.css';

const STEPS = ['Basics', 'Details', 'Photos', 'Price & Preview'];

const BRANDS = [
  { value: 'royal-enfield', label: 'Royal Enfield' },
  { value: 'ktm', label: 'KTM' },
  { value: 'kawasaki', label: 'Kawasaki' },
  { value: 'honda', label: 'Honda' },
  { value: 'triumph', label: 'Triumph' },
  { value: 'ducati', label: 'Ducati' },
  { value: 'bajaj', label: 'Bajaj' },
  { value: 'harley', label: 'Harley-Davidson' },
  { value: 'bmw', label: 'BMW Motorrad' },
  { value: 'yamaha', label: 'Yamaha' },
  { value: 'suzuki', label: 'Suzuki' },
  { value: 'other', label: 'Other' },
] as const;

const YEARS = Array.from({ length: 15 }, (_, i) => {
  const y = 2025 - i;
  return { value: String(y), label: String(y) };
});

const OWNERS = [
  { value: '1', label: '1st owner' },
  { value: '2', label: '2nd owner' },
  { value: '3', label: '3rd owner' },
  { value: '4+', label: '4+ owners' },
];

const STATES = [
  'Andhra Pradesh','Delhi','Gujarat','Karnataka','Kerala',
  'Maharashtra','Rajasthan','Tamil Nadu','Telangana','West Bengal','Other',
].map((s) => ({ value: s.toLowerCase().replace(/\s/g, '-'), label: s }));

const INSURANCE = [
  { value: 'valid', label: 'Valid'       },
  { value: 'expired', label: 'Expired'   },
  { value: 'none', label: 'None'          },
];

/* ─────────────────────────────────────── */

interface FormData {
  brand: string; model: string; year: string; city: string; state: string;
  kmDriven: string; owners: string; insurance: string; engineCC: string;
  color: string; rto: string; modifications: string;
  askingPrice: string; negotiable: boolean; description: string;
}

const INIT: FormData = {
  brand: '', model: '', year: '', city: '', state: '',
  kmDriven: '', owners: '', insurance: '', engineCC: '',
  color: '', rto: '', modifications: '',
  askingPrice: '', negotiable: true, description: '',
};

/**
 * SellBikeWizard — 4-step client wizard.
 * Step 0: Basics  (brand, model, year, city, state)
 * Step 1: Details (km, owners, insurance, engine, RTO, colour, mods)
 * Step 2: Photos  (8-slot uploader)
 * Step 3: Price & Preview
 */
export function SellBikeWizard() {
  const [step, setStep]         = useState(0);
  const [data, setData]         = useState<FormData>(INIT);
  const [submitting, setSubmitting] = useState(false);

  function set(field: keyof FormData, value: string | boolean) {
    setData((prev) => ({ ...prev, [field]: value }));
  }

  function next() {
    if (step < STEPS.length - 1) setStep((s) => s + 1);
    else handleSubmit();
  }

  function back() { setStep((s) => Math.max(0, s - 1)); }

  async function handleSubmit() {
    setSubmitting(true);
    // Phase 7 — wire to Firestore
    await new Promise((r) => setTimeout(r, 1200));
    setSubmitting(false);
    alert('Listing published! (Demo — Firestore wired in Phase 7)');
  }

  const bikeName = [data.brand ? BRANDS.find((b) => b.value === data.brand)?.label : '', data.model].filter(Boolean).join(' ');

  return (
    <div>
      <StepBar steps={STEPS} current={step} />

      <div className={styles.panel}>

        {/* ── Step 0: Basics ── */}
        {step === 0 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Tell us about the bike</h2>
            <div className={styles.row2}>
              <FormSelect label="Brand" required options={BRANDS} placeholder="Select brand" value={data.brand} onChange={(e) => set('brand', e.target.value)} />
              <FormField  label="Model" required placeholder="e.g. Interceptor 650" value={data.model} onChange={(e) => set('model', e.target.value)} />
            </div>
            <div className={styles.row2}>
              <FormSelect label="Year" required options={YEARS} placeholder="Select year" value={data.year} onChange={(e) => set('year', e.target.value)} />
              <FormField  label="City" required placeholder="e.g. Hyderabad" value={data.city} onChange={(e) => set('city', e.target.value)} />
            </div>
            <FormSelect label="State" required options={STATES} placeholder="Select state" value={data.state} onChange={(e) => set('state', e.target.value)} />
          </div>
        )}

        {/* ── Step 1: Details ── */}
        {step === 1 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Bike details & condition</h2>
            <div className={styles.row2}>
              <FormField label="KM Driven" required type="number" placeholder="e.g. 12000" value={data.kmDriven} onChange={(e) => set('kmDriven', e.target.value)} hint="Total odometer reading in km" />
              <FormSelect label="No. of Owners" required options={OWNERS} placeholder="Select" value={data.owners} onChange={(e) => set('owners', e.target.value)} />
            </div>
            <div className={styles.row2}>
              <FormSelect label="Insurance" required options={INSURANCE} placeholder="Select" value={data.insurance} onChange={(e) => set('insurance', e.target.value)} />
              <FormField label="Engine (CC)" type="number" placeholder="e.g. 650" value={data.engineCC} onChange={(e) => set('engineCC', e.target.value)} />
            </div>
            <div className={styles.row2}>
              <FormField label="Colour" placeholder="e.g. Matte Black" value={data.color} onChange={(e) => set('color', e.target.value)} />
              <FormField label="RTO Registration" placeholder="e.g. TS-09 AB 1234" value={data.rto} onChange={(e) => set('rto', e.target.value)} />
            </div>
            <FormField as="textarea" rows={3} label="Modifications (optional)" placeholder="List any modifications, accessories fitted, recent service work…" value={data.modifications} onChange={(e) => set('modifications', e.target.value)} />
          </div>
        )}

        {/* ── Step 2: Photos ── */}
        {step === 2 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Add photos</h2>
            <PhotoUpload
              maxPhotos={8}
              hint="Upload up to 8 photos. The first photo becomes the cover. Clear, well-lit photos get 3× more enquiries."
            />
          </div>
        )}

        {/* ── Step 3: Price & Preview ── */}
        {step === 3 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Set your price</h2>
            <div className={styles.row2}>
              <FormField
                label="Asking Price (₹)" required type="number"
                placeholder="e.g. 250000"
                value={data.askingPrice}
                onChange={(e) => set('askingPrice', e.target.value)}
                hint="Enter the price in Indian Rupees"
              />
              <div className={styles.checkWrap}>
                <label className={styles.checkLabel}>
                  <input
                    type="checkbox"
                    className={styles.checkbox}
                    checked={data.negotiable}
                    onChange={(e) => set('negotiable', e.target.checked)}
                  />
                  <span className={styles.checkText}>Price is negotiable</span>
                </label>
              </div>
            </div>
            <FormField
              as="textarea" rows={4} label="Description" required
              placeholder="Describe the bike's condition, service history, reason for selling…"
              value={data.description}
              onChange={(e) => set('description', e.target.value)}
            />

            <div className={styles.divider} />

            <ListingPreview
              name={bikeName || 'Your Bike'}
              priceInRupees={Number(data.askingPrice) || 0}
              type="bike"
              details={[
                { key: 'Year',  value: data.year    },
                { key: 'KM',    value: data.kmDriven ? `${Number(data.kmDriven).toLocaleString('en-IN')} km` : '' },
                { key: 'City',  value: data.city    },
              ]}
            />
          </div>
        )}
      </div>

      <WizardFooter
        step={step}
        totalSteps={STEPS.length}
        onBack={back}
        onNext={next}
        isSubmitting={submitting}
        submitLabel="PUBLISH LISTING"
      />
    </div>
  );
}
