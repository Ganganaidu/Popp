'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { ShopRow } from '@/components/cards/ShopRow';
import { Btn } from '@/components/ds/Btn';
import { getServices } from '@/lib/firebase/firestore';
import type { FirestoreService } from '@/lib/types';
import styles from './page.module.css';

const CATEGORY_LABELS: Record<string, string> = {
  mechanics:          'TRUSTED MECHANICS',
  'bike-rentals':     'BIKE RENTALS',
  'track-day':        'TRACK DAYS',
  'training-day':     'TRAINING DAYS',
  'accessory-store':  'ACCESSORY STORES',
  'tyre-shops':       'TYRE SHOPS',
  towing:             'TOWING SERVICES',
  inspection:         'PREMIUM INSPECTION',
};

export function ServiceListContent() {
  const { category } = useParams<{ category: string }>();
  const [shops, setShops] = useState<FirestoreService[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (!category) return;
    getServices(category, 20).then((data) => { setShops(data); setLoaded(true); });
  }, [category]);

  const label = CATEGORY_LABELS[category] ?? (category ?? '').replace(/-/g, ' ').toUpperCase();
  const words = label.split(' ');

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',     href: '/'          },
        { label: 'Services'                     },
        { label: label                          },
      ]} />

      <h1 className={styles.heading}>
        {words.map((w, i) => (
          i === words.length - 1
            ? <span key={i} className={styles.accent}>{w} </span>
            : <span key={i}>{w} </span>
        ))}
      </h1>

      <div className={styles.list}>
        {shops.map((s) => (
          <ShopRow
            key={s.id}
            id={s.id}
            name={s.businessTitle ?? ''}
            city={[s.area, s.city].filter(Boolean).join(', ')}
            rating={s.rating ?? '—'}
            tags={(s.tags ?? []) as string[]}
            category={category}
            imageUrl={s.promoImageUrls?.[0] || s.shopImageUrls?.[0]}
          />
        ))}
        {loaded && shops.length === 0 && <p>No listings found.</p>}
      </div>

      <div className={styles.loadMore}>
        <Btn kind="line" size="md">LOAD MORE</Btn>
      </div>
    </div>
  );
}
