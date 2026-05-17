import { SectionHead } from '@/components/ds/SectionHead';
import { GearCard } from '@/components/cards/GearCard';
import { ShopRow } from '@/components/cards/ShopRow';
import styles from './GearMechanicsRow.module.css';

/* Static data — verbatim from design handoff §4.2.E */
const GEAR = [
  { name: 'Korda Modular Helmet',   priceInRupees: 3000 },
  { name: 'Kawasaki Riding Jacket', priceInRupees: 7000 },
] as const;

const MECHANICS = [
  { name: 'Weekendmech Pvt Ltd',   city: 'Jubilee Hills, Hyderabad',  rating: '4.9', tags: ['Akrapovic', 'Ducati', 'Triumph'] },
  { name: 'GarageOne Performance', city: 'Andheri West, Mumbai',      rating: '4.8', tags: ['ECU tune', 'Suspension'] },
  { name: "Apex Riders' Garage",   city: 'Indiranagar, Bengaluru',    rating: '4.7', tags: ['Track prep', 'Race fairings'] },
] as const;

/**
 * GearMechanicsRow — two-column split.
 * Left: 2-col GearCard grid.   Right: stacked ShopRow list.
 */
export function GearMechanicsRow() {
  return (
    <section className={styles.section}>
      {/* Left — Protection Gear */}
      <div>
        <SectionHead title="PROTECTION GEAR" trailing="VIEW ALL" trailingHref="/accessories" />
        <div className={styles.gearGrid}>
          {GEAR.map((g, i) => (
            <GearCard key={i} {...g} />
          ))}
        </div>
      </div>

      {/* Right — Trusted Mechanics */}
      <div>
        <SectionHead title="TRUSTED MECHANICS" trailing="FIND NEAR ME" trailingHref="/services/mechanics" />
        <div className={styles.shopList}>
          {MECHANICS.map((m, i) => (
            <ShopRow key={i} {...m} />
          ))}
        </div>
      </div>
    </section>
  );
}
