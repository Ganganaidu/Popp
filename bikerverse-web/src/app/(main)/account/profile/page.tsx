'use client';

import { useState } from 'react';
import { FormField } from '@/components/forms/FormField';
import { FormSelect } from '@/components/forms/FormSelect';
import { Btn } from '@/components/ds/Btn';
import { INDIAN_STATES } from '@/lib/data/bikeData';
import styles from './page.module.css';

const STATE_OPTIONS = INDIAN_STATES.map((s) => ({ value: s, label: s }));

interface ProfileData {
  displayName: string;
  email: string;
  phoneNumber: string;
  address: string;
  area: string;
  city: string;
  pinCode: string;
  state: string;
}

const SEED: ProfileData = {
  displayName: 'Rajan Mehta',
  email: 'rajan.mehta@example.com',
  phoneNumber: '9876543210',
  address: '14, MG Road',
  area: 'Indiranagar',
  city: 'Bengaluru',
  pinCode: '560038',
  state: 'Karnataka',
};

export default function ProfilePage() {
  const [form, setForm] = useState<ProfileData>(SEED);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [saved, setSaved] = useState(false);

  function set(key: keyof ProfileData) {
    return (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
      setForm((prev) => ({ ...prev, [key]: e.target.value }));
      setSaved(false);
    };
  }

  function handleSave(e: React.FormEvent) {
    e.preventDefault();
    // TODO: persist to backend
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  }

  function handleDelete() {
    if (!showDeleteConfirm) {
      setShowDeleteConfirm(true);
      return;
    }
    // TODO: call delete account API
    alert('Account deletion requested.');
    setShowDeleteConfirm(false);
  }

  return (
    <div className={styles.page}>
      <h1 className={styles.heading}>
        MY <span className={styles.green}>PROFILE</span>
      </h1>

      <form className={styles.form} onSubmit={handleSave} noValidate>
        <FormField
          label="Display Name"
          required
          value={form.displayName}
          onChange={set('displayName')}
          placeholder="Your name"
        />

        <FormField
          label="Email"
          type="email"
          value={form.email}
          onChange={() => {}}
          readOnly
          disabled
          hint="Email cannot be changed"
          className={styles.readonlyField}
        />

        <FormField
          label="Phone Number"
          type="tel"
          value={form.phoneNumber}
          onChange={set('phoneNumber')}
          placeholder="10-digit mobile number"
        />

        <FormField
          label="Address"
          value={form.address}
          onChange={set('address')}
          placeholder="Street / flat number"
        />

        <FormField
          label="Area"
          value={form.area}
          onChange={set('area')}
          placeholder="Locality / area"
        />

        <div className={styles.row}>
          <FormField
            label="City"
            value={form.city}
            onChange={set('city')}
            placeholder="City"
          />
          <FormField
            label="Pin Code"
            type="number"
            value={form.pinCode}
            onChange={set('pinCode')}
            placeholder="6-digit pin"
          />
        </div>

        <FormSelect
          label="State"
          options={STATE_OPTIONS}
          placeholder="Select state"
          value={form.state}
          onChange={set('state')}
        />

        <div className={styles.saveRow}>
          <Btn type="submit" kind="primary" size="md">
            {saved ? 'SAVED!' : 'SAVE CHANGES'}
          </Btn>
        </div>
      </form>

      <div className={styles.dangerZone}>
        <div className={styles.sectionLabel}>ACCOUNT</div>

        {showDeleteConfirm ? (
          <div className={styles.confirmRow}>
            <span className={styles.confirmText}>
              Are you sure? This action is irreversible.
            </span>
            <button
              type="button"
              className={styles.deleteBtn}
              onClick={handleDelete}
            >
              YES, DELETE MY ACCOUNT
            </button>
            <button
              type="button"
              className={styles.cancelBtn}
              onClick={() => setShowDeleteConfirm(false)}
            >
              CANCEL
            </button>
          </div>
        ) : (
          <button
            type="button"
            className={styles.deleteBtn}
            onClick={handleDelete}
          >
            DELETE ACCOUNT
          </button>
        )}
      </div>
    </div>
  );
}
