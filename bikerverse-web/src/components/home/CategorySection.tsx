'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { ArrowRightIcon } from '@/components/ds/Icons';
import { BikeCard } from '@/components/cards/BikeCard';
import { GearCard } from '@/components/cards/GearCard';
import { getProducts } from '@/lib/firebase/firestore';
import type { FirestoreProduct } from '@/lib/types';
import styles from './CategorySection.module.css';

interface CategorySectionProps {
  categoryName: string;
  viewAllHref: string;
  limit?: number;
}

export function CategorySection({ categoryName, viewAllHref, limit = 4 }: CategorySectionProps) {
  const [products, setProducts] = useState<FirestoreProduct[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    getProducts({ lim: limit, category: categoryName }).then((p) => {
      setProducts(p);
      setLoaded(true);
    });
  }, [categoryName, limit]);

  if (loaded && products.length === 0) return null;

  const isBikes = categoryName === 'Premium Bikes';

  return (
    <section className={styles.section}>
      <div className={styles.header}>
        <div className={styles.titleWrap}>
          <h2 className={styles.title}>{categoryName.toUpperCase()}</h2>
          <div className={styles.accent} aria-hidden />
        </div>
        <Link href={viewAllHref} className={styles.viewAll}>
          VIEW ALL
          <ArrowRightIcon color="var(--bv-green)" size={12} />
        </Link>
      </div>

      <div className={styles.grid}>
        {products.map((p) =>
          isBikes ? (
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
          ) : (
            <GearCard
              key={p.id}
              id={p.id}
              name={`${p.brandName} ${p.modelName}`}
              priceInRupees={parseFloat(p.expectedPrice) || 0}
              imageUrl={p.imageUrl || p.thumbImageUrls?.[0]}
              subCategory={p.subCategory}
            />
          )
        )}
      </div>
    </section>
  );
}
