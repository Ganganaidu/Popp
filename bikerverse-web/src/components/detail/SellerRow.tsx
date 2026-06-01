'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Btn } from '@/components/ds/Btn';
import styles from './SellerRow.module.css';

interface SellerRowProps {
  name: string;
  city: string;
  verified?: boolean;
  sellerId?: string;
  listingCount?: number;
  phone?: string;
  sellerCategory?: string;
}

function initials(name: string): string {
  return name
    .split(' ')
    .slice(0, 2)
    .map((w) => w[0])
    .join('')
    .toUpperCase();
}

/**
 * SellerRow — surface-lo card.
 * Left: 44×44 green initials tile.
 * Center: name + verified badge + city + seller category.
 * Right: "CALL SELLER" ghost button (toggles phone number) + "VIEW STORE" line button.
 */
export function SellerRow({
  name,
  city,
  verified = true,
  sellerId,
  listingCount,
  phone,
  sellerCategory,
}: SellerRowProps) {
  const storeHref = sellerId ? `/store/${sellerId}` : '#';
  const [showPhone, setShowPhone] = useState(false);

  return (
    <div className={styles.row}>
      {/* Avatar */}
      <div className={styles.avatar}>{initials(name)}</div>

      {/* Info */}
      <div className={styles.info}>
        <div className={styles.nameRow}>
          <span className={styles.name}>{name}</span>
          {verified && <span className={styles.verified}>✓ VERIFIED</span>}
          {sellerCategory && (
            <span className={styles.sellerCategory}>{sellerCategory.toUpperCase()}</span>
          )}
        </div>
        <span className={styles.city}>{city}</span>
        {listingCount !== undefined && (
          <span className={styles.count}>{listingCount} active listings</span>
        )}
      </div>

      {/* Actions */}
      <div className={styles.actions}>
        {phone && (
          showPhone ? (
            <span className={styles.phoneNumber}>{phone}</span>
          ) : (
            <Btn kind="ghost" size="sm" onClick={() => setShowPhone(true)}>
              CALL SELLER
            </Btn>
          )
        )}
        <Btn kind="line" size="sm" href={storeHref}>
          VIEW STORE
        </Btn>
      </div>
    </div>
  );
}
