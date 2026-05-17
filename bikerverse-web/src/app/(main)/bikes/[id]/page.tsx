import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { ImageGallery } from '@/components/detail/ImageGallery';
import { PriceCard } from '@/components/detail/PriceCard';
import { SpecStrip } from '@/components/detail/SpecStrip';
import { SellerRow } from '@/components/detail/SellerRow';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import { FeaturesGrid } from '@/components/detail/FeaturesGrid';
import styles from './page.module.css';

export const metadata: Metadata = {
  title: 'Triumph Street Twin 2022 — Bikerverse',
};

/* Seed data — replaced by dynamic fetch in Phase 7 */
const BIKE = {
  id: '5',
  name: 'Triumph Street Twin',
  year: 2022,
  priceInRupees: 720000,
  negotiable: true,
  kmDriven: 6200,
  owners: 1,
  insurance: 'Valid till 2025',
  city: 'Jubilee Hills, Hyderabad',
  seller: { name: 'Ravi Kumar',  city: 'Hyderabad', verified: true, listingCount: 3 },
  specs: [
    { key: 'Engine',        value: '900cc Parallel Twin' },
    { key: 'Power',         value: '65 bhp @ 7,500 rpm'  },
    { key: 'Torque',        value: '80 Nm @ 3,800 rpm'   },
    { key: 'Transmission',  value: '5-speed manual'       },
    { key: 'Fuel',          value: 'Petrol'               },
    { key: 'Mileage',       value: '18 km/l'              },
    { key: 'Brakes',        value: 'ABS (dual channel)'   },
    { key: 'Seat Height',   value: '790 mm'               },
    { key: 'Kerb Weight',   value: '198 kg'               },
    { key: 'Fuel Tank',     value: '12 litres'            },
    { key: 'Colour',        value: 'Matte Khaki Green'    },
    { key: 'RTO',           value: 'Telangana (TS-09)'    },
  ],
  features: [
    'LED Headlight', 'USB Charging', 'Low Rider Bar', 'Touring Screen',
    'Bar-end Mirrors', 'Fly Screen', 'Heated Grips', 'Tail Tidy',
    'Custom Exhaust', 'Tank Pad', 'Engine Guard', 'Centre Stand',
  ],
  about: `A stunning Matte Khaki Green Street Twin with only 6,200 km on the clock.
    Fully stock apart from the touring screen and bar-end mirrors.
    Serviced by Triumph authorised dealer in December 2023.
    All documents clear, insurance valid till March 2025.
    First owner, no accidents, parked in covered garage.`,
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function BikeDetailPage({ params }: PageProps) {
  const { id } = await params;
  // In Phase 7 — fetch bike by `id` from Firestore
  const bike = { ...BIKE, id };

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',  href: '/'      },
        { label: 'Bikes', href: '/bikes' },
        { label: bike.name              },
      ]} />

      {/* Hero grid: image left, price card right */}
      <div className={styles.hero}>
        <div className={styles.imageCol}>
          <ImageGallery name={bike.name} />
        </div>

        <div className={styles.sideCol}>
          <div className={styles.nameBlock}>
            <h1 className={styles.bikeName}>{bike.name}</h1>
            <span className={styles.bikeYear}>{bike.year}</span>
          </div>

          <PriceCard
            priceInRupees={bike.priceInRupees}
            negotiable={bike.negotiable}
            bikeName={bike.name}
            bikeId={bike.id}
          />
        </div>
      </div>

      {/* Spec strip */}
      <SpecStrip
        kmDriven={bike.kmDriven}
        year={bike.year}
        owners={bike.owners}
        insurance={bike.insurance}
      />

      {/* Seller */}
      <SellerRow
        name={bike.seller.name}
        city={bike.seller.city}
        verified={bike.seller.verified}
        listingCount={bike.seller.listingCount}
      />

      {/* Specs grid */}
      <SpecsGrid specs={bike.specs} />

      {/* Features + About */}
      <FeaturesGrid
        about={bike.about}
        features={bike.features}
      />
    </div>
  );
}
