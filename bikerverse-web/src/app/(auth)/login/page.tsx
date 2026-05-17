import type { Metadata } from 'next';
import { Eyebrow } from '@/components/ds';

export const metadata: Metadata = { title: 'Sign in' };

export default function LoginPage() {
  return (
    <>
      <Eyebrow style={{ marginBottom: 8 }}>Welcome back</Eyebrow>
      <h1
        style={{
          fontFamily: 'var(--font-archivo-narrow)',
          fontWeight: 800,
          fontSize: 32,
          letterSpacing: '-0.02em',
          textTransform: 'uppercase',
          color: 'var(--bv-text)',
          marginBottom: 32,
        }}
      >
        SIGN IN
      </h1>
      <p style={{ color: 'var(--bv-text-3)', fontSize: 13 }}>
        Login form — Phase 5
      </p>
    </>
  );
}
