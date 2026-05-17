import type { Metadata } from 'next';
export const metadata: Metadata = { title: 'Admin' };
export default function Page() {
  return (
    <div style={{ padding: '40px 32px', color: 'var(--bv-text)' }}>
      <h1 style={{ fontFamily: 'var(--font-archivo-narrow)', fontWeight: 800, fontSize: 56, letterSpacing: '-0.025em', textTransform: 'uppercase', marginBottom: 16 }}>ADMIN DASHBOARD</h1>
      <p style={{ fontFamily: 'var(--font-jetbrains-mono)', fontSize: 11, letterSpacing: '0.14em', color: 'var(--bv-text-3)', textTransform: 'uppercase' }}>Admin dashboard — coming in next phase</p>
    </div>
  );
}
