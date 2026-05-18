'use client';

import { useState } from 'react';
import { StepBar } from './StepBar';
import { WizardFooter } from './WizardFooter';
import { FormField } from './FormField';
import { FormSelect } from './FormSelect';
import { PhotoUpload } from './PhotoUpload';
import { ListingPreview } from './ListingPreview';
import styles from './Wizard.module.css';

const STEPS = ['Shop Info', 'Services & Tags', 'Preview'];

const CATEGORIES = [
  { value: 'mechanics',    label: 'Mechanic / Workshop'  },
  { value: 'tyre',         label: 'Tyre Shop'             },
  { value: 'accessories',  label: 'Accessory Store'       },
  { value: 'trackdays',    label: 'Track Day Organiser'   },
  { value: 'training',     label: 'Riding School'         },
] as const;

const EXPERIENCE = [
  { value: '1-3',   label: '1 – 3 years'   },
  { value: '3-5',   label: '3 – 5 years'   },
  { value: '5-10',  label: '5 – 10 years'  },
  { value: '10+',   label: '10+ years'     },
] as const;

const ALL_TAGS = [
  'Ducati', 'Triumph', 'Kawasaki', 'KTM', 'Royal Enfield', 'BMW',
  'Honda', 'Harley-Davidson', 'Yamaha', 'Suzuki',
  'ECU Tune', 'Dyno', 'Suspension', 'Track Prep', 'Race Fairings',
  'Akrapovic', 'SC Project', 'Yoshimura',
  'Restoration', 'Diagnostics', 'Detailing',
];

const STATES = [
  'Andhra Pradesh','Delhi','Gujarat','Karnataka','Kerala',
  'Maharashtra','Rajasthan','Tamil Nadu','Telangana','West Bengal','Other',
].map((s) => ({ value: s.toLowerCase().replace(/\s/g, '-'), label: s }));

interface FormData {
  shopName: string; category: string; city: string; state: string;
  address: string; phone: string; experience: string;
  about: string; tags: string[];
}

const INIT: FormData = {
  shopName: '', category: '', city: '', state: '',
  address: '', phone: '', experience: '',
  about: '', tags: [],
};

/**
 * ListServiceWizard — 3-step wizard for listing a service provider.
 * Step 0: Shop Info   (name, category, location, phone, experience)
 * Step 1: Services & Tags + photos
 * Step 2: Preview
 */
export function ListServiceWizard() {
  const [step, setStep]       = useState(0);
  const [data, setData]       = useState<FormData>(INIT);
  const [submitting, setSubmitting] = useState(false);

  function set<K extends keyof FormData>(field: K, value: FormData[K]) {
    setData((prev) => ({ ...prev, [field]: value }));
  }

  function toggleTag(tag: string) {
    setData((prev) => ({
      ...prev,
      tags: prev.tags.includes(tag) ? prev.tags.filter((t) => t !== tag) : [...prev.tags, tag],
    }));
  }

  function next() {
    if (step < STEPS.length - 1) setStep((s) => s + 1);
    else handleSubmit();
  }

  function back() { setStep((s) => Math.max(0, s - 1)); }

  async function handleSubmit() {
    setSubmitting(true);
    await new Promise((r) => setTimeout(r, 1200));
    setSubmitting(false);
    alert('Service listed! (Demo — Firestore wired in Phase 7)');
  }

  return (
    <div>
      <StepBar steps={STEPS} current={step} />

      <div className={styles.panel}>

        {/* ── Step 0: Shop Info ── */}
        {step === 0 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>About your shop</h2>
            <div className={styles.row2}>
              <FormField label="Shop Name" required placeholder="e.g. Weekendmech Pvt Ltd" value={data.shopName} onChange={(e) => set('shopName', e.target.value)} />
              <FormSelect label="Category" required options={CATEGORIES} placeholder="Select type" value={data.category} onChange={(e) => set('category', e.target.value)} />
            </div>
            <div className={styles.row2}>
              <FormField label="City" required placeholder="e.g. Hyderabad" value={data.city} onChange={(e) => set('city', e.target.value)} />
              <FormSelect label="State" required options={STATES} placeholder="Select state" value={data.state} onChange={(e) => set('state', e.target.value)} />
            </div>
            <FormField as="textarea" rows={2} label="Full Address" placeholder="Street address, landmark…" value={data.address} onChange={(e) => set('address', e.target.value)} />
            <div className={styles.row2}>
              <FormField label="Phone Number" required type="tel" placeholder="+91 98491 00000" value={data.phone} onChange={(e) => set('phone', e.target.value)} />
              <FormSelect label="Years of Experience" options={EXPERIENCE} placeholder="Select" value={data.experience} onChange={(e) => set('experience', e.target.value)} />
            </div>
            <FormField as="textarea" rows={4} label="About Your Shop" required placeholder="Describe your speciality, certifications, brands you work on…" value={data.about} onChange={(e) => set('about', e.target.value)} />
          </div>
        )}

        {/* ── Step 1: Services & Tags + Photos ── */}
        {step === 1 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Services & specialisations</h2>
            <p className={styles.stepHint}>Select all tags that apply to your shop. These help riders find you.</p>
            <div className={styles.tagGrid}>
              {ALL_TAGS.map((tag) => (
                <button
                  key={tag}
                  type="button"
                  className={[styles.tag, data.tags.includes(tag) ? styles.tagActive : ''].filter(Boolean).join(' ')}
                  onClick={() => toggleTag(tag)}
                >
                  {tag}
                </button>
              ))}
            </div>

            <div className={styles.divider} />

            <PhotoUpload
              label="SHOP PHOTOS"
              maxPhotos={6}
              hint="Upload photos of your shop, equipment and work. Clear photos build trust with customers."
            />
          </div>
        )}

        {/* ── Step 2: Preview ── */}
        {step === 2 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Review & publish</h2>
            <p className={styles.stepHint}>Check how your listing will appear to customers before publishing.</p>

            <ListingPreview
              name={data.shopName || 'Your Shop'}
              type="service"
              details={[
                { key: 'Type',  value: CATEGORIES.find((c) => c.value === data.category)?.label ?? '' },
                { key: 'City',  value: data.city   },
                { key: 'Tags',  value: data.tags.slice(0, 3).join(', ') },
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
        submitLabel="LIST MY SHOP"
        nextLabel="NEXT"
      />
    </div>
  );
}
