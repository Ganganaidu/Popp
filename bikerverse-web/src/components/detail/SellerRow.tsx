import Link from 'next/link';
import { Btn } from '@/components/ds/Btn';
import styles from './SellerRow.module.css';

interface SellerRowProps {
  name: string;
  city: string;
  verified?: boolean;
  sellerId?: string;
  listingCount?: number;
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
 * Center: name + verified badge + city.
 * Right: "View Store" line button.
 */
export function SellerRow({ name, city, verified = true, sellerId, listingCount }: SellerRowProps) {
  const storeHref = sellerId ? `/store/${sellerId}` : '#';

  return (
    <div className={styles.row}>
      {/* Avatar */}
      <div className={styles.avatar}>{initials(name)}</div>

      {/* Info */}
      <div className={styles.info}>
        <div className={styles.nameRow}>
          <span className={styles.name}>{name}</span>
          {verified && <span className={styles.verified}>✓ VERIFIED</span>}
        </div>
        <span className={styles.city}>{city}</span>
        {listingCount !== undefined && (
          <span className={styles.count}>{listingCount} active listings</span>
        )}
      </div>

      {/* View store */}
      <Btn kind="line" size="sm" href={storeHref}>
        VIEW STORE
      </Btn>
    </div>
  );
}
