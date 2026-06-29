'use client';

import { useState, useEffect } from 'react';
import { useParams } from 'next/navigation';
import { Breadcrumb } from '@/components/listing/Breadcrumb';
import { Slot } from '@/components/ds/Slot';
import { PinIcon, StarIcon, CalIcon } from '@/components/ds/Icons';
import { Btn } from '@/components/ds/Btn';
import { SpecsGrid } from '@/components/detail/SpecsGrid';
import { ServiceContactCard } from '@/components/detail/ServiceContactCard';
import { getServiceById } from '@/lib/firebase/firestore';
import type { FirestoreService } from '@/lib/types';
import styles from './page.module.css';

export function ServiceDetailContent() {
  const { category, id } = useParams<{ category: string; id: string }>();
  const [service, setService] = useState<FirestoreService | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    if (!id) return;
    getServiceById(id).then((s) => { setService(s); setLoaded(true); });
  }, [id]);

  if (!loaded) return null;
  if (!service) return <div className={styles.page}><p>Service not found.</p></div>;

  const fullAddress = [service.address, service.area, service.city, service.pinCode, service.state]
    .filter(Boolean)
    .join(', ');

  const shopSpecs = [
    { key: 'Address',       value: fullAddress },
    { key: 'Working Hours', value: service.workingHours ?? '' },
    { key: 'GST Number',    value: service.gstNumber ?? '' },
    { key: 'Pin Code',      value: service.pinCode ?? '' },
  ].filter((s) => s.value);

  const trackDaySpecs = service.isTrackDay
    ? [
        { key: 'Event Date',     value: service.eventStartDate === service.eventEndDate ? (service.eventStartDate ?? '') : `${service.eventStartDate ?? ''} – ${service.eventEndDate ?? ''}` },
        { key: 'Start Time',     value: service.eventStartTime ?? '' },
        { key: 'End Time',       value: service.eventEndTime ?? '' },
        { key: 'Max Slots',      value: service.maxSlots ?? '' },
        { key: 'Bike Provision', value: service.bikeProvision ?? '' },
        { key: 'Skill Level',    value: service.riderSkillLevel ?? '' },
      ].filter((s) => s.value)
    : [];

  const statusLabel = service.isApproved ? 'APPROVED' : 'PENDING';
  const heroImageUrl = service.promoImageUrls?.[0] || service.shopImageUrls?.[0];

  return (
    <div className={styles.page}>
      <Breadcrumb items={[
        { label: 'Home',     href: '/'                          },
        { label: 'Services', href: `/services/${category}`      },
        { label: service.businessTitle ?? 'Service'             },
      ]} />

      <div className={styles.hero}>
        <Slot label={service.businessTitle ?? 'Service'} aspectRatio="16/9" className={styles.heroImage} src={heroImageUrl} />

        <div className={styles.heroInfo}>
          <div className={styles.shopNameRow}>
            <h1 className={styles.shopName}>{service.businessTitle}</h1>
            <span className={`${styles.badge} ${service.isApproved ? styles.badgeApproved : styles.badgePending}`}>
              {statusLabel}
            </span>
          </div>

          <div className={styles.metaRow}>
            {service.rating && (
              <>
                <span className={styles.rating}>
                  <StarIcon size={14} color="var(--bv-green)" />
                  {service.rating}
                </span>
                {service.reviewCount != null && (
                  <span className={styles.reviews}>({service.reviewCount} reviews)</span>
                )}
                <span className={styles.sep}>·</span>
              </>
            )}
            <span className={styles.city}>
              <PinIcon size={12} color="var(--bv-text-3)" />
              {[service.area, service.city].filter(Boolean).join(', ')}
            </span>
          </div>

          {service.tags && service.tags.length > 0 && (
            <div className={styles.tags}>
              {service.tags.map((tag) => (
                <span key={tag} className={styles.tag}>{tag}</span>
              ))}
            </div>
          )}

          <div className={styles.ctaRow}>
            {service.isTrackDay && service.googleFormLink ? (
              <Btn kind="primary" size="md" href={service.googleFormLink}>
                REGISTER NOW
              </Btn>
            ) : (
              <Btn kind="primary" size="md" icon={<CalIcon size={16} color="var(--bv-green-ink)" />}>
                BOOK APPOINTMENT
              </Btn>
            )}
            {service.googleMapsLink && (
              <Btn kind="ghost" size="md" href={service.googleMapsLink}>
                GET DIRECTIONS
              </Btn>
            )}
            {service.socialMediaLink && (
              <Btn kind="ghost" size="md" href={service.socialMediaLink}>
                SOCIAL MEDIA
              </Btn>
            )}
          </div>
        </div>
      </div>

      <ServiceContactCard
        contactName={service.contactName ?? ''}
        contactNumber={service.contactNumber ?? ''}
        workingHours={service.workingHours ?? ''}
      />

      <SpecsGrid specs={shopSpecs} title="SHOP DETAILS" />

      {service.isTrackDay && trackDaySpecs.length > 0 && (
        <SpecsGrid specs={trackDaySpecs} title="EVENT DETAILS" />
      )}
    </div>
  );
}
