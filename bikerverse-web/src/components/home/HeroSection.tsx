import { Eyebrow, Btn, Slot, CornerTicks } from '@/components/ds';
import { ArrowRightIcon } from '@/components/ds/Icons';
import styles from './HeroSection.module.css';

/**
 * HeroSection — two-column grid, 1.05fr 1fr.
 * Left: eyebrow + H1 (116px) + paragraph + CTA buttons.
 * Right: 4:5 image slot with gauge-cluster corner ticks.
 */
export function HeroSection() {
  return (
    <section className={styles.section}>
      <div className={styles.grid}>

        {/* ── Left column ───────────────────────────────────────────────── */}
        <div className={styles.copy}>
          <Eyebrow>One-stop hub · India · 2026</Eyebrow>

          <h1 className={styles.h1}>
            EVERY<br />
            BIKER.<br />
            <span className={styles.green}>ONE GARAGE.</span>
          </h1>

          <p className={styles.body}>
            Buy &amp; sell premium pre-owned bikes and accessories. Find trusted mechanics,
            tyre shops and accessory stores. Book track days &amp; training events — all in one place.
          </p>

          <div className={styles.buttons}>
            <Btn
              kind="primary"
              size="lg"
              href="/explore"
              icon={<ArrowRightIcon color="var(--bv-green-ink)" size={14} />}
            >
              Start Exploring
            </Btn>
            <Btn kind="ghost" size="lg" href="/sell/bike">
              List your bike
            </Btn>
          </div>
        </div>

        {/* ── Right column — image + corner ticks ───────────────────────── */}
        <div className={styles.imageWrap}>
          <Slot
            label="Hero bike — Ducati Panigale, ¾ angle, off-black studio bg"
            aspectRatio="4/5"
            className={styles.slot}
          />
          <CornerTicks corners={['tl', 'tr', 'bl', 'br']} offset={8} />
        </div>

      </div>
    </section>
  );
}
