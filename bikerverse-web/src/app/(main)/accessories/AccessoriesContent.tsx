'use client';

import { useState, useEffect } from 'react';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { GearCard } from '@/components/cards/GearCard';
import { Btn } from '@/components/ds/Btn';
import { getProducts } from '@/lib/firebase/firestore';
import type { FirestoreProduct } from '@/lib/types';
import styles from './page.module.css';

export function AccessoriesContent() {
  const [accessories, setAccessories] = useState<FirestoreProduct[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    getProducts({ lim: 20, category: 'accessory' })
      .then((data) => { setAccessories(data); setLoaded(true); });
  }, []);

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',        href: '/'            },
        { label: 'Accessories'                       },
      ]} />

      <div className={styles.headRow}>
        <h1 className={styles.heading}>
          PROTECTION <span className={styles.accent}>GEAR</span>
        </h1>
        <span className={styles.subCount}>{loaded ? `${accessories.length} listings` : ''}</span>
      </div>

      <div className={styles.grid}>
        {accessories.map((p) => (
          <GearCard
            key={p.id}
            id={p.id}
            name={`${p.brandName} ${p.modelName}`}
            priceInRupees={parseFloat(p.expectedPrice) || 0}
            imageUrl={p.imageUrl || p.thumbImageUrls?.[0]}
          />
        ))}
        {loaded && accessories.length === 0 && <p>No listings found.</p>}
      </div>

      <div className={styles.loadMore}>
        <Btn kind="line" size="md">LOAD MORE</Btn>
      </div>
    </div>
  );
}
