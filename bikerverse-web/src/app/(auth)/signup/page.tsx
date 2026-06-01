'use client';

import { useState, type FormEvent } from 'react';
import Link from 'next/link';
import { FormField } from '@/components/forms/FormField';
import { FormSelect } from '@/components/forms/FormSelect';
import { MonthYearPicker } from '@/components/forms/MonthYearPicker';
import { PhoneField } from '@/components/forms/PhoneField';
import { Btn } from '@/components/ds/Btn';
import { BIKE_BRANDS, BIKE_MODELS, INDIAN_STATES, toSelectOptions } from '@/lib/data/bikeData';
import styles from './page.module.css';

/* ── Eye icons ──────────────────────────────────────────────────────────────── */
function EyeIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

function EyeOffIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94" />
      <path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19" />
      <line x1="1" y1="1" x2="23" y2="23" />
    </svg>
  );
}

/* ── Types ──────────────────────────────────────────────────────────────────── */
interface BikeSlot {
  id: number;
  brand: string;
  model: string;
  monthYear: { month: string; year: string };
}

/* ── Placeholder Firebase stub ──────────────────────────────────────────────── */
async function createAccount(_data: Record<string, unknown>): Promise<void> {
  // TODO Phase 7: wire to src/lib/firebase/auth.ts
  await new Promise((r) => setTimeout(r, 800));
}

/* ── Component ──────────────────────────────────────────────────────────────── */
export default function SignupPage() {
  // Core fields
  const [username, setUsername]       = useState('');
  const [email, setEmail]             = useState('');
  const [phoneCode, setPhoneCode]     = useState('+91');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword]       = useState('');
  const [confirmPass, setConfirmPass] = useState('');
  const [showPass, setShowPass]       = useState(false);
  const [showConf, setShowConf]       = useState(false);

  // Address fields
  const [address, setAddress]   = useState('');
  const [area, setArea]         = useState('');
  const [city, setCity]         = useState('');
  const [pinCode, setPinCode]   = useState('');
  const [state, setState]       = useState('');

  // Bike data (up to 3 slots)
  const [bikes, setBikes] = useState<BikeSlot[]>([]);

  // Terms & submit
  const [terms, setTerms]     = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError]     = useState('');
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});

  /* ── Bike slot helpers ──────────────────────────────────────────────────── */
  function addBike() {
    if (bikes.length >= 3) return;
    setBikes((prev) => [
      ...prev,
      { id: Date.now(), brand: '', model: '', monthYear: { month: '', year: '' } },
    ]);
  }

  function removeBike(id: number) {
    setBikes((prev) => prev.filter((b) => b.id !== id));
  }

  function updateBike(id: number, patch: Partial<BikeSlot>) {
    setBikes((prev) =>
      prev.map((b) => (b.id === id ? { ...b, ...patch } : b))
    );
  }

  /* ── Validation ─────────────────────────────────────────────────────────── */
  function validate(): boolean {
    const errs: Record<string, string> = {};

    if (!username.trim()) errs.username = 'Username is required';
    if (!email.trim()) errs.email = 'Email is required';
    if (!phoneNumber.trim()) errs.phone = 'Phone number is required';
    if (!password) errs.password = 'Password is required';
    if (!confirmPass) errs.confirmPass = 'Please confirm your password';
    else if (password !== confirmPass) errs.confirmPass = 'Passwords do not match';
    if (!address.trim()) errs.address = 'Address is required';
    if (!area.trim()) errs.area = 'Area is required';
    if (!city.trim()) errs.city = 'City is required';
    if (!terms) errs.terms = 'You must accept the terms to continue';

    setFieldErrors(errs);
    return Object.keys(errs).length === 0;
  }

  /* ── Submit ─────────────────────────────────────────────────────────────── */
  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    if (!validate()) return;

    setLoading(true);
    try {
      await createAccount({
        username, email, phone: `${phoneCode}${phoneNumber}`, password,
        address, area, city, pinCode, state,
        bikes: bikes.filter((b) => b.brand),
      });
      // TODO Phase 7: redirect to home / onboarding
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Account creation failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  const brandOptions = toSelectOptions(BIKE_BRANDS);
  const stateOptions = toSelectOptions(INDIAN_STATES);

  return (
    <>
      <div className={styles.eyebrow}>Join the community</div>
      <h1 className={styles.heading}>CREATE ACCOUNT</h1>

      <form className={styles.form} onSubmit={handleSubmit} noValidate>
        {error && <div className={styles.errorBanner} role="alert">{error}</div>}

        {/* ── Personal Info ─────────────────────────────────────────────────── */}
        <FormField
          label="Username"
          type="text"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          placeholder="yourhandle"
          autoComplete="username"
          required
          error={fieldErrors.username}
        />

        <FormField
          label="Email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
          autoComplete="email"
          required
          error={fieldErrors.email}
        />

        <PhoneField
          label="Phone Number"
          countryCode={phoneCode}
          number={phoneNumber}
          onCountryCodeChange={setPhoneCode}
          onNumberChange={setPhoneNumber}
          required
          hint={fieldErrors.phone}
        />

        {/* Password */}
        <div className={styles.passwordWrap}>
          <FormField
            label="Password"
            type={showPass ? 'text' : 'password'}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            autoComplete="new-password"
            required
            error={fieldErrors.password}
            className={styles.passwordInput}
          />
          <button
            type="button"
            className={styles.passwordToggle}
            onClick={() => setShowPass((v) => !v)}
            aria-label={showPass ? 'Hide password' : 'Show password'}
            tabIndex={-1}
          >
            {showPass ? <EyeOffIcon /> : <EyeIcon />}
          </button>
        </div>

        {/* Confirm Password */}
        <div className={styles.passwordWrap}>
          <FormField
            label="Confirm Password"
            type={showConf ? 'text' : 'password'}
            value={confirmPass}
            onChange={(e) => setConfirmPass(e.target.value)}
            placeholder="••••••••"
            autoComplete="new-password"
            required
            error={fieldErrors.confirmPass}
            className={styles.passwordInput}
          />
          <button
            type="button"
            className={styles.passwordToggle}
            onClick={() => setShowConf((v) => !v)}
            aria-label={showConf ? 'Hide confirm password' : 'Show confirm password'}
            tabIndex={-1}
          >
            {showConf ? <EyeOffIcon /> : <EyeIcon />}
          </button>
        </div>

        <hr className={styles.divider} />

        {/* ── Address ──────────────────────────────────────────────────────── */}
        <div className={styles.sectionLabel}>Address</div>

        <FormField
          label="Address"
          type="text"
          value={address}
          onChange={(e) => setAddress(e.target.value)}
          placeholder="Street / flat / building"
          required
          error={fieldErrors.address}
        />

        <FormField
          label="Area"
          type="text"
          value={area}
          onChange={(e) => setArea(e.target.value)}
          placeholder="Locality / area"
          required
          error={fieldErrors.area}
        />

        <FormField
          label="City"
          type="text"
          value={city}
          onChange={(e) => setCity(e.target.value)}
          placeholder="City"
          required
          error={fieldErrors.city}
        />

        <FormField
          label="Pin Code"
          type="number"
          value={pinCode}
          onChange={(e) => setPinCode(e.target.value)}
          placeholder="6-digit pin"
          inputMode="numeric"
        />

        <FormSelect
          label="State"
          value={state}
          onChange={(e) => setState(e.target.value)}
          options={stateOptions}
          placeholder="Select state"
        />

        <hr className={styles.divider} />

        {/* ── Bike Data ────────────────────────────────────────────────────── */}
        <div className={styles.sectionLabel}>Your Bikes (optional)</div>

        {bikes.map((bike, idx) => (
          <div key={bike.id} className={styles.bikeSlot}>
            <div className={styles.bikeSlotHeader}>
              <span className={styles.bikeSlotTitle}>Bike {idx + 1}</span>
              {idx > 0 && (
                <button
                  type="button"
                  className={styles.removeBtn}
                  onClick={() => removeBike(bike.id)}
                  aria-label={`Remove bike ${idx + 1}`}
                >
                  ×
                </button>
              )}
            </div>

            <FormSelect
              label="Bike Brand"
              value={bike.brand}
              onChange={(e) => updateBike(bike.id, { brand: e.target.value, model: '' })}
              options={brandOptions}
              placeholder="Select brand"
            />

            <FormSelect
              label="Bike Model"
              value={bike.model}
              onChange={(e) => updateBike(bike.id, { model: e.target.value })}
              options={bike.brand ? toSelectOptions(BIKE_MODELS[bike.brand] ?? []) : []}
              placeholder={bike.brand ? 'Select model' : 'Select brand first'}
              disabled={!bike.brand}
            />

            <MonthYearPicker
              label="Purchase Month / Year"
              value={bike.monthYear}
              onChange={(v) => updateBike(bike.id, { monthYear: v })}
            />
          </div>
        ))}

        {bikes.length < 3 && (
          <Btn type="button" kind="ghost" size="sm" onClick={addBike}>
            + ADD {bikes.length === 0 ? 'A' : 'ANOTHER'} BIKE
          </Btn>
        )}

        <hr className={styles.divider} />

        {/* ── Terms ────────────────────────────────────────────────────────── */}
        <div>
          <label className={styles.checkboxLabel}>
            <input
              type="checkbox"
              checked={terms}
              onChange={(e) => setTerms(e.target.checked)}
            />
            I agree to the{' '}
            <a href="/terms" className={styles.termsLink} target="_blank" rel="noopener noreferrer">
              Terms &amp; Conditions
            </a>{' '}
            and{' '}
            <a href="/privacy" className={styles.termsLink} target="_blank" rel="noopener noreferrer">
              Privacy Policy
            </a>
          </label>
          {fieldErrors.terms && (
            <div className={styles.termsError} role="alert">{fieldErrors.terms}</div>
          )}
        </div>

        <Btn type="submit" kind="primary" size="lg" fullWidth disabled={loading}>
          {loading ? 'CREATING ACCOUNT…' : 'CREATE ACCOUNT'}
        </Btn>
      </form>

      <p className={styles.footer} style={{ marginTop: 24 }}>
        Already have an account?{' '}
        <Link href="/login" className={styles.footerLink}>Sign in</Link>
      </p>
    </>
  );
}
