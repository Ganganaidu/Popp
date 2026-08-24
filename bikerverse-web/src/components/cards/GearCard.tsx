import Link from 'next/link';
import { Slot } from '@/components/ds/Slot';
import { HeartIcon } from '@/components/ds/Icons';
import styles from './GearCard.module.css';

export interface GearCardProps {
  id?: string;
  name: string;
  priceInRupees: number;
  sold?: boolean;
  imageUrl?: string;
  subCategory?: string;
}

export function GearCard({ id, name, priceInRupees, sold, imageUrl, subCategory }: GearCardProps) {
  const href = id ? `/accessories/${id}` : '#';

  return (
    <Link href={href} className={styles.card}>
      <div className={styles.imageWrap}>
        <Slot label={name} aspectRatio="4/3" src={imageUrl} alt={name} />
        {sold && <span className={styles.soldBadge}>Sold</span>}
        <button
          type="button"
          className={styles.heart}
          aria-label={`Save ${name}`}
          onClick={(e) => { e.preventDefault(); }}
        >
          <HeartIcon color="var(--bv-text)" size={14} />
        </button>
      </div>

      <div className={styles.body}>
        <span className={styles.name}>{name}</span>
        <div className={styles.price}>₹ {priceInRupees.toLocaleString('en-IN')}</div>
        {subCategory && <div className={styles.meta}>{subCategory}</div>}
      </div>
    </Link>
  );
}
