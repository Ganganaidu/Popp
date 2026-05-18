import Link from 'next/link';
import Image from 'next/image';
import { Eyebrow } from '@/components/ds/Eyebrow';
import styles from './ActionGrid.module.css';

/**
 * Colors sourced directly from Flutter's pop_service_item.dart.
 * Non-featured tiles: card uses a dark tint of the base colour.
 * Featured (first) tile: bright var(--bv-green) fill.
 */
const TILES = [
  {
    verb: 'SELL',
    noun: 'Bike',
    n: '01',
    href: '/sell/bike',
    image: '/assets/actions/sell_your_bike.png',
    color: null, // featured — uses CSS var(--bv-green)
    featured: true,
  },
  {
    verb: 'SELL',
    noun: 'Accessory',
    n: '02',
    href: '/sell/accessory',
    image: '/assets/actions/sell_your_accessory.png',
    color: '#1565C0',  // Flutter: Blue
    featured: false,
  },
  {
    verb: 'LIST',
    noun: 'Business',
    n: '03',
    href: '/list-service',
    image: '/assets/actions/list_your_business.png',
    color: '#6A0DAD',  // Flutter: Purple (0xFF9006E3 darkened)
    featured: false,
  },
  {
    verb: 'FIND',
    noun: 'Mechanic',
    n: '04',
    href: '/services/mechanics',
    image: '/assets/actions/find_mechanic.png',
    color: '#BF360C',  // Flutter: Deep Orange (0xFFD84315)
    featured: false,
  },
  {
    verb: 'BOOK',
    noun: 'Track day',
    n: '05',
    href: '/services/track-day',
    image: '/assets/actions/track_training_day.png',
    color: '#B71C1C',  // Flutter: Red (0xFFC62828)
    featured: false,
  },
  {
    verb: 'RENT',
    noun: 'Super bike',
    n: '06',
    href: '/services/bike-rentals',
    image: '/assets/actions/bike_rentals.png',
    color: '#37474F',  // Flutter: Blue Grey (0xFF455A64)
    featured: false,
  },
] as const;

export function ActionGrid() {
  return (
    <section className={styles.section}>
      {/* Header */}
      <div className={styles.header}>
        <Eyebrow>Would you like to</Eyebrow>
        <span className={styles.label}>SIX WAYS IN</span>
      </div>

      {/* 6-column grid */}
      <div className={styles.grid}>
        {TILES.map(({ verb, noun, n, href, image, color, featured }) => (
          <Link
            key={n}
            href={href}
            className={[styles.tile, featured ? styles.tileFeatured : ''].join(' ')}
            style={!featured && color ? { '--tile-color': color } as React.CSSProperties : undefined}
          >
            {/* Top row: index + arrow */}
            <div className={styles.topRow}>
              <span className={styles.index}>/{n}</span>
              <span className={styles.arrow} aria-hidden>→</span>
            </div>

            {/* Image — centred in the card body */}
            <div className={styles.imageWrap}>
              <Image
                src={image}
                alt={`${verb} ${noun}`}
                fill
                sizes="(max-width: 600px) 50vw, (max-width: 1024px) 33vw, 16vw"
                className={styles.image}
              />
            </div>

            {/* Bottom gradient overlay */}
            <div className={styles.gradient} aria-hidden />

            {/* Text — pinned to bottom */}
            <div className={styles.textBlock}>
              <span className={styles.verb}>{verb}</span>
              <span className={styles.noun}>{noun}</span>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
