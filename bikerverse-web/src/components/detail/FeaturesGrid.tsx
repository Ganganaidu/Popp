import styles from './FeaturesGrid.module.css';

interface FeaturesGridProps {
  about: string;
  features: string[];
  title?: string;
}

/**
 * FeaturesGrid — 1fr 2fr layout.
 * Left: section title + paragraph.
 * Right: 3-column feature chips with 6×6 green square markers.
 */
export function FeaturesGrid({ about, features, title = 'ABOUT THIS BIKE' }: FeaturesGridProps) {
  return (
    <section className={styles.section}>
      {/* Left */}
      <div className={styles.left}>
        <h2 className={styles.title}>{title}</h2>
        <p className={styles.about}>{about}</p>
      </div>

      {/* Right */}
      <div className={styles.right}>
        <div className={styles.featureGrid}>
          {features.map((feature) => (
            <div key={feature} className={styles.feature}>
              <span className={styles.dot} aria-hidden="true" />
              <span className={styles.featureLabel}>{feature}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
