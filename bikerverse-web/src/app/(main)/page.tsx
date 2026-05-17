import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Bikerverse — One-stop hub for riders in India',
};

/**
 * Home page — Phase 2 will implement the full design (hero, testimonials carousel,
 * action grid, premium bikes row, gear + mechanics two-up).
 * Placeholder rendered so the layout chrome is visible during Phase 1.
 */
export default function HomePage() {
  return (
    <div style={{ padding: '56px 32px', color: 'var(--bv-text)' }}>
      <p
        style={{
          fontFamily: 'var(--font-jetbrains-mono)',
          fontSize: 11,
          letterSpacing: '0.18em',
          textTransform: 'uppercase',
          color: 'var(--bv-green)',
          marginBottom: 16,
        }}
      >
        Phase 1 complete · Design system loaded
      </p>
      <h1
        style={{
          fontFamily: 'var(--font-archivo-narrow)',
          fontWeight: 800,
          fontSize: 116,
          lineHeight: 0.92,
          letterSpacing: '-0.035em',
          textTransform: 'uppercase',
        }}
      >
        EVERY<br />
        BIKER.<br />
        <span style={{ color: 'var(--bv-green)' }}>ONE GARAGE.</span>
      </h1>
      <p
        style={{
          fontFamily: 'var(--font-archivo)',
          fontSize: 17,
          lineHeight: 1.55,
          color: 'var(--bv-text-2)',
          maxWidth: 540,
          marginTop: 28,
        }}
      >
        Buy &amp; sell premium pre-owned bikes and accessories. Find trusted mechanics,
        tyre shops and accessory stores. Book track days &amp; training events — all in one place.
      </p>
    </div>
  );
}
