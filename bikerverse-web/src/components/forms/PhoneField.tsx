import { COUNTRY_CODES } from '@/lib/data/bikeData';
import styles from './PhoneField.module.css';

interface PhoneFieldProps {
  label: string;
  countryCode: string;
  number: string;
  onCountryCodeChange: (v: string) => void;
  onNumberChange: (v: string) => void;
  required?: boolean;
  hint?: string;
}

/**
 * PhoneField — country code dropdown + number input.
 * Mirrors Flutter's Country Code Dropdown + TextFormField pattern.
 */
export function PhoneField({
  label, countryCode, number, onCountryCodeChange, onNumberChange, required, hint,
}: PhoneFieldProps) {
  const fieldId = `phone-${label.toLowerCase().replace(/\s+/g, '-')}`;

  return (
    <div className={styles.wrap}>
      <label htmlFor={`${fieldId}-number`} className={styles.label}>
        {label}
        {required && <span className={styles.req} aria-hidden>*</span>}
      </label>
      <div className={styles.row}>
        <div className={styles.codeWrap}>
          <select
            className={styles.codeSelect}
            value={countryCode}
            onChange={(e) => onCountryCodeChange(e.target.value)}
            aria-label="Country code"
          >
            {COUNTRY_CODES.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
          <span className={styles.chevron} aria-hidden>▾</span>
        </div>
        <input
          id={`${fieldId}-number`}
          type="tel"
          className={styles.numberInput}
          placeholder="Enter phone number"
          value={number}
          onChange={(e) => onNumberChange(e.target.value)}
          inputMode="numeric"
          maxLength={15}
        />
      </div>
      {hint && <span className={styles.hint}>{hint}</span>}
    </div>
  );
}
