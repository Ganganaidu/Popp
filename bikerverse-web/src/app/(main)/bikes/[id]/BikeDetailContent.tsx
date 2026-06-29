'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { ImageGallery } from '@/components/detail/ImageGallery';
import { PriceCard } from '@/components/detail/PriceCard';
import { SpecStrip } from '@/components/detail/SpecStrip';
import { SellerRow } from '@/components/detail/SellerRow';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import { FeaturesGrid } from '@/components/detail/FeaturesGrid';
import { getProductById } from '@/lib/firebase/firestore';
import type { FirestoreProduct } from '@/lib/types';
import styles from './page.module.css';

function ordinalOwner(n: string): string {
  const num = parseInt(n, 10);
  if (isNaN(num)) return n;
  const suffix = num === 1 ? 'st' : num === 2 ? 'nd' : num === 3 ? 'rd' : 'th';
  return `${num}${suffix} Owner`;
}

function formatMonthYear(iso?: string): string {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    return d.toLocaleDateString('en-IN', { month: 'short', year: 'numeric' });
  } catch {
    return iso;
  }
}

function formatDate(iso?: string): string {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
  } catch {
    return iso;
  }
}

export function BikeDetailContent() {
  const { id } = useParams<{ id: string }>();
  const [product, setProduct] = useState<FirestoreProduct | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (!id) return;
    getProductById(id).then((p) => { setProduct(p); setLoaded(true); });
  }, [id]);

  if (!loaded) return null;
  if (!product) return <div className={styles.page}><p>Listing not found.</p></div>;

  const name = `${product.brandName} ${product.modelName}`;
  const year = product.mfgDate ? new Date(product.mfgDate).getFullYear() : '';
  const imageUrls = product.thumbImageUrls ?? (product.imageUrl ? [product.imageUrl] : []);
  const kmDriven = parseInt(product.kmDriven ?? '0', 10) || 0;

  const specsForGrid = [
    { key: 'Brand',               value: product.brandName },
    { key: 'Model',               value: product.modelName },
    { key: 'Manufacture Date',    value: formatMonthYear(product.mfgDate) },
    { key: 'Registration Date',   value: formatMonthYear(product.registrationDate) },
    { key: 'Registration Place',  value: product.registrationPlace ?? '' },
    { key: 'KM Driven',           value: `${kmDriven.toLocaleString('en-IN')} km` },
    { key: 'Ownership',           value: ordinalOwner(product.firstOwner ?? '1') },
    { key: 'Invoice Available',   value: product.invoiceAvailable ?? '' },
    { key: 'NOC Available',       value: product.nocAvailable ?? '' },
    { key: 'Insurance',           value: product.insuranceAvailable ?? '' },
    { key: 'Insurance Valid Till', value: formatMonthYear(product.insuranceValidTill) },
    { key: 'Battery Condition',   value: product.batteryCondition ?? '' },
    { key: 'Tyre Condition',      value: product.tyreCondition ?? '' },
  ].filter((s) => s.value);

  return (
    <div className={styles.page}>
      {product.isSold && (
        <div className={styles.soldBanner}>
          SOLD — This listing is no longer active
        </div>
      )}

      <Breadcrumb items={[
        { label: 'Home',  href: '/'      },
        { label: 'Bikes', href: '/bikes' },
        { label: name                    },
      ]} />

      <div className={styles.hero}>
        <div className={styles.imageCol}>
          <ImageGallery name={name} images={imageUrls} />
        </div>

        <div className={styles.sideCol}>
          <div className={styles.nameBlock}>
            <div className={styles.nameStack}>
              <div className={styles.nameBadgeRow}>
                <h1 className={styles.bikeName}>{name}</h1>
                <span className={styles.bikeYear}>{year}</span>
                {product.isSold && (
                  <span className={`${styles.badge} ${styles.badgeSold}`}>SOLD</span>
                )}
                {!product.isSold && product.isApproved && (
                  <span className={`${styles.badge} ${styles.badgeApproved}`}>APPROVED</span>
                )}
                {!product.isSold && !product.isApproved && (
                  <span className={`${styles.badge} ${styles.badgePending}`}>PENDING</span>
                )}
              </div>
              <span className={styles.listedOn}>
                {product.createdAt ? `Listed on ${formatDate(product.createdAt)} · ` : ''}
                {[product.area, product.city, product.state].filter(Boolean).join(', ')}
              </span>
            </div>
          </div>

          <PriceCard
            priceInRupees={parseFloat(product.expectedPrice) || 0}
            negotiable={false}
            bikeName={name}
            bikeId={id}
          />
        </div>
      </div>

      <SpecStrip
        kmDriven={kmDriven}
        year={year}
        owners={parseInt(product.firstOwner ?? '1', 10) || 1}
        insurance={
          product.insuranceAvailable === 'Yes'
            ? `Valid till ${formatMonthYear(product.insuranceValidTill)}`
            : 'Not Available'
        }
      />

      <SellerRow
        name={product.sellerName ?? ''}
        city={[product.area, product.city].filter(Boolean).join(', ')}
        verified={false}
        listingCount={0}
        phone={product.sellerContactNumber ?? ''}
        sellerCategory={product.sellerCategory ?? ''}
      />

      <SpecsGrid specs={specsForGrid} />

      <FeaturesGrid
        about={product.additionalDetails ?? ''}
        features={[]}
        title="ABOUT THIS BIKE"
      />
    </div>
  );
}
