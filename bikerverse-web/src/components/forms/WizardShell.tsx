import type { ReactNode } from 'react';
import styles from './WizardShell.module.css';

interface WizardShellProps {
  title: string;
  subtitle?: string;
  children: ReactNode;
}

/**
 * WizardShell — max-width constrained page wrapper for sell/list wizards.
 * Renders the big heading + optional subtitle, then children (StepBar + form panels).
 */
export function WizardShell({ title, subtitle, children }: WizardShellProps) {
  return (
    <div className={styles.page}>
      <div className={styles.inner}>
        <div className={styles.head}>
          <h1 className={styles.title}>
            {title.split(' ').map((word, i, arr) => (
              i === arr.length - 1
                ? <span key={i} className={styles.accent}>{word}</span>
                : <span key={i}>{word} </span>
            ))}
          </h1>
          {subtitle && <p className={styles.subtitle}>{subtitle}</p>}
        </div>
        {children}
      </div>
    </div>
  );
}
