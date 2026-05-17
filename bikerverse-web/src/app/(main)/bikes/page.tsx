import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { FilterBar } from '@/components/listing/FilterBar';
import { BikeCard } from '@/components/cards/BikeCard';
import { Btn } from '@/components/ds/Btn';
import styles from './page.module.css';

export const metadata: Metadata = {
  title: 'Premium Bikes — Bikerverse',
  description: 'Browse pre-owned premium motorcycles across India. Filter by brand, budget, KM driven and more.',
};

/* Static seed data — 8 cards matching the handoff */
const BIKES = [
  { id: '1', name: 'Royal Enfield Interceptor',  priceInRupees: 180000, kmDriven: 14200, city: 'Bengaluru', year: 2022, featured: true  },
  { id: '2', name: 'KTM 390 Duke',               priceInRupees: 255000, kmDriven: 8500,  city: 'Pune',      year: 2023, isNew: true     },
  { id: '3', name: 'Kawasaki Ninja 650',          priceInRupees: 540000, kmDriven: 12000, city: 'Mumbai',    year: 2021               },
  { id: '4', name: 'Honda CB500F',                priceInRupees: 320000, kmDriven: 9800,  city: 'Delhi',     year: 2022               },
  { id: '5', name: 'Triumph Street Twin',         priceInRupees: 720000, kmDriven: 6200,  city: 'Hyderabad', year: 2022, featured: true  },
  { id: '6', name: 'Bajaj Dominar 400',           priceInRupees: 195000, kmDriven: 22000, city: 'Chennai',   year: 2020               },
  { id: '7', name: 'Ducati Monster 797',          priceInRupees: 890000, kmDriven: 5400,  city: 'Bengaluru', year: 2021               },
  { id: '8', name: 'Harley-Davidson Iron 883',    priceInRupees: 980000, kmDriven: 7800,  city: 'Mumbai',    year: 2020               },
] as const;

export default function BikesPage() {
  return (
    <>
      <FilterBar count={240} />

      <div className={styles.page}>
        <Breadcrumb items={[
          { label: 'Home', href: '/' },
          { label: 'Bikes' },
        ]} />

        <div className={styles.headRow}>
          <h1 className={styles.heading}>
            PREMIUM <span className={styles.accent}>BIKES</span>
          </h1>
          <span className={styles.subCount}>240 listings</span>
        </div>

        {/* 4-column grid */}
        <div className={styles.grid}>
          {BIKES.map((bike) => (
            <BikeCard key={bike.id} {...bike} />
          ))}
        </div>

        {/* Load more */}
        <div className={styles.loadMore}>
          <Btn kind="line" size="md">
            LOAD 240 MORE
          </Btn>
        </div>
      </div>
    </>
  );
}
