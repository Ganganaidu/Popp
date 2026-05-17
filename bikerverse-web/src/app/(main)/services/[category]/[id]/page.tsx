import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { Slot } from '@/components/ds/Slot';
import { PinIcon, StarIcon, CalIcon } from '@/components/ds/Icons';
import { Btn } from '@/components/ds/Btn';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import styles from './page.module.css';

export const metadata: Metadata = {
  title: 'Weekendmech Pvt Ltd — Bikerverse',
};

const SHOP = {
  id: 's1',
  name: 'Weekendmech Pvt Ltd',
  city: 'Jubilee Hills, Hyderabad',
  rating: '4.9',
  reviewCount: 128,
  tags: ['Akrapovic', 'Ducati', 'Triumph', 'Track Prep', 'ECU Tune', 'Suspension'],
  about: `One of Hyderabad's most respected performance garages, specialising in
    European and premium Japanese motorcycles. Factory-trained technicians for
    Ducati and Triumph. Official Akrapovic exhaust fitment centre.
    Open Tuesday – Sunday, 9 AM to 7 PM.`,
  specs: [
    { key: 'Established',  value: '2014'                    },
    { key: 'Experience',   value: '10+ years'               },
    { key: 'Speciality',   value: 'European superbikes'     },
    { key: 'Languages',    value: 'Telugu, Hindi, English'  },
    { key: 'Hours',        value: 'Tue – Sun, 9 AM – 7 PM' },
    { key: 'Phone',        value: '+91 98491 XXXXX'         },
  ],
  reviews: [
    { author: 'Kiran M.',  rating: 5, text: 'Brilliant work on my Ducati Panigale. Transparent pricing and fast turnaround.' },
    { author: 'Suresh R.', rating: 5, text: 'Best suspension setup in Hyderabad. My Street Triple handles like a track bike now.' },
    { author: 'Anu P.',    rating: 4, text: 'Great ECU tune, picked up 8 bhp. Would appreciate earlier appointment slots.' },
  ],
};

interface PageProps {
  params: Promise<{ category: string; id: string }>;
}

export default async function ServiceDetailPage({ params }: PageProps) {
  const { category } = await params;
  const shop = SHOP;

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',     href: '/'                         },
        { label: 'Services', href: `/services/${category}`     },
        { label: shop.name                                      },
      ]} />

      {/* Hero */}
      <div className={styles.hero}>
        <Slot label={shop.name} aspectRatio="16/9" className={styles.heroImage} />

        <div className={styles.heroInfo}>
          <h1 className={styles.shopName}>{shop.name}</h1>

          <div className={styles.metaRow}>
            <span className={styles.rating}>
              <StarIcon size={14} color="var(--bv-green)" />
              {shop.rating}
            </span>
            <span className={styles.reviews}>({shop.reviewCount} reviews)</span>
            <span className={styles.sep}>·</span>
            <span className={styles.city}>
              <PinIcon size={12} color="var(--bv-text-3)" />
              {shop.city}
            </span>
          </div>

          <div className={styles.tags}>
            {shop.tags.map((tag) => (
              <span key={tag} className={styles.tag}>{tag}</span>
            ))}
          </div>

          <p className={styles.about}>{shop.about}</p>

          <div className={styles.ctaRow}>
            <Btn kind="primary" size="md" icon={<CalIcon size={16} color="var(--bv-green-ink)" />}>
              BOOK APPOINTMENT
            </Btn>
            <Btn kind="ghost" size="md">GET DIRECTIONS</Btn>
          </div>
        </div>
      </div>

      {/* Specs */}
      <SpecsGrid specs={shop.specs} title="SHOP DETAILS" />

      {/* Reviews */}
      <section className={styles.reviewsSection}>
        <h2 className={styles.reviewsTitle}>REVIEWS</h2>
        <div className={styles.reviewList}>
          {shop.reviews.map((rev) => (
            <div key={rev.author} className={styles.reviewCard}>
              <div className={styles.reviewHeader}>
                <span className={styles.reviewAuthor}>{rev.author}</span>
                <span className={styles.reviewRating}>
                  {'★'.repeat(rev.rating)}{'☆'.repeat(5 - rev.rating)}
                </span>
              </div>
              <p className={styles.reviewText}>{rev.text}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
