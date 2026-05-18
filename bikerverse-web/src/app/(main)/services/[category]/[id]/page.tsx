import type { Metadata } from 'next';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { Slot } from '@/components/ds/Slot';
import { PinIcon, StarIcon, CalIcon } from '@/components/ds/Icons';
import { Btn } from '@/components/ds/Btn';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import { ServiceContactCard } from '@/components/detail/ServiceContactCard';
import styles from './page.module.css';

export const metadata: Metadata = {
  title: 'Weekendmech Pvt Ltd — Bikerverse',
};

const SHOP = {
  id: 's1',

  // Identity
  shopName: 'Weekendmech Pvt Ltd',
  businessTitle: 'Performance Garage & ECU Specialists',
  businessDescription: `One of Hyderabad's most respected performance garages, specialising in
European and premium Japanese motorcycles. Factory-trained technicians for
Ducati and Triumph. Official Akrapovic exhaust fitment centre.`,

  // Contact
  contactName: 'Venkat Rao',
  contactNumber: '+91 98491 22334',

  // Business info
  gstNumber: '36AABCW1234F1Z5',
  googleMapsLink: 'https://maps.google.com/?q=Weekendmech+Jubilee+Hills+Hyderabad',
  socialMediaLink: 'https://instagram.com/weekendmech',

  // Working hours
  workingHours: 'Tue – Sun, 9 AM – 7 PM',

  // Location
  address: 'Plot 42, Road No. 36',
  area: 'Jubilee Hills',
  city: 'Hyderabad',
  pinCode: '500033',
  state: 'Telangana',

  // Status
  status: 'Approved',  // Approved | Pending | Rejected

  // Tags / specialities
  tags: ['Akrapovic', 'Ducati', 'Triumph', 'Track Prep', 'ECU Tune', 'Suspension'],

  // Rating (from reviews)
  rating: '4.9',
  reviewCount: 128,

  // Track day / training day — only relevant for those categories
  isTrackDay: false,
  eventStartDate: '',
  eventEndDate: '',
  eventStartTime: '',
  eventEndTime: '',
  maxSlots: '',
  bikeProvision: '',
  riderSkillLevel: '',
  googleFormLink: '',

  specs: [
    { key: 'Established',  value: '2014'                        },
    { key: 'Experience',   value: '10+ years'                   },
    { key: 'Speciality',   value: 'European superbikes'         },
    { key: 'Languages',    value: 'Telugu, Hindi, English'      },
    { key: 'GST Number',   value: '36AABCW1234F1Z5'             },
    { key: 'Pin Code',     value: '500033'                      },
  ],

  reviews: [
    { author: 'Kiran M.',  rating: 5, text: 'Brilliant work on my Ducati Panigale. Transparent pricing and fast turnaround.' },
    { author: 'Suresh R.', rating: 5, text: 'Best suspension setup in Hyderabad. My Street Triple handles like a track bike now.' },
    { author: 'Anu P.',    rating: 4, text: 'Great ECU tune, picked up 8 bhp. Would appreciate earlier appointment slots.' },
  ],
};

const TRACK_DAY_SHOP = {
  ...SHOP,
  id: 'td1',
  shopName: 'Hyderabad Track Experience',
  businessTitle: 'Track Day — Open Laps Session',
  businessDescription: `Professional track day event at JNTU Circuit. Open laps for all skill levels.
Timing transponders provided. Safety marshals on track. Medical team on standby.`,
  contactName: 'Arjun Reddy',
  contactNumber: '+91 99990 12345',
  isTrackDay: true,
  eventStartDate: '12 Jun 2025',
  eventEndDate: '12 Jun 2025',
  eventStartTime: '6:00 AM',
  eventEndTime: '2:00 PM',
  maxSlots: '40',
  bikeProvision: 'Own Bike',
  riderSkillLevel: 'Intermediate',
  googleFormLink: 'https://forms.google.com/example',
  status: 'Approved',
};

function statusBadgeClass(status: string): string {
  if (status === 'Approved') return styles.badgeApproved;
  if (status === 'Rejected') return styles.badgeRejected;
  return styles.badgePending;
}

interface PageProps {
  params: Promise<{ category: string; id: string }>;
}

export default async function ServiceDetailPage({ params }: PageProps) {
  const { category, id } = await params;

  // In Phase 7 — fetch service by `id` and `category` from Firestore
  // Using TRACK_DAY_SHOP for track-day category seed, SHOP otherwise
  const isTrackDayCategory = category === 'track-day' || category === 'training-day';
  const shop = isTrackDayCategory ? { ...TRACK_DAY_SHOP, id } : { ...SHOP, id };

  const fullAddress = [shop.address, shop.area, shop.city, shop.pinCode, shop.state]
    .filter(Boolean)
    .join(', ');

  const shopSpecs = [
    ...shop.specs,
    { key: 'Address',       value: fullAddress },
    { key: 'Working Hours', value: shop.workingHours },
  ];

  const trackDaySpecs = shop.isTrackDay
    ? [
        { key: 'Event Date',     value: shop.eventStartDate === shop.eventEndDate ? shop.eventStartDate : `${shop.eventStartDate} – ${shop.eventEndDate}` },
        { key: 'Start Time',     value: shop.eventStartTime },
        { key: 'End Time',       value: shop.eventEndTime },
        { key: 'Max Slots',      value: shop.maxSlots },
        { key: 'Bike Provision', value: shop.bikeProvision },
        { key: 'Skill Level',    value: shop.riderSkillLevel },
      ]
    : [];

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',     href: '/'                         },
        { label: 'Services', href: `/services/${category}`     },
        { label: shop.shopName                                  },
      ]} />

      {/* Hero */}
      <div className={styles.hero}>
        <Slot label={shop.shopName} aspectRatio="16/9" className={styles.heroImage} />

        <div className={styles.heroInfo}>
          <div className={styles.shopNameRow}>
            <h1 className={styles.shopName}>{shop.shopName}</h1>
            <span className={`${styles.badge} ${statusBadgeClass(shop.status)}`}>
              {shop.status.toUpperCase()}
            </span>
          </div>

          {shop.businessTitle && (
            <p className={styles.businessTitle}>{shop.businessTitle}</p>
          )}

          <div className={styles.metaRow}>
            <span className={styles.rating}>
              <StarIcon size={14} color="var(--bv-green)" />
              {shop.rating}
            </span>
            <span className={styles.reviews}>({shop.reviewCount} reviews)</span>
            <span className={styles.sep}>·</span>
            <span className={styles.city}>
              <PinIcon size={12} color="var(--bv-text-3)" />
              {shop.area}, {shop.city}
            </span>
          </div>

          <div className={styles.tags}>
            {shop.tags.map((tag) => (
              <span key={tag} className={styles.tag}>{tag}</span>
            ))}
          </div>

          <p className={styles.about}>{shop.businessDescription}</p>

          <div className={styles.ctaRow}>
            {shop.isTrackDay && shop.googleFormLink ? (
              <Btn kind="primary" size="md" href={shop.googleFormLink}>
                REGISTER NOW
              </Btn>
            ) : (
              <Btn kind="primary" size="md" icon={<CalIcon size={16} color="var(--bv-green-ink)" />}>
                BOOK APPOINTMENT
              </Btn>
            )}
            {shop.googleMapsLink && (
              <Btn kind="ghost" size="md" href={shop.googleMapsLink}>
                GET DIRECTIONS
              </Btn>
            )}
            {shop.socialMediaLink && (
              <Btn kind="ghost" size="md" href={shop.socialMediaLink}>
                SOCIAL MEDIA
              </Btn>
            )}
          </div>
        </div>
      </div>

      {/* Contact card */}
      <ServiceContactCard
        contactName={shop.contactName}
        contactNumber={shop.contactNumber}
        workingHours={shop.workingHours}
      />

      {/* Shop / event specs */}
      <SpecsGrid specs={shopSpecs} title="SHOP DETAILS" />

      {/* Track day / training day event details */}
      {shop.isTrackDay && trackDaySpecs.length > 0 && (
        <SpecsGrid specs={trackDaySpecs} title="EVENT DETAILS" />
      )}

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
