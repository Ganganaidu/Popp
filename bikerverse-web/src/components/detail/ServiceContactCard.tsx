'use client';

import { useState } from 'react';
import { Btn } from '@/components/ds/Btn';
import styles from './ServiceContactCard.module.css';

interface ServiceContactCardProps {
  contactName: string;
  contactNumber: string;
  workingHours?: string;
}

/**
 * ServiceContactCard — surface-lo card for service/shop contact info.
 * Shows contact name + working hours, with a CALL button that reveals the number.
 */
export function ServiceContactCard({
  contactName,
  contactNumber,
  workingHours,
}: ServiceContactCardProps) {
  const [showPhone, setShowPhone] = useState(false);

  return (
    <div className={styles.card}>
      <div className={styles.info}>
        <span className={styles.label}>CONTACT</span>
        <span className={styles.name}>{contactName}</span>
        {workingHours && (
          <span className={styles.hours}>{workingHours}</span>
        )}
      </div>

      <div className={styles.actions}>
        {showPhone ? (
          <span className={styles.phoneNumber}>{contactNumber}</span>
        ) : (
          <Btn kind="ghost" size="sm" onClick={() => setShowPhone(true)}>
            CALL
          </Btn>
        )}
      </div>
    </div>
  );
}
