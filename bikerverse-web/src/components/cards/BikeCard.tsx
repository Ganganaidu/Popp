'use client';

import Link from 'next/link';
import { Slot } from '@/components/ds/Slot';
import { HeartIcon, PinIcon } from '@/components/ds/Icons';
import styles from './BikeCard.module.css';

export interface BikeCardProps {
  id?: string;
  name: string;
  priceInRupees: number;
  kmDriven: number;
  city: string;
  year: string | number;
  featured?: boolean;
  imageUrl?: string;
  /** Show New badge instead of Featured */
  isNew?: boolean;
}

function formatPrice(n: number): string {
  return n.toLocaleString('en-IN');
}

/**
 * BikeCard — used on Home, Listing, My Listings, Saved.
 * Spec: 4:3 image · featured badge · heart button · name/year row ·
 *       mono price in green · km · city row.
 */
export function BikeCard({
  id,
  name,
  priceInRupees,
  kmDriven,
  city,
  year,
  featured,
  imageUrl,
  isNew,
}: BikeCardProps) {
  const href = id ? `/bikes/${id}` : '#';

  return (
    <Link href={href} className={styles.card}>
      {/* Image zone */}
      <div className={styles.imageWrap}>
        <Slot
          label={`${name} photo`}
          aspectRatio="4/3"
          src={imageUrl}
          alt={name}
          className={styles.image}
        />

        {/* Featured / New badge */}
        {featured && (
          <span className={styles.badge}>Featured</span>
        )}
        {isNew && !featured && (
          <span className={`${styles.badge} ${styles.badgeNew}`}>New</span>
        )}

        {/* Heart */}
        <button
          type="button"
          className={styles.heart}
          aria-label={`Save ${name}`}
          onClick={(e) => {
            e.preventDefault();
            /* Phase 6 — toggle saved state */
          }}
        >
          <HeartIcon color="var(--bv-text)" size={14} />
        </button>
      </div>

      {/* Body */}
      <div className={styles.body}>
        {/* Name + Year */}
        <div className={styles.nameRow}>
          <span className={styles.name}>{name}</span>
          <span className={styles.year}>{year}</span>
        </div>

        {/* Price */}
        <div className={styles.price}>₹ {formatPrice(priceInRupees)}</div>

        {/* KM · City */}
        <div className={styles.meta}>
          <span>{formatPrice(kmDriven)} KM</span>
          <span className={styles.dot}>·</span>
          <span className={styles.city}>
            <PinIcon color="var(--bv-text-3)" size={12} />
            {city}
          </span>
        </div>
      </div>
    </Link>
  );
}
