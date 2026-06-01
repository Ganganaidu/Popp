'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import styles from './BVCategoryRail.module.css';

const CATEGORIES = [
  { label: 'Premium bikes',          href: '/bikes' },
  { label: 'Protection gear',        href: '/accessories?cat=protection-gear' },
  { label: 'Luggage & accessories',  href: '/accessories?cat=luggage' },
  { label: 'Lights & mounts',        href: '/accessories?cat=lights-mounts' },
  { label: 'Electronic accessories', href: '/accessories?cat=electronics' },
  { label: 'Universal',              href: '/accessories?cat=universal' },
  { label: 'Find mechanic',          href: '/services/mechanics' },
  { label: 'Bike rentals',           href: '/services/bike-rentals' },
  { label: 'Track day',              href: '/services/track-day' },
  { label: 'Training day',           href: '/services/training-day' },
] as const;

/**
 * BVCategoryRail — 44px thin category strip below the top bar.
 * Spec: height 44px, bg --bv-surface-lo, bottom border 1px --bv-border, padding 0 32px.
 * Each link: mono 11px, 0.14em, uppercase, 1px left border (none on first).
 */
export function BVCategoryRail() {
  const pathname = usePathname();

  function isActive(href: string): boolean {
    const base = href.split('?')[0];
    return pathname === base || pathname.startsWith(base + '/');
  }

  return (
    <nav className={styles.rail} aria-label="Category navigation">
      {CATEGORIES.map(({ label, href }, i) => (
        <Link
          key={href}
          href={href}
          className={[
            styles.link,
            i === 0 ? styles.first : '',
            isActive(href) ? styles.active : '',
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {label}
        </Link>
      ))}
    </nav>
  );
}
