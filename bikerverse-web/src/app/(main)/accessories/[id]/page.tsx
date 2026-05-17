import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { ImageGallery } from '@/components/detail/ImageGallery';
import { PriceCard } from '@/components/detail/PriceCard';
import { SellerRow } from '@/components/detail/SellerRow';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import { FeaturesGrid } from '@/components/detail/FeaturesGrid';
import styles from './page.module.css';

export const metadata: Metadata = {
  title: 'Arai RX-7V Helmet — Bikerverse',
};

const ACCESSORY = {
  id: 'a1',
  name: 'Arai RX-7V Helmet',
  priceInRupees: 45000,
  negotiable: false,
  condition: 'Like New',
  usageMonths: 8,
  size: 'L (59-60 cm)',
  seller: { name: 'Priya Sharma', city: 'Pune', verified: true, listingCount: 2 },
  specs: [
    { key: 'Brand',      value: 'Arai'                   },
    { key: 'Model',      value: 'RX-7V'                  },
    { key: 'Type',       value: 'Full Face'               },
    { key: 'Size',       value: 'L (59-60 cm)'           },
    { key: 'Shell',      value: 'PB-cLc (fibreglass)'    },
    { key: 'Weight',     value: '≈ 1,450 g'              },
    { key: 'Visor',      value: 'VAS-V (anti-fog ready)' },
    { key: 'Condition',  value: 'Like New'               },
    { key: 'Usage',      value: '8 months'               },
    { key: 'Colour',     value: 'Solid Black'            },
  ],
  features: [
    'FIA 8860-2010', 'SNELL M2015', 'ECE 22.05', 'Anti-fog ready',
    'Includes bag', 'Two visors', 'Winter liner', 'Pinlock fitted',
  ],
  about: `Purchased new in January 2023. Used for weekend track days only — never crashed.
    Comes with original bag, clear and dark tinted visors, spare pinlock lens,
    and all internal padding. Shell has zero scratches. Interior freshly washed.
    Reason for selling: upgraded to Arai CK-6 for track.`,
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function AccessoryDetailPage({ params }: PageProps) {
  const { id } = await params;
  const item = { ...ACCESSORY, id };

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',        href: '/'            },
        { label: 'Accessories', href: '/accessories' },
        { label: item.name                           },
      ]} />

      <div className={styles.hero}>
        <div className={styles.imageCol}>
          <ImageGallery name={item.name} />
        </div>

        <div className={styles.sideCol}>
          <div className={styles.nameBlock}>
            <h1 className={styles.itemName}>{item.name}</h1>
          </div>
          <PriceCard
            priceInRupees={item.priceInRupees}
            negotiable={item.negotiable}
            bikeName={item.name}
            bikeId={item.id}
          />
        </div>
      </div>

      <SellerRow
        name={item.seller.name}
        city={item.seller.city}
        verified={item.seller.verified}
        listingCount={item.seller.listingCount}
      />

      <SpecsGrid specs={item.specs} title="ITEM SPECIFICATIONS" />

      <FeaturesGrid
        about={item.about}
        features={item.features}
        title="ABOUT THIS ITEM"
      />
    </div>
  );
}
