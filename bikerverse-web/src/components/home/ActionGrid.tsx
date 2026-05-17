import Link from 'next/link';
import { Eyebrow } from '@/components/ds/Eyebrow';
import { ArrowRightIcon } from '@/components/ds/Icons';
import styles from './ActionGrid.module.css';

const TILES = [
  { verb: 'Sell',  noun: 'Bike',       n: '01', href: '/sell/bike',                featured: true  },
  { verb: 'Sell',  noun: 'Accessory',  n: '02', href: '/sell/accessory',           featured: false },
  { verb: 'List',  noun: 'Business',   n: '03', href: '/list-service',             featured: false },
  { verb: 'Find',  noun: 'Mechanic',   n: '04', href: '/services/mechanics',       featured: false },
  { verb: 'Book',  noun: 'Track day',  n: '05', href: '/services/track-day',       featured: false },
  { verb: 'Rent',  noun: 'Super bike', n: '06', href: '/services/bike-rentals',    featured: false },
] as const;

/**
 * ActionGrid — "Pick a Lane" 6-column tile grid.
 * First tile is featured: lime fill, green-ink text.
 * Others: surface bg with border.
 * Spec: verb in Archivo Narrow 800 38px, noun in Archivo 14px 0.7 opacity.
 */
export function ActionGrid() {
  return (
    <section className={styles.section}>
      {/* Header */}
      <div className={styles.header}>
        <div>
          <Eyebrow>Would you like to</Eyebrow>
          <h2 className={styles.h2}>PICK A LANE</h2>
        </div>
        <span className={styles.label}>SIX WAYS IN</span>
      </div>

      {/* 6-column grid */}
      <div className={styles.grid}>
        {TILES.map(({ verb, noun, n, href, featured }) => (
          <Link
            key={n}
            href={href}
            className={[styles.tile, featured ? styles.tileFeatured : ''].join(' ')}
          >
            {/* Index label */}
            <span className={styles.index}>/{n}</span>

            {/* Verb — large display type */}
            <span className={styles.verb}>{verb}</span>

            {/* Noun — body sans */}
            <span className={styles.noun}>{noun}</span>

            {/* Arrow bottom-right */}
            <span className={styles.arrow} aria-hidden>
              <ArrowRightIcon
                color={featured ? 'var(--bv-green-ink)' : 'var(--bv-text-2)'}
                size={14}
              />
            </span>
          </Link>
        ))}
      </div>
    </section>
  );
}
