import type { Metadata } from 'next';
export const metadata: Metadata = { title: 'Sign up' };
export default function Page() {
  return (
    <div style={{ padding: '40px 32px', color: 'var(--bv-text)' }}>
      <h1 style={{ fontFamily: 'var(--font-archivo-narrow)', fontWeight: 800, fontSize: 56, letterSpacing: '-0.025em', textTransform: 'uppercase', marginBottom: 16 }}>CREATE ACCOUNT</h1>
      <p style={{ fontFamily: 'var(--font-jetbrains-mono)', fontSize: 11, letterSpacing: '0.14em', color: 'var(--bv-text-3)', textTransform: 'uppercase' }}>Signup form — coming in next phase</p>
    </div>
  );
}
