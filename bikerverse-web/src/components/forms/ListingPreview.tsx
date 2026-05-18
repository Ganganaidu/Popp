import { Slot } from '@/components/ds/Slot';
import styles from './ListingPreview.module.css';

interface ListingPreviewProps {
  name: string;
  priceInRupees?: number;
  details: { key: string; value: string }[];
  photoUrl?: string;
  type?: 'bike' | 'accessory' | 'service';
}

function fmt(n: number) { return n.toLocaleString('en-IN'); }

/**
 * ListingPreview — a card that shows the user how their listing will look.
 * Used on the final "Preview" step of all three wizards.
 */
export function ListingPreview({ name, priceInRupees, details, photoUrl, type = 'bike' }: ListingPreviewProps) {
  return (
    <div className={styles.wrap}>
      <p className={styles.tag}>LISTING PREVIEW</p>

      <div className={styles.card}>
        {/* Image */}
        <div className={styles.imageWrap}>
          <Slot
            label={`${name} preview`}
            aspectRatio={type === 'service' ? '16/9' : '4/3'}
            src={photoUrl}
            alt={name}
            className={styles.image}
          />
        </div>

        {/* Body */}
        <div className={styles.body}>
          <span className={styles.name}>{name || '—'}</span>

          {priceInRupees !== undefined && priceInRupees > 0 && (
            <span className={styles.price}>₹ {fmt(priceInRupees)}</span>
          )}

          <div className={styles.details}>
            {details.filter((d) => d.value).map((d) => (
              <div key={d.key} className={styles.detailRow}>
                <span className={styles.detailKey}>{d.key}</span>
                <span className={styles.detailVal}>{d.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <p className={styles.note}>
        This is how your listing will appear to buyers. You can edit it after publishing.
      </p>
    </div>
  );
}
