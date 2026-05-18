'use client';

import { useState, type FormEvent } from 'react';
import Link from 'next/link';
import { FormField } from '@/components/forms/FormField';
import { Btn } from '@/components/ds/Btn';
import styles from './page.module.css';

/* ── Eye icon SVGs ──────────────────────────────────────────────────────────── */
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

/* ── Placeholder Firebase stub ──────────────────────────────────────────────── */
async function signInWithEmailPassword(_email: string, _password: string): Promise<void> {
  // TODO Phase 7: wire to src/lib/firebase/auth.ts
  await new Promise((r) => setTimeout(r, 600));
  // throw new Error('Invalid credentials'); // uncomment to test error state
}

/* ── Component ──────────────────────────────────────────────────────────────── */
export default function LoginPage() {
  const [email, setEmail]           = useState('');
  const [password, setPassword]     = useState('');
  const [showPass, setShowPass]     = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [loading, setLoading]       = useState(false);
  const [error, setError]           = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await signInWithEmailPassword(email, password);
      // TODO Phase 7: redirect to home or previous route
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Sign in failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <div className={styles.eyebrow}>Welcome back</div>
      <h1 className={styles.heading}>SIGN IN</h1>

      <form className={styles.form} onSubmit={handleSubmit} noValidate>
        {error && <div className={styles.errorBanner} role="alert">{error}</div>}

        <FormField
          label="Email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
          autoComplete="email"
          required
        />

        <div>
          <div className={styles.passwordWrap}>
            <FormField
              label="Password"
              type={showPass ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              autoComplete="current-password"
              required
              className={styles.passwordInput}
            />
            <button
              type="button"
              className={styles.passwordToggle}
              onClick={() => setShowPass((v) => !v)}
              aria-label={showPass ? 'Hide password' : 'Show password'}
              tabIndex={-1}
              style={{ bottom: 0, top: 'auto', transform: 'none', marginBottom: 2 }}
            >
              {showPass ? <EyeOffIcon /> : <EyeIcon />}
            </button>
          </div>
        </div>

        <div className={styles.row}>
          <label className={styles.checkboxLabel}>
            <input
              type="checkbox"
              checked={rememberMe}
              onChange={(e) => setRememberMe(e.target.checked)}
            />
            Remember me
          </label>
          <Link href="/forgot-password" className={styles.forgotLink}>
            Forgot password?
          </Link>
        </div>

        <Btn type="submit" kind="primary" size="lg" fullWidth disabled={loading}>
          {loading ? 'SIGNING IN…' : 'SIGN IN'}
        </Btn>
      </form>

      <p className={styles.footer} style={{ marginTop: 24 }}>
        Don&apos;t have an account?{' '}
        <Link href="/signup" className={styles.footerLink}>Sign up</Link>
      </p>
    </>
  );
}
