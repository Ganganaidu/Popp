'use client';

import { useState, useEffect } from 'react';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { FilterBar } from '@/components/listing/FilterBar';
import { BikeCard } from '@/components/cards/BikeCard';
import { Btn } from '@/components/ds/Btn';
import { getProducts } from '@/lib/firebase/firestore';
import type { FirestoreProduct } from '@/lib/types';
import styles from './page.module.css';

export function BikesContent() {
  const [bikes, setBikes] = useState<FirestoreProduct[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    getProducts({ lim: 20, category: 'Premium Bikes' })
      .then((data) => { setBikes(data); setLoaded(true); });
  }, []);

  return (
    <>
      <FilterBar count={bikes.length} />

      <div className={styles.page}>
        <Breadcrumb items={[
          { label: 'Home', href: '/' },
          { label: 'Bikes' },
        ]} />

        <div className={styles.headRow}>
          <h1 className={styles.heading}>
            PREMIUM <span className={styles.accent}>BIKES</span>
          </h1>
          <span className={styles.subCount}>{loaded ? `${bikes.length} listings` : ''}</span>
        </div>

        <div className={styles.grid}>
          {bikes.map((p) => (
            <BikeCard
              key={p.id}
              id={p.id}
              name={`${p.brandName} ${p.modelName}`}
              priceInRupees={parseFloat(p.expectedPrice) || 0}
              kmDriven={parseInt(p.kmDriven ?? '0', 10) || 0}
              city={p.city}
              year={p.mfgDate ? new Date(p.mfgDate).getFullYear() : ''}
              imageUrl={p.imageUrl || p.thumbImageUrls?.[0]}
            />
          ))}
          {loaded && bikes.length === 0 && <p>No listings found.</p>}
        </div>

        <div className={styles.loadMore}>
          <Btn kind="line" size="md">LOAD MORE</Btn>
        </div>
      </div>
    </>
  );
}
