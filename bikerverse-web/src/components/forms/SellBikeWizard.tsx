'use client';

import { useState } from 'react';
import { Timestamp } from 'firebase/firestore';
import {
  SELLER_CATEGORIES, BIKE_BRANDS, BIKE_MODELS, OWNERSHIP_NUMBERS,
  YES_NO, YES_NO_NA, BATTERY_CONDITIONS, TYRE_CONDITIONS, INDIAN_STATES,
  toSelectOptions,
} from '@/lib/data/bikeData';
import { auth } from '@/lib/firebase/config';
import { createProduct } from '@/lib/firebase/firestore';
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
type Errors = Record<string, string>;

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

function validateStep(s: number, d: FormData): Errors {
  const e: Errors = {};
  const req = (key: string, val: string) => { if (!val.trim()) e[key] = 'This field is required'; };
  const reqMY = (key: string, val: MY) => { if (!val.month || !val.year) e[key] = 'Select both month and year'; };

  if (s === 0) {
    req('sellerCategory', d.sellerCategory);
    req('sellerName', d.sellerName);
    req('contactNumber', d.contactNumber);
  }
  if (s === 1) {
    req('brandName', d.brandName);
    if (d.brandName !== 'Others') req('modelName', d.modelName);
    if (d.modelName === 'Others') req('modelOther', d.modelOther);
    reqMY('mfgDate', d.mfgDate);
    reqMY('registrationDate', d.registrationDate);
    req('kmDriven', d.kmDriven);
  }
  if (s === 2) {
    req('ownershipNumber', d.ownershipNumber);
    req('invoiceAvailable', d.invoiceAvailable);
    req('nocAvailable', d.nocAvailable);
    req('insuranceAvailable', d.insuranceAvailable);
    if (d.insuranceAvailable === 'Yes') reqMY('insuranceValidTill', d.insuranceValidTill);
    req('batteryCondition', d.batteryCondition);
    req('tyreCondition', d.tyreCondition);
  }
  if (s === 3) {
    req('state', d.state);
    req('address', d.address);
    req('area', d.area);
    req('city', d.city);
  }
  if (s === 4) {
    req('expectedPrice', d.expectedPrice);
    if (!d.termsAccepted) e['termsAccepted'] = 'You must accept the Terms & Conditions to publish';
  }
  return e;
}

export function SellBikeWizard() {
  const [step, setStep]         = useState(0);
  const [data, setData]         = useState<FormData>(INIT);
  const [errors, setErrors]     = useState<Errors>({});
  const [submitting, setSubmitting] = useState(false);

  function set<K extends keyof FormData>(field: K, value: FormData[K]) {
    setData((prev) => ({ ...prev, [field]: value }));
    // Clear this field's error as soon as user edits it
    setErrors((prev) => { const e = { ...prev }; delete e[field as string]; return e; });
  }

  const modelOptions = data.brandName && data.brandName !== 'Others'
    ? [...(BIKE_MODELS[data.brandName] ?? []), 'Others'].map((m) => ({ value: m, label: m }))
    : [];

  function next() {
    const stepErrors = validateStep(step, data);
    if (Object.keys(stepErrors).length > 0) {
      setErrors(stepErrors);
      // Scroll to first error
      setTimeout(() => document.querySelector('[aria-invalid="true"]')?.scrollIntoView({ behavior: 'smooth', block: 'center' }), 50);
      return;
    }
    setErrors({});
    if (step < STEPS.length - 1) setStep((s) => s + 1);
    else handleSubmit();
  }

  function back() {
    setErrors({});
    setStep((s) => Math.max(0, s - 1));
  }

  async function handleSubmit() {
    setSubmitting(true);
    try {
      const user = auth.currentUser;
      if (!user) {
        alert('Please sign in to list a bike');
        setSubmitting(false);
        return;
      }

      function myToTimestamp(my: MY): Timestamp | undefined {
        if (!my.month || !my.year) return undefined;
        return Timestamp.fromDate(new Date(parseInt(my.year, 10), parseInt(my.month, 10) - 1, 1));
      }

      const productData: Record<string, unknown> = {
        categoryId: 'cat_001',
        category: 'Premium Bikes',
        brandName: data.brandName === 'Others' ? data.modelOther : data.brandName,
        modelName: data.modelName === 'Others' ? data.modelOther : data.modelName,
        expectedPrice: data.expectedPrice,
        price: data.expectedPrice,
        additionalDetails: data.additionalDetails,
        city: data.city,
        area: data.area,
        state: data.state,
        address: data.address,
        pinCode: data.pinCode,
        sellerName: data.sellerName,
        sellerContactNumber: `${data.countryCode}${data.contactNumber}`,
        sellerCategory: data.sellerCategory,
        countryCode: data.countryCode,
        kmDriven: data.kmDriven,
        firstOwner: data.ownershipNumber,
        invoiceAvailable: data.invoiceAvailable,
        nocAvailable: data.nocAvailable,
        insuranceAvailable: data.insuranceAvailable,
        batteryCondition: data.batteryCondition,
        tyreCondition: data.tyreCondition,
        isApproved: false,
        isSold: false,
        isActive: true,
      };

      const mfgTs = myToTimestamp(data.mfgDate);
      if (mfgTs) productData.mfgDate = mfgTs;

      const regTs = myToTimestamp(data.registrationDate);
      if (regTs) productData.registrationDate = regTs;

      if (data.insuranceAvailable === 'Yes') {
        const insTs = myToTimestamp(data.insuranceValidTill);
        if (insTs) productData.insuranceValidTill = insTs;
      }

      const docId = await createProduct(productData, user.uid);
      if (docId) {
        alert('Listing submitted for approval! It will be reviewed before going live.');
      } else {
        alert('Failed to submit listing. Please try again.');
      }
    } catch (err) {
      console.error('handleSubmit error:', err);
      alert('Failed to submit listing. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  const bikeName = [
    data.brandName === 'Others' ? '' : data.brandName,
    data.modelName === 'Others' ? data.modelOther : data.modelName,
  ].filter(Boolean).join(' ');

  const canProceed = Object.keys(errors).length === 0;

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
              error={errors.sellerCategory}
            />
            <FormField
              label="Seller Name" required
              placeholder="Your full name or business name"
              value={data.sellerName}
              onChange={(e) => set('sellerName', e.target.value)}
              error={errors.sellerName}
            />
            <PhoneField
              label="Contact Number" required
              countryCode={data.countryCode}
              number={data.contactNumber}
              onCountryCodeChange={(v) => set('countryCode', v)}
              onNumberChange={(v) => { set('contactNumber', v); }}
              error={errors.contactNumber}
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
                error={errors.brandName}
              />
              {data.brandName && data.brandName !== 'Others' ? (
                <FormSelect
                  label="Model Name" required
                  options={modelOptions}
                  placeholder="Select model"
                  value={data.modelName}
                  onChange={(e) => set('modelName', e.target.value)}
                  error={errors.modelName}
                />
              ) : (
                <FormField
                  label="Model Name" required
                  placeholder="Enter model name"
                  value={data.modelName}
                  onChange={(e) => set('modelName', e.target.value)}
                  error={errors.modelName}
                />
              )}
            </div>

            {data.modelName === 'Others' && (
              <FormField
                label="Model Name (specify)" required
                placeholder="Enter the exact model name"
                value={data.modelOther}
                onChange={(e) => set('modelOther', e.target.value)}
                error={errors.modelOther}
              />
            )}

            <div className={styles.row2}>
              <MonthYearPicker
                label="Manufacture Date" required
                value={data.mfgDate}
                onChange={(v) => set('mfgDate', v)}
                error={errors.mfgDate}
              />
              <MonthYearPicker
                label="Registration Date" required
                value={data.registrationDate}
                onChange={(v) => set('registrationDate', v)}
                error={errors.registrationDate}
              />
            </div>

            <FormField
              label="KM Driven" required
              type="number"
              placeholder="e.g. 12000"
              value={data.kmDriven}
              onChange={(e) => set('kmDriven', e.target.value)}
              hint="Total odometer reading in kilometres"
              error={errors.kmDriven}
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
                error={errors.ownershipNumber}
              />
              <FormSelect
                label="Invoice Available" required
                options={toSelectOptions(YES_NO)}
                placeholder="Select"
                value={data.invoiceAvailable}
                onChange={(e) => set('invoiceAvailable', e.target.value)}
                error={errors.invoiceAvailable}
              />
            </div>
            <div className={styles.row2}>
              <FormSelect
                label="NOC Available" required
                options={toSelectOptions(YES_NO_NA)}
                placeholder="Select"
                value={data.nocAvailable}
                onChange={(e) => set('nocAvailable', e.target.value)}
                error={errors.nocAvailable}
              />
              <FormSelect
                label="Insurance Available" required
                options={toSelectOptions(YES_NO)}
                placeholder="Select"
                value={data.insuranceAvailable}
                onChange={(e) => set('insuranceAvailable', e.target.value)}
                error={errors.insuranceAvailable}
              />
            </div>

            {data.insuranceAvailable === 'Yes' && (
              <MonthYearPicker
                label="Insurance Valid Till" required
                value={data.insuranceValidTill}
                onChange={(v) => set('insuranceValidTill', v)}
                fromYear={new Date().getFullYear()}
                toYear={new Date().getFullYear() + 10}
                error={errors.insuranceValidTill}
              />
            )}

            <div className={styles.row2}>
              <FormSelect
                label="Battery Condition" required
                options={toSelectOptions(BATTERY_CONDITIONS)}
                placeholder="Select"
                value={data.batteryCondition}
                onChange={(e) => set('batteryCondition', e.target.value)}
                error={errors.batteryCondition}
              />
              <FormSelect
                label="Tyre Condition" required
                options={toSelectOptions(TYRE_CONDITIONS)}
                placeholder="Select"
                value={data.tyreCondition}
                onChange={(e) => set('tyreCondition', e.target.value)}
                error={errors.tyreCondition}
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
              error={errors.state}
            />
            <FormField
              label="Address" required
              placeholder="Street address, landmark…"
              value={data.address}
              onChange={(e) => set('address', e.target.value)}
              error={errors.address}
            />
            <div className={styles.row2}>
              <FormField
                label="Area" required
                placeholder="Neighbourhood / locality"
                value={data.area}
                onChange={(e) => set('area', e.target.value)}
                hint="Start typing to search your area"
                error={errors.area}
              />
              <FormField
                label="City" required
                placeholder="City"
                value={data.city}
                onChange={(e) => set('city', e.target.value)}
                error={errors.city}
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
              error={errors.expectedPrice}
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
              />
              <span className={styles.checkText}>
                I agree to the{' '}
                <a href="/terms" className={styles.checkLink} target="_blank">Terms &amp; Conditions</a>
                {' '}and confirm the information provided is accurate.
              </span>
            </label>
            {errors.termsAccepted && (
              <span className={styles.fieldError}>{errors.termsAccepted}</span>
            )}
          </div>
        )}
      </div>

      <WizardFooter
        step={step}
        totalSteps={STEPS.length}
        onBack={back}
        onNext={next}
        isSubmitting={submitting}
        canProceed={canProceed}
        submitLabel="PUBLISH LISTING"
      />
    </div>
  );
}
