'use client';

import { useState } from 'react';
import {
  SELLER_CATEGORIES, BIKE_BRANDS, BIKE_MODELS, ACCESSORY_CATEGORIES,
  PRODUCT_CONDITIONS, INDIAN_STATES, toSelectOptions,
} from '@/lib/data/bikeData';
import { StepBar }         from './StepBar';
import { WizardFooter }    from './WizardFooter';
import { FormField }       from './FormField';
import { FormSelect }      from './FormSelect';
import { MonthYearPicker } from './MonthYearPicker';
import { PhoneField }      from './PhoneField';
import { PhotoUpload }     from './PhotoUpload';
import { ListingPreview }  from './ListingPreview';
import styles from './Wizard.module.css';

const STEPS = ['Seller Info', 'Item Details', 'Bill & Warranty', 'Location', 'Price & Photos'];

type MY = { month: string; year: string };
const MY0: MY = { month: '', year: '' };

interface FormData {
  /* Seller */
  sellerCategory: string; sellerName: string; countryCode: string; contactNumber: string;
  /* Item */
  categoryId: string; subcategory: string;
  accessoryName: string; brandName: string;
  isBikeSpecific: boolean;
  bikeBrandName: string; bikeModelName: string; bikeMfgDate: MY;
  productCondition: string; productSize: string;
  /* Bill & Warranty */
  billAvailable: boolean; billDate: MY; productAging: string;
  warrantyAvailable: boolean; warrantyMonths: string;
  /* Location */
  state: string; address: string; area: string; city: string; pinCode: string;
  /* Price */
  expectedPrice: string; additionalDetails: string; termsAccepted: boolean;
}

const INIT: FormData = {
  sellerCategory: '', sellerName: '', countryCode: '+91', contactNumber: '',
  categoryId: '', subcategory: '', accessoryName: '', brandName: '',
  isBikeSpecific: false,
  bikeBrandName: '', bikeModelName: '', bikeMfgDate: MY0,
  productCondition: '', productSize: '',
  billAvailable: false, billDate: MY0, productAging: '',
  warrantyAvailable: true, warrantyMonths: '',
  state: '', address: '', area: '', city: '', pinCode: '',
  expectedPrice: '', additionalDetails: '', termsAccepted: false,
};

/**
 * SellAccessoryWizard — 5-step form with full field parity to
 * Flutter sell_your_accessories.dart.
 *
 * Steps:
 *  0 — Seller Info      (category, name, contact)
 *  1 — Item Details     (category, subcategory, name, brand, bike-specific toggle + conditionals, condition, size)
 *  2 — Bill & Warranty  (bill toggle + date/aging, warranty toggle + period)
 *  3 — Location         (state, address, area, city, pin code)
 *  4 — Price & Photos   (price, additional details, photos, T&C, preview)
 */
export function SellAccessoryWizard() {
  const [step, setStep]     = useState(0);
  const [data, setData]     = useState<FormData>(INIT);
  const [submitting, setSubmitting] = useState(false);

  function set<K extends keyof FormData>(field: K, value: FormData[K]) {
    setData((prev) => ({ ...prev, [field]: value }));
  }

  const selectedCat = ACCESSORY_CATEGORIES.find((c) => c.id === data.categoryId);
  const subcatOptions = selectedCat?.subcategories.map((s) => ({ value: s, label: s })) ?? [];
  const bikeBrandModelOptions = data.bikeBrandName
    ? [...(BIKE_MODELS[data.bikeBrandName] ?? []), 'Others'].map((m) => ({ value: m, label: m }))
    : [];

  function next() {
    if (step < STEPS.length - 1) setStep((s) => s + 1);
    else handleSubmit();
  }
  function back() { setStep((s) => Math.max(0, s - 1)); }

  async function handleSubmit() {
    setSubmitting(true);
    await new Promise((r) => setTimeout(r, 1400));
    setSubmitting(false);
    alert('Listing published! (Firestore write wired in Phase 7)');
  }

  return (
    <div>
      <StepBar steps={STEPS} current={step} />
      <div className={styles.panel}>

        {/* ── Step 0: Seller Info ────────────────────────────────────────── */}
        {step === 0 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Seller information</h2>
            <FormSelect
              label="Seller Category" required
              options={toSelectOptions(SELLER_CATEGORIES)}
              placeholder="Select category"
              value={data.sellerCategory}
              onChange={(e) => set('sellerCategory', e.target.value)}
            />
            <FormField
              label="Seller Name" required
              placeholder="Your full name or business name"
              value={data.sellerName}
              onChange={(e) => set('sellerName', e.target.value)}
            />
            <PhoneField
              label="Contact Number" required
              countryCode={data.countryCode} number={data.contactNumber}
              onCountryCodeChange={(v) => set('countryCode', v)}
              onNumberChange={(v) => set('contactNumber', v)}
            />
          </div>
        )}

        {/* ── Step 1: Item Details ──────────────────────────────────────── */}
        {step === 1 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Item details</h2>
            <div className={styles.row2}>
              <FormSelect
                label="Category" required
                options={ACCESSORY_CATEGORIES.map((c) => ({ value: c.id, label: c.name }))}
                placeholder="Select category"
                value={data.categoryId}
                onChange={(e) => { set('categoryId', e.target.value); set('subcategory', ''); }}
              />
              {selectedCat && selectedCat.subcategories.length > 0 ? (
                <FormSelect
                  label="Subcategory" required
                  options={subcatOptions}
                  placeholder="Select subcategory"
                  value={data.subcategory}
                  onChange={(e) => set('subcategory', e.target.value)}
                />
              ) : (
                <div /> /* placeholder to maintain grid */
              )}
            </div>
            <div className={styles.row2}>
              <FormField
                label="Accessories Name" required
                placeholder="e.g. Arai RX-7V Helmet"
                value={data.accessoryName}
                onChange={(e) => set('accessoryName', e.target.value)}
              />
              <FormField
                label="Brand Name" required
                placeholder="e.g. Arai, Alpinestars, REV'IT"
                value={data.brandName}
                onChange={(e) => set('brandName', e.target.value)}
              />
            </div>
            <div className={styles.row2}>
              <FormSelect
                label="Product Condition" required
                options={toSelectOptions(PRODUCT_CONDITIONS)}
                placeholder="Select condition"
                value={data.productCondition}
                onChange={(e) => set('productCondition', e.target.value)}
              />
              <FormField
                label="Product Size"
                type="text"
                placeholder="e.g. L, XL, 59cm, 42"
                value={data.productSize}
                onChange={(e) => set('productSize', e.target.value)}
                hint="Size in standard units (optional)"
              />
            </div>

            {/* Bike-specific toggle */}
            <div className={styles.toggleRow}>
              <label className={styles.toggleLabel}>
                <span className={styles.toggleText}>Is your product bike specific?</span>
                <div
                  className={[styles.toggle, data.isBikeSpecific ? styles.toggleOn : ''].filter(Boolean).join(' ')}
                  role="switch"
                  aria-checked={data.isBikeSpecific}
                  tabIndex={0}
                  onClick={() => { set('isBikeSpecific', !data.isBikeSpecific); }}
                  onKeyDown={(e) => e.key === 'Enter' && set('isBikeSpecific', !data.isBikeSpecific)}
                >
                  <span className={styles.toggleThumb} />
                </div>
              </label>
            </div>

            {/* Conditional: bike-specific fields */}
            {data.isBikeSpecific && (
              <>
                <div className={styles.row2}>
                  <FormSelect
                    label="Bike Brand Name" required
                    options={toSelectOptions(BIKE_BRANDS)}
                    placeholder="Select bike brand"
                    value={data.bikeBrandName}
                    onChange={(e) => { set('bikeBrandName', e.target.value); set('bikeModelName', ''); }}
                  />
                  {data.bikeBrandName ? (
                    <FormSelect
                      label="Bike Model Name" required
                      options={bikeBrandModelOptions}
                      placeholder="Select model"
                      value={data.bikeModelName}
                      onChange={(e) => set('bikeModelName', e.target.value)}
                    />
                  ) : (
                    <FormField
                      label="Bike Model Name"
                      placeholder="Select brand first"
                      value=""
                      disabled
                      onChange={() => {}}
                    />
                  )}
                </div>
                <MonthYearPicker
                  label="Bike Manufacture Date"
                  value={data.bikeMfgDate}
                  onChange={(v) => set('bikeMfgDate', v)}
                />
              </>
            )}
          </div>
        )}

        {/* ── Step 2: Bill & Warranty ──────────────────────────────────── */}
        {step === 2 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Bill &amp; warranty</h2>

            {/* Bill available */}
            <div className={styles.toggleRow}>
              <label className={styles.toggleLabel}>
                <span className={styles.toggleText}>Bill available?</span>
                <div
                  className={[styles.toggle, data.billAvailable ? styles.toggleOn : ''].filter(Boolean).join(' ')}
                  role="switch" aria-checked={data.billAvailable} tabIndex={0}
                  onClick={() => set('billAvailable', !data.billAvailable)}
                  onKeyDown={(e) => e.key === 'Enter' && set('billAvailable', !data.billAvailable)}
                >
                  <span className={styles.toggleThumb} />
                </div>
              </label>
            </div>
            {data.billAvailable && (
              <div className={styles.row2}>
                <MonthYearPicker
                  label="Bill Date"
                  value={data.billDate}
                  onChange={(v) => set('billDate', v)}
                />
                <FormField
                  label="Product Age (months)"
                  type="number"
                  placeholder="e.g. 8"
                  value={data.productAging}
                  onChange={(e) => set('productAging', e.target.value)}
                  hint="How many months since purchase"
                />
              </div>
            )}

            {/* Warranty available */}
            <div className={styles.toggleRow}>
              <label className={styles.toggleLabel}>
                <span className={styles.toggleText}>Warranty available?</span>
                <div
                  className={[styles.toggle, data.warrantyAvailable ? styles.toggleOn : ''].filter(Boolean).join(' ')}
                  role="switch" aria-checked={data.warrantyAvailable} tabIndex={0}
                  onClick={() => set('warrantyAvailable', !data.warrantyAvailable)}
                  onKeyDown={(e) => e.key === 'Enter' && set('warrantyAvailable', !data.warrantyAvailable)}
                >
                  <span className={styles.toggleThumb} />
                </div>
              </label>
            </div>
            {data.warrantyAvailable && (
              <FormField
                label="Remaining Warranty (months)"
                type="number"
                placeholder="e.g. 12"
                value={data.warrantyMonths}
                onChange={(e) => set('warrantyMonths', e.target.value)}
              />
            )}
          </div>
        )}

        {/* ── Step 3: Location ─────────────────────────────────────────── */}
        {step === 3 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Location</h2>
            <FormSelect
              label="State" required
              options={toSelectOptions(INDIAN_STATES)}
              placeholder="Select state"
              value={data.state}
              onChange={(e) => set('state', e.target.value)}
            />
            <FormField
              label="Address" required
              placeholder="Street address, landmark…"
              value={data.address}
              onChange={(e) => set('address', e.target.value)}
            />
            <div className={styles.row2}>
              <FormField
                label="Area" required
                placeholder="Neighbourhood / locality"
                value={data.area}
                onChange={(e) => set('area', e.target.value)}
              />
              <FormField
                label="City" required
                placeholder="City"
                value={data.city}
                onChange={(e) => set('city', e.target.value)}
              />
            </div>
            <FormField
              label="Pin Code"
              type="number"
              placeholder="6-digit PIN code"
              value={data.pinCode}
              onChange={(e) => set('pinCode', e.target.value)}
            />
          </div>
        )}

        {/* ── Step 4: Price & Photos ───────────────────────────────────── */}
        {step === 4 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Price &amp; photos</h2>
            <FormField
              label="Expected Price (₹)" required
              type="number"
              placeholder="e.g. 8500"
              value={data.expectedPrice}
              onChange={(e) => set('expectedPrice', e.target.value)}
              hint="Enter the asking price in Indian Rupees"
            />
            <FormField
              as="textarea" rows={3}
              label="Additional Details"
              placeholder="Describe the item's condition, what's included, reason for selling…"
              value={data.additionalDetails}
              onChange={(e) => set('additionalDetails', e.target.value)}
            />
            <PhotoUpload
              maxPhotos={8}
              hint="Upload up to 8 photos. Show the item from multiple angles, and any wear or damage."
            />

            <div className={styles.divider} />

            <ListingPreview
              name={data.accessoryName || 'Your Item'}
              priceInRupees={Number(data.expectedPrice) || 0}
              type="accessory"
              details={[
                { key: 'Brand',     value: data.brandName },
                { key: 'Condition', value: data.productCondition },
                { key: 'Size',      value: data.productSize },
                { key: 'City',      value: data.city },
              ]}
            />

            <div className={styles.divider} />

            <label className={styles.checkLabel}>
              <input
                type="checkbox"
                className={styles.checkbox}
                checked={data.termsAccepted}
                onChange={(e) => set('termsAccepted', e.target.checked)}
                required
              />
              <span className={styles.checkText}>
                I agree to the{' '}
                <a href="/terms" className={styles.checkLink} target="_blank">Terms &amp; Conditions</a>
                {' '}and confirm all information is accurate.
              </span>
            </label>
          </div>
        )}
      </div>

      <WizardFooter
        step={step} totalSteps={STEPS.length}
        onBack={back} onNext={next}
        isSubmitting={submitting}
        canProceed={step < 4 || data.termsAccepted}
        submitLabel="PUBLISH LISTING"
      />
    </div>
  );
}
