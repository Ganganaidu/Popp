'use client';

import { useState, useEffect } from 'react';
import { SectionHead } from '@/components/ds/SectionHead';
import { BikeCard } from '@/components/cards/BikeCard';
import { getProducts } from '@/lib/firebase/firestore';
import type { FirestoreProduct } from '@/lib/types';
import styles from './PremiumBikesRow.module.css';

export function PremiumBikesRow() {
  const [products, setProducts] = useState<FirestoreProduct[]>([]);

  useEffect(() => {
    getProducts({ lim: 4, category: 'Premium Bikes' }).then(setProducts);
  }, []);

  return (
    <section className={styles.section}>
      <SectionHead
        title="PREMIUM BIKES"
        trailing={products.length ? `${products.length} LIVE` : ''}
        trailingHref="/bikes"
      />
      <div className={styles.grid}>
        {products.map((p) => (
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
      </div>
    </section>
  );
}
