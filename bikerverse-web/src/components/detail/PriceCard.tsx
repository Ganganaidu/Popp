'use client';

import { useState } from 'react';
import { HeartIcon, HeartFilledIcon, ChatIcon } from '@/components/ds/Icons';
import { Btn } from '@/components/ds/Btn';
import styles from './PriceCard.module.css';

interface PriceCardProps {
  priceInRupees: number;
  negotiable?: boolean;
  bikeId?: string;
  bikeName: string;
}

function formatPrice(n: number): string {
  return n.toLocaleString('en-IN');
}

/**
 * PriceCard — sticky right column on bike detail.
 * 56px Archivo Narrow 800 green price + NEGOTIABLE label.
 * Three CTAs: Chat, Make Offer (primary), Heart (icon).
 */
export function PriceCard({ priceInRupees, negotiable = true, bikeName }: PriceCardProps) {
  const [saved, setSaved] = useState(false);

  return (
    <div className={styles.card}>
      {/* Price */}
      <div className={styles.priceRow}>
        <span className={styles.currency}>₹</span>
        <span className={styles.price}>{formatPrice(priceInRupees)}</span>
      </div>

      {negotiable && (
        <span className={styles.negotiable}>NEGOTIABLE</span>
      )}

      {/* CTAs */}
      <div className={styles.ctas}>
        <Btn kind="ghost" size="md" icon={<ChatIcon size={16} color="var(--bv-text-2)" />}>
          CHAT
        </Btn>
        <Btn kind="primary" size="md" style={{ flex: 1 }}>
          MAKE OFFER
        </Btn>
        <button
          type="button"
          className={[styles.heartBtn, saved ? styles.heartSaved : ''].filter(Boolean).join(' ')}
          aria-label={saved ? `Unsave ${bikeName}` : `Save ${bikeName}`}
          onClick={() => setSaved((s) => !s)}
        >
          {saved
            ? <HeartFilledIcon size={18} color="var(--bv-green)" />
            : <HeartIcon size={18} color="var(--bv-text-2)" />
          }
        </button>
      </div>

      {/* Fine print */}
      <p className={styles.fine}>
        Price is indicative. Verify with seller before transfer.
      </p>
    </div>
  );
}
