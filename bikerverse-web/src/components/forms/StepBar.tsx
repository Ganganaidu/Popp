import styles from './StepBar.module.css';

interface StepBarProps {
  steps: string[];
  current: number; // 0-indexed
}

/**
 * StepBar — horizontal step indicator used at the top of each wizard.
 * Completed steps: filled green circle with checkmark.
 * Current step: green outline circle + green label.
 * Upcoming steps: dim circle + dim label.
 * Connecting lines fill green as steps complete.
 */
export function StepBar({ steps, current }: StepBarProps) {
  return (
    <nav aria-label="Form steps" className={styles.bar}>
      {steps.map((step, i) => {
        const done    = i < current;
        const active  = i === current;
        const upcoming = i > current;

        return (
          <div key={step} className={styles.step}>
            {/* Connector line before step (skip first) */}
            {i > 0 && (
              <div className={[styles.line, done || active ? styles.lineDone : ''].filter(Boolean).join(' ')} />
            )}

            {/* Circle */}
            <div
              className={[
                styles.circle,
                done    ? styles.circleDone    : '',
                active  ? styles.circleActive  : '',
                upcoming ? styles.circleUpcoming : '',
              ].filter(Boolean).join(' ')}
              aria-current={active ? 'step' : undefined}
            >
              {done ? (
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none" aria-hidden>
                  <path d="M1 4l3 3 5-6" stroke="var(--bv-green-ink)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              ) : (
                <span className={styles.num}>{i + 1}</span>
              )}
            </div>

            {/* Label */}
            <span className={[
              styles.label,
              done ? styles.labelDone : '',
              active ? styles.labelActive : '',
            ].filter(Boolean).join(' ')}>
              {step}
            </span>
          </div>
        );
      })}
    </nav>
  );
}
