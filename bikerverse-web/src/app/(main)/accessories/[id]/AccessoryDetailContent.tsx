'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { ImageGallery } from '@/components/detail/ImageGallery';
import { PriceCard } from '@/components/detail/PriceCard';
import { SellerRow } from '@/components/detail/SellerRow';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import { FeaturesGrid } from '@/components/detail/FeaturesGrid';
import { getProductById } from '@/lib/firebase/firestore';
import type { FirestoreProduct } from '@/lib/types';
import styles from './page.module.css';

function formatDate(iso?: string): string {
  if (!iso) return '';
  try {
    const d = new Date(iso);
    return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
  } catch {
    return iso;
  }
}

export function AccessoryDetailContent() {
  const { id } = useParams<{ id: string }>();
  const [product, setProduct] = useState<FirestoreProduct | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (!id) return;
    getProductById(id).then((p) => { setProduct(p); setLoaded(true); });
  }, [id]);

  if (!loaded) return null;
  if (!product) return <div className={styles.page}><p>Item not found.</p></div>;

  const name = `${product.brandName} ${product.modelName}`;
  const imageUrls = product.thumbImageUrls ?? (product.imageUrl ? [product.imageUrl] : []);

  const specsForGrid = [
    { key: 'Category',    value: product.category ?? '' },
    { key: 'Sub-Category', value: product.subCategory ?? '' },
    { key: 'Brand',       value: product.brandName },
    { key: 'Model',       value: product.modelName },
  ].filter((s) => s.value);

  return (
    <div className={styles.page}>
      {product.isSold && (
        <div className={styles.soldBanner}>
          SOLD — This listing is no longer active
        </div>
      )}

      <Breadcrumb items={[
        { label: 'Home',        href: '/'            },
        { label: 'Accessories', href: '/accessories' },
        { label: name                                },
      ]} />

      <div className={styles.hero}>
        <div className={styles.imageCol}>
          <ImageGallery name={name} images={imageUrls} />
        </div>

        <div className={styles.sideCol}>
          <div className={styles.nameBlock}>
            <div className={styles.nameStack}>
              <div className={styles.nameBadgeRow}>
                <h1 className={styles.itemName}>{name}</h1>
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

      <SellerRow
        name={product.sellerName ?? ''}
        city={[product.area, product.city].filter(Boolean).join(', ')}
        verified={false}
        listingCount={0}
        phone={product.sellerContactNumber ?? ''}
        sellerCategory={product.sellerCategory ?? ''}
      />

      <SpecsGrid specs={specsForGrid} title="ITEM SPECIFICATIONS" />

      <FeaturesGrid
        about={product.additionalDetails ?? ''}
        features={[]}
        title="ABOUT THIS ITEM"
      />
    </div>
  );
}
