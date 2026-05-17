import Link from 'next/link';
import { Slot } from '@/components/ds/Slot';
import styles from './GearCard.module.css';

export interface GearCardProps {
  id?: string;
  name: string;
  priceInRupees: number;
  sold?: boolean;
  imageUrl?: string;
}

/**
 * GearCard — 1:1 image, name + price row below.
 * Used in Home gear section and Accessories listing.
 */
export function GearCard({ id, name, priceInRupees, sold, imageUrl }: GearCardProps) {
  const href = id ? `/accessories/${id}` : '#';

  return (
    <Link href={href} className={styles.card}>
      <div className={styles.imageWrap}>
        <Slot
          label={name}
          aspectRatio="1/1"
          src={imageUrl}
          alt={name}
        />
        {sold && <span className={styles.soldBadge}>Sold</span>}
      </div>

      <div className={styles.body}>
        <span className={styles.name}>{name}</span>
        <span className={styles.price}>
          ₹ {priceInRupees.toLocaleString('en-IN')}
        </span>
      </div>
    </Link>
  );
}
