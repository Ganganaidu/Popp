'use client';

import { useState } from 'react';
import { BikeCard } from '@/components/cards/BikeCard';
import { GearCard } from '@/components/cards/GearCard';
import { ShopRow } from '@/components/cards/ShopRow';
import { Btn } from '@/components/ds/Btn';
import styles from './page.module.css';

type ListingStatus = 'APPROVED' | 'PENDING' | 'REJECTED' | 'SOLD';

interface BikeListingItem {
  type: 'bike';
  id: string;
  status: ListingStatus;
  name: string;
  priceInRupees: number;
  kmDriven: number;
  city: string;
  year: string | number;
  imageUrl?: string;
}

interface GearListingItem {
  type: 'gear';
  id: string;
  status: ListingStatus;
  name: string;
  priceInRupees: number;
  imageUrl?: string;
}

interface ServiceListingItem {
  id: string;
  status: ListingStatus;
  name: string;
  city: string;
  rating: string | number;
  tags: string[];
  category?: string;
  imageUrl?: string;
}

type ProductItem = BikeListingItem | GearListingItem;

const SEED_PRODUCTS: ProductItem[] = [
  {
    type: 'bike',
    id: 'b1',
    status: 'APPROVED',
    name: 'Royal Enfield Himalayan 450',
    priceInRupees: 285000,
    kmDriven: 8200,
    city: 'Bengaluru',
    year: 2022,
  },
  {
    type: 'bike',
    id: 'b2',
    status: 'PENDING',
    name: 'KTM Duke 390',
    priceInRupees: 195000,
    kmDriven: 14500,
    city: 'Mumbai',
    year: 2021,
  },
  {
    type: 'gear',
    id: 'g1',
    status: 'APPROVED',
    name: 'Touratech Pannier Set',
    priceInRupees: 18500,
  },
  {
    type: 'gear',
    id: 'g2',
    status: 'REJECTED',
    name: 'Shoei NXR2 Helmet',
    priceInRupees: 42000,
  },
];

const SEED_SERVICES: ServiceListingItem[] = [
  {
    id: 's1',
    status: 'APPROVED',
    name: "Rajan's Motorcycle Workshop",
    city: 'Bengaluru',
    rating: '4.8',
    tags: ['Service', 'Repair', 'Royal Enfield'],
    category: 'mechanics',
  },
  {
    id: 's2',
    status: 'PENDING',
    name: 'Moto Wrap Studio',
    city: 'Pune',
    rating: '4.5',
    tags: ['Wrapping', 'Paint', 'Customisation'],
    category: 'customisation',
  },
];

const STATUS_LABELS: Record<ListingStatus, string> = {
  APPROVED: 'APPROVED',
  PENDING: 'PENDING',
  REJECTED: 'REJECTED',
  SOLD: 'SOLD',
};

function StatusBadge({ status }: { status: ListingStatus }) {
  return (
    <span className={`${styles.badge} ${styles[`badge_${status}`]}`}>
      {STATUS_LABELS[status]}
    </span>
  );
}

type Tab = 'products' | 'services';

export default function ListingsPage() {
  const [tab, setTab] = useState<Tab>('products');
  const [products, setProducts] = useState<ProductItem[]>(SEED_PRODUCTS);
  const [services, setServices] = useState<ServiceListingItem[]>(SEED_SERVICES);

  function deleteProduct(id: string) {
    setProducts((prev) => prev.filter((p) => p.id !== id));
  }

  function deleteService(id: string) {
    setServices((prev) => prev.filter((s) => s.id !== id));
  }

  return (
    <div className={styles.page}>
      <h1 className={styles.heading}>
        MY <span className={styles.green}>LISTINGS</span>
      </h1>

      {/* Tabs */}
      <div className={styles.tabs} role="tablist">
        <button
          role="tab"
          aria-selected={tab === 'products'}
          className={`${styles.tab} ${tab === 'products' ? styles.tabActive : ''}`}
          onClick={() => setTab('products')}
        >
          PRODUCTS
        </button>
        <button
          role="tab"
          aria-selected={tab === 'services'}
          className={`${styles.tab} ${tab === 'services' ? styles.tabActive : ''}`}
          onClick={() => setTab('services')}
        >
          SERVICES
        </button>
      </div>

      {/* Products tab */}
      {tab === 'products' && (
        <>
          {products.length === 0 ? (
            <div className={styles.empty}>
              <p className={styles.emptyMsg}>No listings yet</p>
              <Btn href="/sell/bike" kind="primary" size="sm">
                SELL YOUR BIKE
              </Btn>
            </div>
          ) : (
            <div className={styles.grid}>
              {products.map((item) => (
                <div key={item.id} className={styles.cardWrap}>
                  <div className={styles.statusRow}>
                    <StatusBadge status={item.status} />
                  </div>

                  {item.type === 'bike' ? (
                    <BikeCard
                      id={item.id}
                      name={item.name}
                      priceInRupees={item.priceInRupees}
                      kmDriven={item.kmDriven}
                      city={item.city}
                      year={item.year}
                      imageUrl={item.imageUrl}
                    />
                  ) : (
                    <GearCard
                      id={item.id}
                      name={item.name}
                      priceInRupees={item.priceInRupees}
                      imageUrl={item.imageUrl}
                    />
                  )}

                  <div className={styles.actions}>
                    <Btn
                      kind="ghost"
                      size="sm"
                      href={`/sell/edit/${item.id}`}
                    >
                      EDIT
                    </Btn>
                    <Btn
                      kind="ghost"
                      size="sm"
                      onClick={() => deleteProduct(item.id)}
                      className={styles.deleteAction}
                    >
                      DELETE
                    </Btn>
                  </div>
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {/* Services tab */}
      {tab === 'services' && (
        <>
          {services.length === 0 ? (
            <div className={styles.empty}>
              <p className={styles.emptyMsg}>No listings yet</p>
              <Btn href="/services/list" kind="primary" size="sm">
                LIST A SERVICE
              </Btn>
            </div>
          ) : (
            <div className={styles.serviceList}>
              {services.map((svc) => (
                <div key={svc.id} className={styles.serviceWrap}>
                  <div className={styles.statusRow}>
                    <StatusBadge status={svc.status} />
                  </div>
                  <ShopRow
                    id={svc.id}
                    name={svc.name}
                    city={svc.city}
                    rating={svc.rating}
                    tags={svc.tags}
                    category={svc.category}
                    imageUrl={svc.imageUrl}
                  />
                  <div className={styles.actions}>
                    <Btn
                      kind="ghost"
                      size="sm"
                      href={`/services/edit/${svc.id}`}
                    >
                      EDIT
                    </Btn>
                    <Btn
                      kind="ghost"
                      size="sm"
                      onClick={() => deleteService(svc.id)}
                      className={styles.deleteAction}
                    >
                      DELETE
                    </Btn>
                  </div>
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}
