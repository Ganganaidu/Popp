'use client';

import { useState, type FormEvent } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { FormField } from '@/components/forms/FormField';
import { PasswordField } from '@/components/forms/PasswordField';
import { Btn } from '@/components/ds/Btn';
import { signIn } from '@/lib/firebase/auth';
import styles from './page.module.css';

function mapAuthError(code: string): string {
  switch (code) {
    case 'auth/invalid-credential':
    case 'auth/user-not-found':
    case 'auth/wrong-password':
      return 'Email or password is incorrect.';
    case 'auth/too-many-requests':
      return 'Too many failed attempts. Please try again later.';
    case 'auth/user-disabled':
      return 'This account has been disabled.';
    default:
      return 'Sign in failed. Please try again.';
  }
}

/* ── Component ──────────────────────────────────────────────────────────────── */
export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail]           = useState('');
  const [password, setPassword]     = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [loading, setLoading]       = useState(false);
  const [error, setError]           = useState('');

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await signIn(email, password);
      router.push('/');
    } catch (err: unknown) {
      const code = (err as { code?: string })?.code ?? '';
      setError(mapAuthError(code));
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

        <PasswordField
          label="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="••••••••"
          autoComplete="current-password"
          required
        />

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
