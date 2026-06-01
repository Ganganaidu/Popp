import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { GearCard } from '@/components/cards/GearCard';
import { Btn } from '@/components/ds/Btn';
import styles from './page.module.css';

export const metadata: Metadata = {
  title: 'Accessories & Gear — Bikerverse',
  description: 'Shop pre-owned riding gear, helmets, jackets and accessories from trusted sellers.',
};

const ACCESSORIES = [
  { id: 'a1', name: 'Arai RX-7V Helmet',         priceInRupees: 45000  },
  { id: 'a2', name: 'Alpinestars GP Pro Gloves',  priceInRupees: 8500   },
  { id: 'a3', name: 'Dainese D-Air Jacket',       priceInRupees: 68000  },
  { id: 'a4', name: "REV'IT Apex Boots",           priceInRupees: 22000  },
  { id: 'a5', name: 'Korda Modular Helmet',       priceInRupees: 3000   },
  { id: 'a6', name: 'Kawasaki Riding Jacket',     priceInRupees: 7000   },
  { id: 'a7', name: 'Shoei GT-Air II',            priceInRupees: 38000  },
  { id: 'a8', name: 'Tucano Urbano Back Protector', priceInRupees: 4200 },
] as const;

export default function AccessoriesPage() {
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
        <span className={styles.subCount}>128 listings</span>
      </div>

      <div className={styles.grid}>
        {ACCESSORIES.map((item) => (
          <GearCard key={item.id} {...item} />
        ))}
      </div>

      <div className={styles.loadMore}>
        <Btn kind="line" size="md">LOAD MORE</Btn>
      </div>
    </div>
  );
}
