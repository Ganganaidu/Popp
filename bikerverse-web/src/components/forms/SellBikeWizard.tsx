'use client';

import { useState } from 'react';
import {
  SELLER_CATEGORIES, BIKE_BRANDS, BIKE_MODELS, OWNERSHIP_NUMBERS,
  YES_NO, YES_NO_NA, BATTERY_CONDITIONS, TYRE_CONDITIONS, INDIAN_STATES,
  toSelectOptions,
} from '@/lib/data/bikeData';
import { StepBar }        from './StepBar';
import { WizardFooter }   from './WizardFooter';
import { FormField }      from './FormField';
import { FormSelect }     from './FormSelect';
import { MonthYearPicker } from './MonthYearPicker';
import { PhoneField }     from './PhoneField';
import { PhotoUpload }    from './PhotoUpload';
import { ListingPreview } from './ListingPreview';
import styles from './Wizard.module.css';

const STEPS = ['Seller Info', 'Bike Details', 'Condition & Docs', 'Location', 'Price & Photos'];

type MY = { month: string; year: string };
const MY0: MY = { month: '', year: '' };

interface FormData {
  /* Seller */
  sellerCategory: string;
  sellerName: string;
  countryCode: string;
  contactNumber: string;
  /* Bike */
  brandName: string;
  modelName: string;
  modelOther: string;
  mfgDate: MY;
  registrationDate: MY;
  kmDriven: string;
  /* Condition & Docs */
  ownershipNumber: string;
  invoiceAvailable: string;
  nocAvailable: string;
  insuranceAvailable: string;
  insuranceValidTill: MY;
  batteryCondition: string;
  tyreCondition: string;
  /* Location */
  state: string;
  address: string;
  area: string;
  city: string;
  pinCode: string;
  /* Price */
  expectedPrice: string;
  additionalDetails: string;
  termsAccepted: boolean;
}

const INIT: FormData = {
  sellerCategory: '', sellerName: '', countryCode: '+91', contactNumber: '',
  brandName: '', modelName: '', modelOther: '', mfgDate: MY0, registrationDate: MY0, kmDriven: '',
  ownershipNumber: '', invoiceAvailable: '', nocAvailable: '', insuranceAvailable: '',
  insuranceValidTill: MY0, batteryCondition: '', tyreCondition: '',
  state: '', address: '', area: '', city: '', pinCode: '',
  expectedPrice: '', additionalDetails: '', termsAccepted: false,
};

/**
 * SellBikeWizard — 5-step form with full field parity to Flutter sell_your_bike.dart.
 *
 * Steps:
 *  0 — Seller Info       (category, name, contact)
 *  1 — Bike Details      (brand, model, mfg date, reg date, km driven)
 *  2 — Condition & Docs  (ownership, invoice, NOC, insurance, insurance validity, battery, tyre)
 *  3 — Location          (state, address, area, city, pin code)
 *  4 — Price & Photos    (expected price, additional details, photos, T&C, preview)
 */
export function SellBikeWizard() {
  const [step, setStep]     = useState(0);
  const [data, setData]     = useState<FormData>(INIT);
  const [submitting, setSubmitting] = useState(false);

  function set<K extends keyof FormData>(field: K, value: FormData[K]) {
    setData((prev) => ({ ...prev, [field]: value }));
  }

  /* Dynamic model list based on selected brand */
  const modelOptions = data.brandName && data.brandName !== 'Others'
    ? [...(BIKE_MODELS[data.brandName] ?? []), 'Others'].map((m) => ({ value: m, label: m }))
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

  const bikeName = [
    data.brandName === 'Others' ? '' : data.brandName,
    data.modelName === 'Others' ? data.modelOther : data.modelName,
  ].filter(Boolean).join(' ');

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
              countryCode={data.countryCode}
              number={data.contactNumber}
              onCountryCodeChange={(v) => set('countryCode', v)}
              onNumberChange={(v) => set('contactNumber', v)}
            />
          </div>
        )}

        {/* ── Step 1: Bike Details ───────────────────────────────────────── */}
        {step === 1 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Bike details</h2>
            <div className={styles.row2}>
              <FormSelect
                label="Brand Name" required
                options={toSelectOptions(BIKE_BRANDS)}
                placeholder="Select brand"
                value={data.brandName}
                onChange={(e) => { set('brandName', e.target.value); set('modelName', ''); set('modelOther', ''); }}
              />
              {data.brandName && data.brandName !== 'Others' ? (
                <FormSelect
                  label="Model Name" required
                  options={modelOptions}
                  placeholder="Select model"
                  value={data.modelName}
                  onChange={(e) => set('modelName', e.target.value)}
                />
              ) : (
                <FormField
                  label="Model Name" required
                  placeholder="Enter model name"
                  value={data.modelName}
                  onChange={(e) => set('modelName', e.target.value)}
                />
              )}
            </div>

            {/* If model = Others, show manual entry */}
            {data.modelName === 'Others' && (
              <FormField
                label="Model Name (specify)" required
                placeholder="Enter the exact model name"
                value={data.modelOther}
                onChange={(e) => set('modelOther', e.target.value)}
              />
            )}

            <div className={styles.row2}>
              <MonthYearPicker
                label="Manufacture Date" required
                value={data.mfgDate}
                onChange={(v) => set('mfgDate', v)}
              />
              <MonthYearPicker
                label="Registration Date" required
                value={data.registrationDate}
                onChange={(v) => set('registrationDate', v)}
              />
            </div>

            <FormField
              label="KM Driven" required
              type="number"
              placeholder="e.g. 12000"
              value={data.kmDriven}
              onChange={(e) => set('kmDriven', e.target.value)}
              hint="Total odometer reading in kilometres"
            />
          </div>
        )}

        {/* ── Step 2: Condition & Docs ──────────────────────────────────── */}
        {step === 2 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Condition &amp; documentation</h2>
            <div className={styles.row2}>
              <FormSelect
                label="Current Ownership Number" required
                options={toSelectOptions(OWNERSHIP_NUMBERS)}
                placeholder="Select"
                value={data.ownershipNumber}
                onChange={(e) => set('ownershipNumber', e.target.value)}
              />
              <FormSelect
                label="Invoice Available" required
                options={toSelectOptions(YES_NO)}
                placeholder="Select"
                value={data.invoiceAvailable}
                onChange={(e) => set('invoiceAvailable', e.target.value)}
              />
            </div>
            <div className={styles.row2}>
              <FormSelect
                label="NOC Available" required
                options={toSelectOptions(YES_NO_NA)}
                placeholder="Select"
                value={data.nocAvailable}
                onChange={(e) => set('nocAvailable', e.target.value)}
              />
              <FormSelect
                label="Insurance Available" required
                options={toSelectOptions(YES_NO)}
                placeholder="Select"
                value={data.insuranceAvailable}
                onChange={(e) => set('insuranceAvailable', e.target.value)}
              />
            </div>

            {/* Insurance validity — conditional, only when insurance = Yes */}
            {data.insuranceAvailable === 'Yes' && (
              <MonthYearPicker
                label="Insurance Valid Till"
                value={data.insuranceValidTill}
                onChange={(v) => set('insuranceValidTill', v)}
                fromYear={new Date().getFullYear()}
                toYear={new Date().getFullYear() + 10}
              />
            )}

            <div className={styles.row2}>
              <FormSelect
                label="Battery Condition" required
                options={toSelectOptions(BATTERY_CONDITIONS)}
                placeholder="Select"
                value={data.batteryCondition}
                onChange={(e) => set('batteryCondition', e.target.value)}
              />
              <FormSelect
                label="Tyre Condition" required
                options={toSelectOptions(TYRE_CONDITIONS)}
                placeholder="Select"
                value={data.tyreCondition}
                onChange={(e) => set('tyreCondition', e.target.value)}
              />
            </div>
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
                hint="Start typing to search your area"
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
              placeholder="e.g. 250000"
              value={data.expectedPrice}
              onChange={(e) => set('expectedPrice', e.target.value)}
              hint="Enter the asking price in Indian Rupees"
            />
            <FormField
              as="textarea" rows={3}
              label="Additional Details"
              placeholder="Describe the bike's condition, service history, reason for selling, modifications…"
              value={data.additionalDetails}
              onChange={(e) => set('additionalDetails', e.target.value)}
            />
            <PhotoUpload
              maxPhotos={8}
              hint="Upload up to 8 photos. The first photo is the cover. Well-lit photos attract 3× more enquiries."
            />

            <div className={styles.divider} />

            <ListingPreview
              name={bikeName || 'Your Bike'}
              priceInRupees={Number(data.expectedPrice) || 0}
              type="bike"
              details={[
                { key: 'Brand',    value: data.brandName },
                { key: 'Year',     value: data.mfgDate.year },
                { key: 'KM',       value: data.kmDriven ? `${Number(data.kmDriven).toLocaleString('en-IN')} km` : '' },
                { key: 'Owners',   value: data.ownershipNumber ? `${data.ownershipNumber} owner(s)` : '' },
                { key: 'City',     value: data.city },
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
                {' '}and confirm the information provided is accurate.
              </span>
            </label>
          </div>
        )}
      </div>

      <WizardFooter
        step={step}
        totalSteps={STEPS.length}
        onBack={back}
        onNext={next}
        isSubmitting={submitting}
        canProceed={step < 4 || data.termsAccepted}
        submitLabel="PUBLISH LISTING"
      />
    </div>
  );
}
