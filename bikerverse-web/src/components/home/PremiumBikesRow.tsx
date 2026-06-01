import { SectionHead } from '@/components/ds/SectionHead';
import { BikeCard } from '@/components/cards/BikeCard';
import styles from './PremiumBikesRow.module.css';

/* Static preview data — matches design handoff exactly */
const BIKES = [
  { name: 'Ducati Panigale V2',       priceInRupees: 1449000, kmDriven: 4700,  city: 'Mumbai',    year: '2021', featured: true  },
  { name: 'Triumph Scrambler 400X',   priceInRupees:  250000, kmDriven: 12400, city: 'Bengaluru', year: '2024', featured: false },
  { name: 'BMW S 1000 RR',            priceInRupees: 2550000, kmDriven: 8200,  city: 'Delhi NCR', year: '2022', featured: false },
  { name: 'Kawasaki Ninja ZX-10R',    priceInRupees: 2070000, kmDriven: 5600,  city: 'Hyderabad', year: '2023', featured: false },
] as const;

/**
 * PremiumBikesRow — 4-column BikeCard grid with section header.
 * In production these would be fetched from Firestore; static for now.
 */
export function PremiumBikesRow() {
  return (
    <section className={styles.section}>
      <SectionHead title="PREMIUM BIKES" trailing="248 LIVE" trailingHref="/bikes" />
      <div className={styles.grid}>
        {BIKES.map((bike, i) => (
          <BikeCard key={i} {...bike} />
        ))}
      </div>
    </section>
  );
}
