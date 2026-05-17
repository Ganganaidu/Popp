import Link from 'next/link';
import { Slot } from '@/components/ds/Slot';
import { PinIcon } from '@/components/ds/Icons';
import styles from './ShopRow.module.css';

export interface ShopRowProps {
  id?: string;
  name: string;
  city: string;
  rating: string | number;
  tags: readonly string[];
  category?: string;
  imageUrl?: string;
}

/**
 * ShopRow — 88×88 image left, name + rating + location + tag chips right.
 * Used in Home mechanics section and Service listing pages.
 */
export function ShopRow({ id, name, city, rating, tags, category = 'mechanics', imageUrl }: ShopRowProps) {
  const href = id ? `/services/${category}/${id}` : '#';

  return (
    <Link href={href} className={styles.row}>
      {/* Thumbnail */}
      <div className={styles.thumb}>
        <Slot label={name} aspectRatio="1/1" src={imageUrl} alt={name} style={{ width: 88, height: 88 }} />
      </div>

      {/* Content */}
      <div className={styles.content}>
        <div className={styles.topRow}>
          <span className={styles.name}>{name}</span>
          <span className={styles.rating}>★ {rating}</span>
        </div>

        <div className={styles.location}>
          <PinIcon color="var(--bv-text-3)" size={12} />
          {city}
        </div>

        <div className={styles.tags}>
          {tags.map((tag) => (
            <span key={tag} className={styles.tag}>{tag}</span>
          ))}
        </div>
      </div>
    </Link>
  );
}
