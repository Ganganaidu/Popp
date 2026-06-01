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
  // Identity
  brandName: 'Triumph',
  modelName: 'Street Twin',
  name: 'Triumph Street Twin',
  year: 2022,

  // Pricing
  priceInRupees: 720000,
  negotiable: true,

  // Dates
  mfgDate: 'Jan 2022',
  registrationDate: 'Mar 2022',
  registrationPlace: 'Hyderabad - Telangana',

  // Usage
  kmDriven: 6200,
  firstOwner: '1',          // "1" → "1st Owner"
  invoiceAvailable: 'Yes',
  nocAvailable: 'N/A',

  // Insurance
  insuranceAvailable: 'Yes',
  insuranceValidTill: 'Mar 2025',

  // Condition
  batteryCondition: 'Good',
  tyreCondition: 'Good',

  // Location
  area: 'Jubilee Hills',
  city: 'Hyderabad',
  state: 'Telangana',

  // Seller
  sellerName: 'Ravi Kumar',
  sellerContactNumber: '+91 98491 56789',
  sellerCategory: 'Individual',
  sellerVerified: true,
  sellerListingCount: 3,

  // Status
  isApproved: true,
  isSold: false,
  createdAtDate: '15 Jan 2025',

  // Description
  additionalDetails: `A stunning Matte Khaki Green Street Twin with only 6,200 km on the clock.
Fully stock apart from the touring screen and bar-end mirrors.
Serviced by Triumph authorised dealer in December 2023.
All documents clear, insurance valid till March 2025.
First owner, no accidents, parked in covered garage.`,

  // Technical specs (bike-specific extras)
  fuelType: 'Petrol',
  engine: '900cc Parallel Twin',
  power: '65 bhp @ 7,500 rpm',
  torque: '80 Nm @ 3,800 rpm',
  transmission: '5-speed manual',
  mileage: '18 km/l',
  brakes: 'ABS (dual channel)',
  seatHeight: '790 mm',
  kerbWeight: '198 kg',
  fuelTank: '12 litres',
  colour: 'Matte Khaki Green',
  rto: 'Telangana (TS-09)',

  features: [
    'LED Headlight', 'USB Charging', 'Low Rider Bar', 'Touring Screen',
    'Bar-end Mirrors', 'Fly Screen', 'Heated Grips', 'Tail Tidy',
    'Custom Exhaust', 'Tank Pad', 'Engine Guard', 'Centre Stand',
  ],
};

function ordinalOwner(n: string): string {
  const num = parseInt(n, 10);
  if (isNaN(num)) return n;
  const suffix = num === 1 ? 'st' : num === 2 ? 'nd' : num === 3 ? 'rd' : 'th';
  return `${num}${suffix} Owner`;
}

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function BikeDetailPage({ params }: PageProps) {
  const { id } = await params;
  // In Phase 7 — fetch bike by `id` from Firestore
  const bike = { ...BIKE, id };

  const specsForGrid = [
    { key: 'Brand',               value: bike.brandName },
    { key: 'Model',               value: bike.modelName },
    { key: 'Manufacture Date',    value: bike.mfgDate },
    { key: 'Registration Date',   value: bike.registrationDate },
    { key: 'Registration Place',  value: bike.registrationPlace },
    { key: 'KM Driven',           value: `${bike.kmDriven.toLocaleString('en-IN')} km` },
    { key: 'Ownership',           value: ordinalOwner(bike.firstOwner) },
    { key: 'Invoice Available',   value: bike.invoiceAvailable },
    { key: 'NOC Available',       value: bike.nocAvailable },
    { key: 'Insurance',           value: bike.insuranceAvailable },
    { key: 'Insurance Valid Till', value: bike.insuranceValidTill },
    { key: 'Battery Condition',   value: bike.batteryCondition },
    { key: 'Tyre Condition',      value: bike.tyreCondition },
    { key: 'Fuel Type',           value: bike.fuelType },
    { key: 'Engine',              value: bike.engine },
    { key: 'Power',               value: bike.power },
    { key: 'Torque',              value: bike.torque },
    { key: 'Transmission',        value: bike.transmission },
    { key: 'Mileage',             value: bike.mileage },
    { key: 'Brakes',              value: bike.brakes },
    { key: 'Seat Height',         value: bike.seatHeight },
    { key: 'Kerb Weight',         value: bike.kerbWeight },
    { key: 'Fuel Tank',           value: bike.fuelTank },
    { key: 'Colour',              value: bike.colour },
    { key: 'RTO',                 value: bike.rto },
  ];

  return (
    <div className={styles.page}>
      {/* Sold banner */}
      {bike.isSold && (
        <div className={styles.soldBanner}>
          SOLD — This listing is no longer active
        </div>
      )}

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
            <div className={styles.nameStack}>
              <div className={styles.nameBadgeRow}>
                <h1 className={styles.bikeName}>{bike.name}</h1>
                <span className={styles.bikeYear}>{bike.year}</span>
                {/* Status badges */}
                {bike.isSold && (
                  <span className={`${styles.badge} ${styles.badgeSold}`}>SOLD</span>
                )}
                {!bike.isSold && bike.isApproved && (
                  <span className={`${styles.badge} ${styles.badgeApproved}`}>APPROVED</span>
                )}
                {!bike.isSold && !bike.isApproved && (
                  <span className={`${styles.badge} ${styles.badgePending}`}>PENDING</span>
                )}
              </div>
              <span className={styles.listedOn}>
                Listed on {bike.createdAtDate} · {bike.area}, {bike.city}, {bike.state}
              </span>
            </div>
          </div>

          <PriceCard
            priceInRupees={bike.priceInRupees}
            negotiable={bike.negotiable}
            bikeName={bike.name}
            bikeId={bike.id}
          />
        </div>
      </div>

      {/* Spec strip — 4 key highlights */}
      <SpecStrip
        kmDriven={bike.kmDriven}
        year={bike.year}
        owners={parseInt(bike.firstOwner, 10) || 1}
        insurance={bike.insuranceAvailable === 'Yes' ? `Valid till ${bike.insuranceValidTill}` : 'Not Available'}
      />

      {/* Seller */}
      <SellerRow
        name={bike.sellerName}
        city={`${bike.area}, ${bike.city}`}
        verified={bike.sellerVerified}
        listingCount={bike.sellerListingCount}
        phone={bike.sellerContactNumber}
        sellerCategory={bike.sellerCategory}
      />

      {/* Specs grid — all model fields */}
      <SpecsGrid specs={specsForGrid} />

      {/* Features + About */}
      <FeaturesGrid
        about={bike.additionalDetails}
        features={bike.features}
        title="ABOUT THIS BIKE"
      />
    </div>
  );
}
