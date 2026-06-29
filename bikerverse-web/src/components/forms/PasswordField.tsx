'use client';

import { useState, type InputHTMLAttributes } from 'react';
import formStyles from './FormField.module.css';
import styles from './PasswordField.module.css';

interface PasswordFieldProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type' | 'className'> {
  label: string;
  error?: string;
  hint?: string;
}

function EyeIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
      <circle cx="12" cy="12" r="3" />
    </svg>
  );
}

function EyeOffIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94" />
      <path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19" />
      <line x1="1" y1="1" x2="23" y2="23" />
    </svg>
  );
}

export function PasswordField({ label, error, hint, required, ...rest }: PasswordFieldProps) {
  const [show, setShow] = useState(false);
  const fieldId = `field-${label.toLowerCase().replace(/\s+/g, '-')}`;

  return (
    <div className={formStyles.wrap}>
      <label htmlFor={fieldId} className={formStyles.label}>
        {label}
        {required && <span className={formStyles.req} aria-hidden>*</span>}
      </label>

      <div className={styles.inputWrap}>
        <input
          id={fieldId}
          className={[formStyles.input, error ? formStyles.hasError : ''].filter(Boolean).join(' ')}
          type={show ? 'text' : 'password'}
          style={{ paddingRight: '44px' }}
          required={required}
          aria-describedby={hint || error ? `${fieldId}-hint` : undefined}
          aria-invalid={!!error}
          {...rest}
        />
        <button
          type="button"
          className={styles.toggle}
          onClick={() => setShow((v) => !v)}
          tabIndex={-1}
          aria-label={show ? 'Hide password' : 'Show password'}
        >
          {show ? <EyeOffIcon /> : <EyeIcon />}
        </button>
      </div>

      {(error || hint) && (
        <span id={`${fieldId}-hint`} className={error ? formStyles.error : formStyles.hint}>
          {error ?? hint}
        </span>
      )}
    </div>
  );
}
