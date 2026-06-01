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

  // Category
  category: 'Accessories',
  subcategory: 'Helmet',

  // Condition & size
  productCondition: 'Like New',
  productSize: 'L (59-60 cm)',
  productAging: '8',          // months

  // Brand
  brand: 'Arai',
  model: 'RX-7V',

  // Bike compatibility
  isProductBikeSpecific: false,
  bikeBrandName: '',
  bikeModelName: '',
  bikeMfgDate: '',

  // Bill / warranty
  billAvailable: 'Yes',
  billDate: 'Jan 2023',
  warrantyLimit: 'Mar 2024',

  // Location
  area: 'Koregaon Park',
  city: 'Pune',
  state: 'Maharashtra',

  // Seller
  sellerName: 'Priya Sharma',
  sellerContactNumber: '+91 98765 43210',
  sellerCategory: 'Individual',
  sellerVerified: true,
  sellerListingCount: 2,

  // Status
  isApproved: true,
  isSold: false,
  createdAtDate: '10 Feb 2025',

  // Description
  additionalDetails: `Purchased new in January 2023. Used for weekend track days only — never crashed.
Comes with original bag, clear and dark tinted visors, spare pinlock lens,
and all internal padding. Shell has zero scratches. Interior freshly washed.
Reason for selling: upgraded to Arai CK-6 for track.`,

  features: [
    'FIA 8860-2010', 'SNELL M2015', 'ECE 22.05', 'Anti-fog ready',
    'Includes bag', 'Two visors', 'Winter liner', 'Pinlock fitted',
  ],
};

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function AccessoryDetailPage({ params }: PageProps) {
  const { id } = await params;
  const item = { ...ACCESSORY, id };

  const specsForGrid = [
    { key: 'Category',        value: item.category },
    { key: 'Sub-Category',    value: item.subcategory },
    { key: 'Brand',           value: item.brand },
    { key: 'Model',           value: item.model },
    { key: 'Condition',       value: item.productCondition },
    { key: 'Size',            value: item.productSize },
    { key: 'Usage',           value: `${item.productAging} months` },
    { key: 'Bill Available',  value: item.billAvailable },
    { key: 'Bill Date',       value: item.billDate },
    { key: 'Warranty Limit',  value: item.warrantyLimit },
  ];

  const compatSpecsForGrid = item.isProductBikeSpecific
    ? [
        { key: 'Bike Brand', value: item.bikeBrandName },
        { key: 'Bike Model', value: item.bikeModelName },
        { key: 'Bike Year',  value: item.bikeMfgDate },
      ]
    : [];

  return (
    <div className={styles.page}>
      {/* Sold banner */}
      {item.isSold && (
        <div className={styles.soldBanner}>
          SOLD — This listing is no longer active
        </div>
      )}

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
            <div className={styles.nameStack}>
              <div className={styles.nameBadgeRow}>
                <h1 className={styles.itemName}>{item.name}</h1>
                {item.isSold && (
                  <span className={`${styles.badge} ${styles.badgeSold}`}>SOLD</span>
                )}
                {!item.isSold && item.isApproved && (
                  <span className={`${styles.badge} ${styles.badgeApproved}`}>APPROVED</span>
                )}
                {!item.isSold && !item.isApproved && (
                  <span className={`${styles.badge} ${styles.badgePending}`}>PENDING</span>
                )}
              </div>
              <span className={styles.listedOn}>
                Listed on {item.createdAtDate} · {item.area}, {item.city}, {item.state}
              </span>
            </div>
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
        name={item.sellerName}
        city={`${item.area}, ${item.city}`}
        verified={item.sellerVerified}
        listingCount={item.sellerListingCount}
        phone={item.sellerContactNumber}
        sellerCategory={item.sellerCategory}
      />

      <SpecsGrid specs={specsForGrid} title="ITEM SPECIFICATIONS" />

      {/* Compatible bike — only shown when isProductBikeSpecific */}
      {item.isProductBikeSpecific && compatSpecsForGrid.length > 0 && (
        <SpecsGrid specs={compatSpecsForGrid} title="COMPATIBLE WITH" />
      )}

      <FeaturesGrid
        about={item.additionalDetails}
        features={item.features}
        title="ABOUT THIS ITEM"
      />
    </div>
  );
}
