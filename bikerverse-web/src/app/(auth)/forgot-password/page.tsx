'use client';

import { useState, type FormEvent } from 'react';
import Link from 'next/link';
import { FormField } from '@/components/forms/FormField';
import { Btn } from '@/components/ds/Btn';
import { resetPassword } from '@/lib/firebase/auth';
import styles from './page.module.css';

/* ── Component ──────────────────────────────────────────────────────────────── */
export default function ForgotPasswordPage() {
  const [email, setEmail]   = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError]   = useState('');
  const [sent, setSent]     = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await resetPassword(email);
      setSent(true);
    } catch (err: unknown) {
      const code = (err as { code?: string })?.code ?? '';
      if (code === 'auth/user-not-found' || code === 'auth/invalid-email') {
        setError('No account found with that email address.');
      } else {
        setError('Failed to send reset link. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  }

  if (sent) {
    return (
      <div className={styles.successBox}>
        <div className={styles.successIcon} aria-hidden>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
            <polyline points="20 6 9 17 4 12" />
          </svg>
        </div>
        <h1 className={styles.successHeading}>Check your email</h1>
        <p className={styles.successText}>
          We&apos;ve sent a password reset link to <strong style={{ color: 'var(--bv-text)' }}>{email}</strong>.
          Check your inbox and follow the instructions.
        </p>
        <Btn href="/login" kind="primary" size="md" fullWidth>
          BACK TO SIGN IN
        </Btn>
      </div>
    );
  }

  return (
    <>
      <div className={styles.eyebrow}>Account recovery</div>
      <h1 className={styles.heading}>RESET PASSWORD</h1>
      <p className={styles.subtext}>
        Enter your email address and we&apos;ll send you a link to reset your password.
      </p>

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

        <Btn type="submit" kind="primary" size="lg" fullWidth disabled={loading}>
          {loading ? 'SENDING…' : 'SEND RESET LINK'}
        </Btn>
      </form>

      <p className={styles.footer} style={{ marginTop: 24 }}>
        <Link href="/login" className={styles.footerLink}>Back to sign in</Link>
      </p>
    </>
  );
}
