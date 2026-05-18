'use client';

import { useState } from 'react';
import styles from './page.module.css';

/* ---- Types ---- */
type ItemStatus = 'pending' | 'approved' | 'rejected' | 'sent_back';

interface Product {
  id: string;
  name: string;
  price: string;
  city: string;
  seller: string;
  status: ItemStatus;
}

interface Service {
  id: string;
  name: string;
  city: string;
  seller: string;
  category: string;
  status: ItemStatus;
}

interface Ad {
  id: string;
  title: string;
  active: boolean;
}

/* ---- Seed data ---- */
const SEED_PRODUCTS: Product[] = [
  { id: 'p1', name: 'Royal Enfield Thunderbird 500', price: '₹ 1,45,000', city: 'Pune', seller: 'Ankit Mehta', status: 'pending' },
  { id: 'p2', name: 'Yamaha MT-07', price: '₹ 6,80,000', city: 'Mumbai', seller: 'Deepak Nair', status: 'pending' },
  { id: 'p3', name: 'Honda CB Hornet 160R', price: '₹ 72,000', city: 'Chennai', seller: 'Suresh Pillai', status: 'pending' },
];

const SEED_SERVICES: Service[] = [
  { id: 's1', name: 'SpeedMasters Tuning', city: 'Hyderabad', seller: 'Mohammed Ali', category: 'Tuning', status: 'pending' },
  { id: 's2', name: 'Precision Tyres & Alignment', city: 'Bengaluru', seller: 'Ramesh Gowda', category: 'Tyres', status: 'pending' },
];

const SEED_ADS: Ad[] = [
  { id: 'a1', title: 'Hero Splendor Plus — Summer Offer', active: true },
  { id: 'a2', title: 'Bikerverse Premium Membership', active: false },
];

type Tab = 'products' | 'services' | 'ads';

/* ---- Components ---- */
function ProductCard({
  item,
  onApprove,
  onReject,
  onSentBack,
}: {
  item: Product;
  onApprove: () => void;
  onReject: () => void;
  onSentBack: () => void;
}) {
  return (
    <div className={[styles.card, item.status !== 'pending' ? styles.dismissed : ''].join(' ')}>
      <div className={styles.cardImage}>Photo</div>
      <div className={styles.cardBody}>
        <p className={styles.cardName}>{item.name}</p>
        <p className={styles.cardMeta}>{item.city} · {item.seller}</p>
        <p className={styles.cardPrice}>{item.price}</p>
        <div className={styles.cardActions}>
          <span className={[styles.badge, styles.badgePending].join(' ')}>Pending</span>
          <button className={styles.btnApprove} onClick={onApprove}>Approve</button>
          <button className={styles.btnReject} onClick={onReject}>Reject</button>
          <button className={styles.btnSentBack} onClick={onSentBack}>Sent back</button>
        </div>
      </div>
    </div>
  );
}

function ServiceCard({
  item,
  onApprove,
  onReject,
  onSentBack,
}: {
  item: Service;
  onApprove: () => void;
  onReject: () => void;
  onSentBack: () => void;
}) {
  return (
    <div className={[styles.card, item.status !== 'pending' ? styles.dismissed : ''].join(' ')}>
      <div className={styles.cardImage}>Photo</div>
      <div className={styles.cardBody}>
        <p className={styles.cardName}>{item.name}</p>
        <p className={styles.cardMeta}>{item.city} · {item.seller} · {item.category}</p>
        <div className={styles.cardActions}>
          <span className={[styles.badge, styles.badgePending].join(' ')}>Pending</span>
          <button className={styles.btnApprove} onClick={onApprove}>Approve</button>
          <button className={styles.btnReject} onClick={onReject}>Reject</button>
          <button className={styles.btnSentBack} onClick={onSentBack}>Sent back</button>
        </div>
      </div>
    </div>
  );
}

function Toggle({ active, onToggle }: { active: boolean; onToggle: () => void }) {
  return (
    <button
      className={styles.toggle}
      onClick={onToggle}
      aria-pressed={active}
      aria-label={active ? 'Active — click to deactivate' : 'Inactive — click to activate'}
    >
      <span className={[styles.toggleTrack, active ? styles.toggleTrackOn : styles.toggleTrackOff].join(' ')}>
        <span className={[styles.toggleThumb, active ? styles.toggleThumbOn : styles.toggleThumbOff].join(' ')} />
      </span>
      <span className={styles.toggleLabel}>{active ? 'Active' : 'Inactive'}</span>
    </button>
  );
}

/* ---- Page ---- */
export default function AdminDashboardPage() {
  const [activeTab, setActiveTab] = useState<Tab>('products');
  const [products, setProducts] = useState<Product[]>(SEED_PRODUCTS);
  const [services, setServices] = useState<Service[]>(SEED_SERVICES);
  const [ads, setAds] = useState<Ad[]>(SEED_ADS);

  function updateProductStatus(id: string, status: ItemStatus) {
    setProducts((prev) => prev.map((p) => p.id === id ? { ...p, status } : p));
  }

  function updateServiceStatus(id: string, status: ItemStatus) {
    setServices((prev) => prev.map((s) => s.id === id ? { ...s, status } : s));
  }

  function toggleAd(id: string) {
    setAds((prev) => prev.map((a) => a.id === id ? { ...a, active: !a.active } : a));
  }

  return (
    <div className={styles.page}>
      <h1 className={styles.title}>Admin</h1>

      <div className={styles.tabs}>
        {(['products', 'services', 'ads'] as Tab[]).map((t) => (
          <button
            key={t}
            className={[styles.tab, activeTab === t ? styles.tabActive : ''].join(' ')}
            onClick={() => setActiveTab(t)}
          >
            {t}
          </button>
        ))}
      </div>

      {activeTab === 'products' && (
        <div className={styles.list}>
          {products.map((p) => (
            <ProductCard
              key={p.id}
              item={p}
              onApprove={() => updateProductStatus(p.id, 'approved')}
              onReject={() => updateProductStatus(p.id, 'rejected')}
              onSentBack={() => updateProductStatus(p.id, 'sent_back')}
            />
          ))}
        </div>
      )}

      {activeTab === 'services' && (
        <div className={styles.list}>
          {services.map((s) => (
            <ServiceCard
              key={s.id}
              item={s}
              onApprove={() => updateServiceStatus(s.id, 'approved')}
              onReject={() => updateServiceStatus(s.id, 'rejected')}
              onSentBack={() => updateServiceStatus(s.id, 'sent_back')}
            />
          ))}
        </div>
      )}

      {activeTab === 'ads' && (
        <div className={styles.adList}>
          {ads.map((ad) => (
            <div key={ad.id} className={styles.adRow}>
              <span className={styles.adTitle}>{ad.title}</span>
              <Toggle active={ad.active} onToggle={() => toggleAd(ad.id)} />
              <a href="#" className={styles.editLink}>Edit</a>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
