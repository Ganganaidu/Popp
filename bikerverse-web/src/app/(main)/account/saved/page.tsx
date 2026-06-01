'use client';

import { useState } from 'react';
import { BikeCard } from '@/components/cards/BikeCard';
import { GearCard } from '@/components/cards/GearCard';
import { ShopRow } from '@/components/cards/ShopRow';
import { Btn } from '@/components/ds/Btn';
import styles from './page.module.css';

interface SavedBike {
  type: 'bike';
  id: string;
  name: string;
  priceInRupees: number;
  kmDriven: number;
  city: string;
  year: string | number;
  imageUrl?: string;
}

interface SavedGear {
  type: 'gear';
  id: string;
  name: string;
  priceInRupees: number;
  imageUrl?: string;
}

interface SavedService {
  id: string;
  name: string;
  city: string;
  rating: string | number;
  tags: string[];
  category?: string;
  imageUrl?: string;
}

type SavedProduct = SavedBike | SavedGear;

const SEED_PRODUCTS: SavedProduct[] = [
  {
    type: 'bike',
    id: 'b10',
    name: 'Honda CB650R',
    priceInRupees: 920000,
    kmDriven: 3100,
    city: 'Delhi',
    year: 2023,
  },
  {
    type: 'bike',
    id: 'b11',
    name: 'Royal Enfield Continental GT 650',
    priceInRupees: 335000,
    kmDriven: 9800,
    city: 'Chennai',
    year: 2021,
  },
  {
    type: 'gear',
    id: 'g10',
    name: 'Alpinestars SMX-6 Boots',
    priceInRupees: 22000,
  },
  {
    type: 'gear',
    id: 'g11',
    name: "Rev'it Tornado 3 Jacket",
    priceInRupees: 31500,
  },
];

const SEED_SERVICES: SavedService[] = [
  {
    id: 's10',
    name: "Speedy Moto Garage",
    city: 'Hyderabad',
    rating: '4.7',
    tags: ['Service', 'Tyres', 'Performance'],
    category: 'mechanics',
  },
  {
    id: 's11',
    name: 'Coastal Customs',
    city: 'Goa',
    rating: '4.9',
    tags: ['Customisation', 'Paint', 'Bobber Builds'],
    category: 'customisation',
  },
];

type Tab = 'products' | 'services';

function UnsaveBtn({ onClick }: { onClick: () => void }) {
  return (
    <button
      type="button"
      className={styles.unsaveBtn}
      onClick={onClick}
      aria-label="Remove from saved"
      title="Remove from saved"
    >
      ♥
    </button>
  );
}

export default function SavedPage() {
  const [tab, setTab] = useState<Tab>('products');
  const [products, setProducts] = useState<SavedProduct[]>(SEED_PRODUCTS);
  const [services, setServices] = useState<SavedService[]>(SEED_SERVICES);

  function unsaveProduct(id: string) {
    setProducts((prev) => prev.filter((p) => p.id !== id));
  }

  function unsaveService(id: string) {
    setServices((prev) => prev.filter((s) => s.id !== id));
  }

  return (
    <div className={styles.page}>
      <h1 className={styles.heading}>
        <span className={styles.green}>SAVED</span>
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
              <p className={styles.emptyMsg}>Nothing saved yet</p>
              <Btn href="/bikes" kind="primary" size="sm">
                EXPLORE
              </Btn>
            </div>
          ) : (
            <div className={styles.grid}>
              {products.map((item) => (
                <div key={item.id} className={styles.cardWrap}>
                  <div className={styles.unsaveRow}>
                    <UnsaveBtn onClick={() => unsaveProduct(item.id)} />
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
              <p className={styles.emptyMsg}>Nothing saved yet</p>
              <Btn href="/services" kind="primary" size="sm">
                EXPLORE
              </Btn>
            </div>
          ) : (
            <div className={styles.serviceList}>
              {services.map((svc) => (
                <div key={svc.id} className={styles.serviceWrap}>
                  <div className={styles.unsaveRow}>
                    <UnsaveBtn onClick={() => unsaveService(svc.id)} />
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
                </div>
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
}
