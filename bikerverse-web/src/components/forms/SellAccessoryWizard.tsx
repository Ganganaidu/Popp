'use client';

import { useState } from 'react';
import { StepBar } from './StepBar';
import { WizardFooter } from './WizardFooter';
import { FormField } from './FormField';
import { FormSelect } from './FormSelect';
import { PhotoUpload } from './PhotoUpload';
import { ListingPreview } from './ListingPreview';
import styles from './Wizard.module.css';

const STEPS = ['Item Info', 'Photos', 'Price & Preview'];

const CATEGORIES = [
  { value: 'helmet',     label: 'Helmet'            },
  { value: 'jacket',     label: 'Riding Jacket'     },
  { value: 'gloves',     label: 'Gloves'            },
  { value: 'boots',      label: 'Boots'             },
  { value: 'pants',      label: 'Riding Pants'      },
  { value: 'protector',  label: 'Body Protector'    },
  { value: 'luggage',    label: 'Luggage / Tank Bag'},
  { value: 'exhaust',    label: 'Exhaust'           },
  { value: 'electronics',label: 'Electronics'       },
  { value: 'other',      label: 'Other'             },
] as const;

const CONDITIONS = [
  { value: 'new',        label: 'Brand New (unused)'    },
  { value: 'like-new',   label: 'Like New (< 3 months)' },
  { value: 'good',       label: 'Good (light use)'      },
  { value: 'fair',       label: 'Fair (visible wear)'   },
] as const;

const SIZES = [
  { value: 'xs',  label: 'XS' },
  { value: 's',   label: 'S'  },
  { value: 'm',   label: 'M'  },
  { value: 'l',   label: 'L'  },
  { value: 'xl',  label: 'XL' },
  { value: 'xxl', label: 'XXL'},
  { value: 'na',  label: 'N/A'},
] as const;

interface FormData {
  category: string; brand: string; model: string;
  condition: string; size: string; color: string; usageMonths: string;
  askingPrice: string; negotiable: boolean; description: string;
}

const INIT: FormData = {
  category: '', brand: '', model: '',
  condition: '', size: '', color: '', usageMonths: '',
  askingPrice: '', negotiable: false, description: '',
};

/**
 * SellAccessoryWizard — 3-step wizard for listing gear/accessories.
 * Step 0: Item Info   (category, brand, model, condition, size, colour, usage)
 * Step 1: Photos      (6-slot uploader)
 * Step 2: Price & Preview
 */
export function SellAccessoryWizard() {
  const [step, setStep]       = useState(0);
  const [data, setData]       = useState<FormData>(INIT);
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
    await new Promise((r) => setTimeout(r, 1200));
    setSubmitting(false);
    alert('Listing published! (Demo — Firestore wired in Phase 7)');
  }

  const itemName = [data.brand, data.model].filter(Boolean).join(' ');

  return (
    <div>
      <StepBar steps={STEPS} current={step} />

      <div className={styles.panel}>

        {/* ── Step 0: Item Info ── */}
        {step === 0 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Item details</h2>
            <div className={styles.row2}>
              <FormSelect label="Category" required options={CATEGORIES} placeholder="Select category" value={data.category} onChange={(e) => set('category', e.target.value)} />
              <FormSelect label="Condition" required options={CONDITIONS} placeholder="Select condition" value={data.condition} onChange={(e) => set('condition', e.target.value)} />
            </div>
            <div className={styles.row2}>
              <FormField label="Brand" required placeholder="e.g. Arai, Alpinestars" value={data.brand} onChange={(e) => set('brand', e.target.value)} />
              <FormField label="Model / Name" required placeholder="e.g. RX-7V, GP Pro" value={data.model} onChange={(e) => set('model', e.target.value)} />
            </div>
            <div className={styles.row3}>
              <FormSelect label="Size" options={SIZES} placeholder="Select size" value={data.size} onChange={(e) => set('size', e.target.value)} />
              <FormField label="Colour" placeholder="e.g. Matte Black" value={data.color} onChange={(e) => set('color', e.target.value)} />
              <FormField label="Used for (months)" type="number" placeholder="e.g. 6" value={data.usageMonths} onChange={(e) => set('usageMonths', e.target.value)} />
            </div>
            <FormField as="textarea" rows={3} label="Description (optional)" placeholder="Describe the item's condition, what's included in the box, reason for selling…" value={data.description} onChange={(e) => set('description', e.target.value)} />
          </div>
        )}

        {/* ── Step 1: Photos ── */}
        {step === 1 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Add photos</h2>
            <PhotoUpload
              maxPhotos={6}
              hint="Upload up to 6 clear photos. Show the item from all angles, and any wear or damage."
            />
          </div>
        )}

        {/* ── Step 2: Price & Preview ── */}
        {step === 2 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Set your price</h2>
            <div className={styles.row2}>
              <FormField
                label="Asking Price (₹)" required type="number"
                placeholder="e.g. 8500"
                value={data.askingPrice}
                onChange={(e) => set('askingPrice', e.target.value)}
              />
              <div className={styles.checkWrap}>
                <label className={styles.checkLabel}>
                  <input type="checkbox" className={styles.checkbox} checked={data.negotiable} onChange={(e) => set('negotiable', e.target.checked)} />
                  <span className={styles.checkText}>Price is negotiable</span>
                </label>
              </div>
            </div>

            <div className={styles.divider} />

            <ListingPreview
              name={itemName || 'Your Item'}
              priceInRupees={Number(data.askingPrice) || 0}
              type="accessory"
              details={[
                { key: 'Condition', value: CONDITIONS.find((c) => c.value === data.condition)?.label ?? '' },
                { key: 'Size',      value: data.size ? SIZES.find((s) => s.value === data.size)?.label ?? '' : '' },
                { key: 'Colour',    value: data.color },
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
