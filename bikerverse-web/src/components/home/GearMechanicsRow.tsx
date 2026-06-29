'use client';

import { useState, useEffect } from 'react';
import { SectionHead } from '@/components/ds/SectionHead';
import { GearCard } from '@/components/cards/GearCard';
import { ShopRow } from '@/components/cards/ShopRow';
import { getProducts, getServices } from '@/lib/firebase/firestore';
import type { FirestoreProduct, FirestoreService } from '@/lib/types';
import styles from './GearMechanicsRow.module.css';

export function GearMechanicsRow() {
  const [accessories, setAccessories] = useState<FirestoreProduct[]>([]);
  const [mechanics, setMechanics] = useState<FirestoreService[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      getProducts({ lim: 2, category: 'accessory' }),
      getServices('mechanics', 3),
    ]).then(([acc, mech]) => {
      setAccessories(acc);
      setMechanics(mech);
      setLoaded(true);
    });
  }, []);

  return (
    <section className={styles.section}>
      {/* Left — Protection Gear */}
      <div>
        <SectionHead title="PROTECTION GEAR" trailing="VIEW ALL" trailingHref="/accessories" />
        <div className={styles.gearGrid}>
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
      </div>

      {/* Right — Trusted Mechanics */}
      <div>
        <SectionHead title="TRUSTED MECHANICS" trailing="FIND NEAR ME" trailingHref="/services/mechanics" />
        <div className={styles.shopList}>
          {mechanics.map((s) => (
            <ShopRow
              key={s.id}
              id={s.id}
              name={s.businessTitle ?? ''}
              city={[s.area, s.city].filter(Boolean).join(', ')}
              rating={s.rating ?? '—'}
              tags={(s.tags ?? []) as string[]}
              category="mechanics"
              imageUrl={s.promoImageUrls?.[0] || s.shopImageUrls?.[0]}
            />
          ))}
          {loaded && mechanics.length === 0 && <p>No listings found.</p>}
        </div>
      </div>
    </section>
  );
}
