import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { ShopRow } from '@/components/cards/ShopRow';
import { Btn } from '@/components/ds/Btn';
import styles from './page.module.css';

const CATEGORY_LABELS: Record<string, string> = {
  mechanics:    'TRUSTED MECHANICS',
  tyre:         'TYRE SHOPS',
  accessories:  'ACCESSORY STORES',
  trackdays:    'TRACK DAYS',
  training:     'TRAINING',
};

const SHOPS = [
  { id: 's1', name: 'Weekendmech Pvt Ltd',    city: 'Jubilee Hills, Hyderabad',  rating: '4.9', tags: ['Akrapovic', 'Ducati', 'Triumph'],   category: 'mechanics' },
  { id: 's2', name: 'GarageOne Performance',  city: 'Andheri West, Mumbai',      rating: '4.8', tags: ['ECU tune', 'Suspension'],            category: 'mechanics' },
  { id: 's3', name: "Apex Riders' Garage",    city: 'Indiranagar, Bengaluru',    rating: '4.7', tags: ['Track prep', 'Race fairings'],        category: 'mechanics' },
  { id: 's4', name: 'Pitstop Motorsports',    city: 'Connaught Place, Delhi',    rating: '4.6', tags: ['KTM', 'Royal Enfield', 'Service'],    category: 'mechanics' },
  { id: 's5', name: 'Moto Clinic',            city: 'T. Nagar, Chennai',         rating: '4.5', tags: ['Diagnostic', 'Restoration'],          category: 'mechanics' },
  { id: 's6', name: 'Speed Works Garage',     city: 'Koregaon Park, Pune',       rating: '4.4', tags: ['Harley', 'Triumph', 'Dyno tune'],     category: 'mechanics' },
] as const;

interface PageProps {
  params: Promise<{ category: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { category } = await params;
  const label = CATEGORY_LABELS[category] ?? category.toUpperCase();
  return { title: `${label} — Bikerverse` };
}

export default async function ServiceCategoryPage({ params }: PageProps) {
  const { category } = await params;
  const label = CATEGORY_LABELS[category] ?? category.replace(/-/g, ' ').toUpperCase();

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',     href: '/'          },
        { label: 'Services'                     },
        { label: label                          },
      ]} />

      <h1 className={styles.heading}>
        {label.split(' ').map((w, i) => (
          i === label.split(' ').length - 1
            ? <span key={i} className={styles.accent}>{w} </span>
            : <span key={i}>{w} </span>
        ))}
      </h1>

      <div className={styles.list}>
        {SHOPS.map((shop) => (
          <ShopRow
            key={shop.id}
            id={shop.id}
            name={shop.name}
            city={shop.city}
            rating={shop.rating}
            tags={shop.tags}
            category={category}
          />
        ))}
      </div>

      <div className={styles.loadMore}>
        <Btn kind="line" size="md">LOAD MORE</Btn>
      </div>
    </div>
  );
}
