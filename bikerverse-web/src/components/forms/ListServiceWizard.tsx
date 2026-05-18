'use client';

import { useState } from 'react';
import {
  SERVICE_CATEGORIES, RIDER_SKILL_LEVELS, BIKE_PROVISION,
  TOWING_SERVICE_TYPES, SERVICE_COVERAGE_AREAS, INDIAN_STATES,
  toSelectOptions,
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

/* Steps differ per category group */
const STEPS_STANDARD    = ['Category', 'Business Info', 'Location & Hours', 'Photos & Preview'];
const STEPS_EVENT       = ['Category', 'Event Details', 'Location',          'Photos & Preview'];
const STEPS_TOWING      = ['Category', 'Business Info', 'Location & Hours', 'Photos & Preview'];

type MY = { month: string; year: string };
const MY0: MY = { month: '', year: '' };

interface FormData {
  /* Category */
  serviceCategory: string;

  /* Common business fields */
  shopName: string; businessTitle: string; businessDescription: string;
  countryCode: string; contactNumber: string; contactName: string;
  gstNumber: string; googleMapsLink: string; socialMediaLink: string;

  /* Location */
  state: string; address: string; area: string; city: string; pinCode: string;

  /* Working hours (free text — mirrors Flutter's WorkingHoursPicker output) */
  workingHours: string;

  /* Find Mechanic specific */
  premiumBikeInspection: string;

  /* Tyre Shop specific */
  tyreFitment: string;

  /* Track/Training Day specific */
  eventName: string;
  eventCountryCode: string; eventContactNumber: string; eventContactName: string;
  bikeTypeModel: string; bikeProvision: string; riderSkillLevel: string;
  eventStartDate: MY; eventEndDate: MY;
  eventStartTime: string; eventEndTime: string;
  maxSlots: string; eventDescription: string;
  locationName: string; locationAddress: string;
  googleFormLink: string;

  /* Towing Service specific */
  bikeRSA: string; towingServiceName: string; businessName: string;
  towingTypes: string[]; towingTypeOther: string;
  serviceCoverageArea: string;

  /* Terms */
  termsAccepted: boolean;
}

const INIT: FormData = {
  serviceCategory: '',
  shopName: '', businessTitle: '', businessDescription: '',
  countryCode: '+91', contactNumber: '', contactName: '',
  gstNumber: '', googleMapsLink: '', socialMediaLink: '',
  state: '', address: '', area: '', city: '', pinCode: '',
  workingHours: '',
  premiumBikeInspection: '', tyreFitment: '',
  eventName: '',
  eventCountryCode: '+91', eventContactNumber: '', eventContactName: '',
  bikeTypeModel: '', bikeProvision: '', riderSkillLevel: '',
  eventStartDate: MY0, eventEndDate: MY0,
  eventStartTime: '', eventEndTime: '',
  maxSlots: '', eventDescription: '',
  locationName: '', locationAddress: '',
  googleFormLink: '',
  bikeRSA: '', towingServiceName: '', businessName: '',
  towingTypes: [], towingTypeOther: '',
  serviceCoverageArea: '',
  termsAccepted: false,
};

function isEvent(cat: string) { return cat === 'Track day' || cat === 'Training day'; }
function isTowing(cat: string) { return cat === 'Towing Service'; }
function isMechanic(cat: string) { return cat === 'Find Mechanic'; }
function isTyreShop(cat: string) { return cat === 'Tyre Shops'; }
function isStandard(cat: string) { return !isEvent(cat) && !isTowing(cat); }

/**
 * ListServiceWizard — multi-step form with full field parity to
 * Flutter list_service_form_screen.dart.
 *
 * Category-aware steps:
 *  Standard (Mechanic / Rentals / Accessory Store / Tyre Shops):
 *    0 Category → 1 Business Info → 2 Location & Hours → 3 Photos & Preview
 *  Track Day / Training Day:
 *    0 Category → 1 Event Details → 2 Location → 3 Photos & Preview
 *  Towing Service:
 *    0 Category → 1 Business Info (+ towing fields) → 2 Location & Hours → 3 Photos & Preview
 */
export function ListServiceWizard() {
  const [step, setStep]     = useState(0);
  const [data, setData]     = useState<FormData>(INIT);
  const [submitting, setSubmitting] = useState(false);

  function set<K extends keyof FormData>(field: K, value: FormData[K]) {
    setData((prev) => ({ ...prev, [field]: value }));
  }

  function toggleTowingType(t: string) {
    setData((prev) => ({
      ...prev,
      towingTypes: prev.towingTypes.includes(t)
        ? prev.towingTypes.filter((x) => x !== t)
        : [...prev.towingTypes, t],
    }));
  }

  const steps = isEvent(data.serviceCategory) ? STEPS_EVENT : STEPS_STANDARD;

  function next() {
    if (step < steps.length - 1) setStep((s) => s + 1);
    else handleSubmit();
  }
  function back() { setStep((s) => Math.max(0, s - 1)); }

  async function handleSubmit() {
    setSubmitting(true);
    await new Promise((r) => setTimeout(r, 1400));
    setSubmitting(false);
    alert('Service listed! (Firestore write wired in Phase 7)');
  }

  const lastStep = steps.length - 1;

  return (
    <div>
      <StepBar steps={steps} current={step} />
      <div className={styles.panel}>

        {/* ── Step 0: Category Selection ────────────────────────────────── */}
        {step === 0 && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Select service type</h2>
            <p className={styles.stepHint}>Choose the category that best describes your listing.</p>
            <div className={styles.catGrid}>
              {SERVICE_CATEGORIES.map((cat) => (
                <button
                  key={cat}
                  type="button"
                  className={[styles.catCard, data.serviceCategory === cat ? styles.catCardActive : ''].filter(Boolean).join(' ')}
                  onClick={() => { set('serviceCategory', cat); }}
                >
                  <span className={styles.catIcon}>{CAT_ICONS[cat]}</span>
                  <span className={styles.catLabel}>{cat}</span>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* ── Step 1 — STANDARD: Business Info ─────────────────────────── */}
        {step === 1 && isStandard(data.serviceCategory) && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Business information</h2>
            <div className={styles.row2}>
              <FormField
                label="Shop Name" required
                placeholder="e.g. Weekendmech Pvt Ltd"
                value={data.shopName}
                onChange={(e) => set('shopName', e.target.value)}
              />
              <FormField
                label="Business Title" required
                placeholder="e.g. Performance Workshop"
                value={data.businessTitle}
                onChange={(e) => set('businessTitle', e.target.value)}
              />
            </div>
            <FormField
              as="textarea" rows={3}
              label="Business Description" required
              placeholder="Describe your services, specialisations, certifications…"
              value={data.businessDescription}
              onChange={(e) => set('businessDescription', e.target.value)}
            />
            <PhoneField
              label="Contact Number" required
              countryCode={data.countryCode} number={data.contactNumber}
              onCountryCodeChange={(v) => set('countryCode', v)}
              onNumberChange={(v) => set('contactNumber', v)}
            />
            <FormField
              label="Contact Name" required
              placeholder="Name of person to contact"
              value={data.contactName}
              onChange={(e) => set('contactName', e.target.value)}
            />
            <div className={styles.row2}>
              <FormField
                label="GST Number" required
                placeholder="22AAAAA0000A1Z5"
                value={data.gstNumber}
                onChange={(e) => set('gstNumber', e.target.value)}
              />
              <FormField
                label="Google Maps Link"
                placeholder="https://maps.google.com/…"
                value={data.googleMapsLink}
                onChange={(e) => set('googleMapsLink', e.target.value)}
              />
            </div>
            <FormField
              label="Social Media Link"
              placeholder="Instagram / Facebook page URL"
              value={data.socialMediaLink}
              onChange={(e) => set('socialMediaLink', e.target.value)}
            />

            {/* Find Mechanic: premium inspection field */}
            {isMechanic(data.serviceCategory) && (
              <FormSelect
                label="Premium Bike Inspection Available"
                options={toSelectOptions(['Yes', 'No'] as const)}
                placeholder="Select"
                value={data.premiumBikeInspection}
                onChange={(e) => set('premiumBikeInspection', e.target.value)}
              />
            )}

            {/* Tyre Shop: fitment field */}
            {isTyreShop(data.serviceCategory) && (
              <FormSelect
                label="Tyre Fitment Available"
                options={toSelectOptions(['Yes', 'No'] as const)}
                placeholder="Select"
                value={data.tyreFitment}
                onChange={(e) => set('tyreFitment', e.target.value)}
              />
            )}

            {/* Towing: extra towing-specific fields */}
            {isTowing(data.serviceCategory) && (
              <>
                <div className={styles.row2}>
                  <FormField
                    label="Bike RSA" required
                    placeholder="RSA number / reference"
                    value={data.bikeRSA}
                    onChange={(e) => set('bikeRSA', e.target.value)}
                  />
                  <FormField
                    label="Towing Service Name" required
                    placeholder="Name of your towing service"
                    value={data.towingServiceName}
                    onChange={(e) => set('towingServiceName', e.target.value)}
                  />
                </div>
                <FormField
                  label="Business Name" required
                  placeholder="Registered business name"
                  value={data.businessName}
                  onChange={(e) => set('businessName', e.target.value)}
                />
                <div className={styles.fields}>
                  <span className={styles.subLabel}>List of Towing Services (select all that apply)</span>
                  <div className={styles.tagGrid}>
                    {TOWING_SERVICE_TYPES.map((t) => (
                      <button
                        key={t}
                        type="button"
                        className={[styles.tag, data.towingTypes.includes(t) ? styles.tagActive : ''].filter(Boolean).join(' ')}
                        onClick={() => toggleTowingType(t)}
                      >
                        {t}
                      </button>
                    ))}
                  </div>
                  {data.towingTypes.includes('Others') && (
                    <FormField
                      label="Specify Other Towing Service" required
                      placeholder="Describe the service"
                      value={data.towingTypeOther}
                      onChange={(e) => set('towingTypeOther', e.target.value)}
                    />
                  )}
                </div>
                <FormSelect
                  label="Service Coverage Area" required
                  options={toSelectOptions(SERVICE_COVERAGE_AREAS)}
                  placeholder="Select coverage area"
                  value={data.serviceCoverageArea}
                  onChange={(e) => set('serviceCoverageArea', e.target.value)}
                />
              </>
            )}
          </div>
        )}

        {/* ── Step 1 — EVENT: Event Details ────────────────────────────── */}
        {step === 1 && isEvent(data.serviceCategory) && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Event details</h2>
            <FormField
              label="Event Name" required
              placeholder="e.g. Bikerverse Track Day — BIC Round 4"
              value={data.eventName}
              onChange={(e) => set('eventName', e.target.value)}
            />
            <div className={styles.row2}>
              <PhoneField
                label="Contact Number" required
                countryCode={data.eventCountryCode} number={data.eventContactNumber}
                onCountryCodeChange={(v) => set('eventCountryCode', v)}
                onNumberChange={(v) => set('eventContactNumber', v)}
              />
              <FormField
                label="Point of Contact Name" required
                placeholder="Name of organiser"
                value={data.eventContactName}
                onChange={(e) => set('eventContactName', e.target.value)}
              />
            </div>
            <div className={styles.row2}>
              <FormField
                label="Bike Type / Model"
                placeholder="e.g. 600cc+, Any"
                value={data.bikeTypeModel}
                onChange={(e) => set('bikeTypeModel', e.target.value)}
              />
              <FormSelect
                label="Bike Provision" required
                options={toSelectOptions(BIKE_PROVISION)}
                placeholder="Select"
                value={data.bikeProvision}
                onChange={(e) => set('bikeProvision', e.target.value)}
              />
            </div>
            <FormSelect
              label="Rider Skill Level" required
              options={toSelectOptions(RIDER_SKILL_LEVELS)}
              placeholder="Select level"
              value={data.riderSkillLevel}
              onChange={(e) => set('riderSkillLevel', e.target.value)}
            />
            <div className={styles.row2}>
              <MonthYearPicker
                label="Event Start Date" required
                value={data.eventStartDate}
                onChange={(v) => set('eventStartDate', v)}
                fromYear={new Date().getFullYear()}
                toYear={new Date().getFullYear() + 3}
              />
              <MonthYearPicker
                label="Event End Date" required
                value={data.eventEndDate}
                onChange={(v) => set('eventEndDate', v)}
                fromYear={new Date().getFullYear()}
                toYear={new Date().getFullYear() + 3}
              />
            </div>
            <div className={styles.row2}>
              <FormField
                label="Start Time" required
                type="time"
                value={data.eventStartTime}
                onChange={(e) => set('eventStartTime', e.target.value)}
              />
              <FormField
                label="End Time" required
                type="time"
                value={data.eventEndTime}
                onChange={(e) => set('eventEndTime', e.target.value)}
              />
            </div>
            <FormField
              label="Max Slots" required
              type="number"
              placeholder="e.g. 30"
              value={data.maxSlots}
              onChange={(e) => set('maxSlots', e.target.value)}
            />
            <FormField
              as="textarea" rows={3}
              label="Event Detailed Description" required
              placeholder="Track layout, briefing time, what's included, safety requirements…"
              value={data.eventDescription}
              onChange={(e) => set('eventDescription', e.target.value)}
            />
            <FormField
              label="Google Form / Registration Link"
              placeholder="https://forms.google.com/…"
              value={data.googleFormLink}
              onChange={(e) => set('googleFormLink', e.target.value)}
            />
          </div>
        )}

        {/* ── Step 2 — STANDARD: Location & Hours ──────────────────────── */}
        {step === 2 && isStandard(data.serviceCategory) && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Location &amp; hours</h2>
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
              label="Pin Code" required
              type="number"
              placeholder="6-digit PIN code"
              value={data.pinCode}
              onChange={(e) => set('pinCode', e.target.value)}
            />
            <FormField
              as="textarea" rows={2}
              label="Business Working Days &amp; Hours" required
              placeholder="e.g. Mon–Sat: 9 AM – 7 PM, Sun: Closed"
              value={data.workingHours}
              onChange={(e) => set('workingHours', e.target.value)}
              hint="Describe your working days and opening hours"
            />
          </div>
        )}

        {/* ── Step 2 — EVENT: Location ──────────────────────────────────── */}
        {step === 2 && isEvent(data.serviceCategory) && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Event location</h2>
            <FormField
              label="Location Name" required
              placeholder="e.g. Buddh International Circuit"
              value={data.locationName}
              onChange={(e) => set('locationName', e.target.value)}
            />
            <FormField
              as="textarea" rows={2}
              label="Location Address" required
              placeholder="Full address of the venue"
              value={data.locationAddress}
              onChange={(e) => set('locationAddress', e.target.value)}
            />
            <FormSelect
              label="State" required
              options={toSelectOptions(INDIAN_STATES)}
              placeholder="Select state"
              value={data.state}
              onChange={(e) => set('state', e.target.value)}
            />
            <div className={styles.row2}>
              <FormField
                label="City" required
                placeholder="City"
                value={data.city}
                onChange={(e) => set('city', e.target.value)}
              />
              <FormField
                label="Pin Code"
                type="number"
                placeholder="6-digit PIN code"
                value={data.pinCode}
                onChange={(e) => set('pinCode', e.target.value)}
              />
            </div>
          </div>
        )}

        {/* ── Step 3 — Photos & Preview (all categories) ───────────────── */}
        {step === lastStep && (
          <div className={styles.fields}>
            <h2 className={styles.stepTitle}>Photos &amp; preview</h2>

            {isEvent(data.serviceCategory) ? (
              <PhotoUpload
                label="EVENT PROMO PICTURE"
                maxPhotos={3}
                hint="Upload a banner or promotional image for your event."
              />
            ) : (
              <>
                <PhotoUpload
                  label="BUSINESS PROMO / ADVERTISEMENT PICTURES"
                  maxPhotos={4}
                  hint="Logos, banners, advertisement creatives."
                />
                <PhotoUpload
                  label="SHOP / GARAGE PICTURES"
                  maxPhotos={6}
                  hint="Photos of your workshop, equipment, and work area. Builds trust."
                />
                {isTowing(data.serviceCategory) && (
                  <PhotoUpload
                    label="TOWING VEHICLE PICTURES"
                    maxPhotos={4}
                    hint="Clear photos of your tow trucks and equipment."
                  />
                )}
              </>
            )}

            <div className={styles.divider} />

            <ListingPreview
              name={isEvent(data.serviceCategory) ? data.eventName || 'Your Event' : data.shopName || 'Your Shop'}
              type="service"
              details={[
                { key: 'Type',  value: data.serviceCategory },
                { key: 'City',  value: data.city },
                ...(isEvent(data.serviceCategory) ? [
                  { key: 'Level', value: data.riderSkillLevel },
                  { key: 'Slots', value: data.maxSlots },
                ] : []),
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
                {' '}and confirm all information provided is accurate.
              </span>
            </label>
          </div>
        )}
      </div>

      <WizardFooter
        step={step} totalSteps={steps.length}
        onBack={back} onNext={next}
        isSubmitting={submitting}
        canProceed={step === 0 ? !!data.serviceCategory : (step < lastStep || data.termsAccepted)}
        submitLabel="LIST MY SERVICE"
      />
    </div>
  );
}

/* Category tile icons */
const CAT_ICONS: Record<string, string> = {
  'Find Mechanic':   '🔧',
  'Bike Rentals':    '🏍',
  'Track day':       '🏁',
  'Training day':    '🎓',
  'Accessory Store': '🛒',
  'Tyre Shops':      '⭕',
  'Towing Service':  '🚛',
};
