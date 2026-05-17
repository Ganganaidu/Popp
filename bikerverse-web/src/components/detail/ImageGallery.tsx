'use client';

import { useState } from 'react';
import { Slot } from '@/components/ds/Slot';
import { CornerTicks } from '@/components/ds/CornerTicks';
import styles from './ImageGallery.module.css';

interface ImageGalleryProps {
  images?: string[];
  name: string;
}

const PLACEHOLDER_COUNT = 4;

/**
 * ImageGallery — 4:3 primary image with top-left + bottom-right corner ticks.
 * Below: 4-column thumbnail strip. Active thumb has 2px --bv-green outline.
 */
export function ImageGallery({ images, name }: ImageGalleryProps) {
  const [active, setActive] = useState(0);

  // Create placeholder slots if no images provided
  const thumbCount = images?.length ?? PLACEHOLDER_COUNT;
  const thumbIndices = Array.from({ length: thumbCount }, (_, i) => i);

  return (
    <div className={styles.wrap}>
      {/* Primary image */}
      <div className={styles.primaryWrap}>
        <CornerTicks corners={['tl', 'br']} offset={10} />
        <Slot
          label={`${name} — main photo`}
          aspectRatio="4/3"
          src={images?.[active]}
          alt={`${name} photo ${active + 1}`}
          className={styles.primary}
        />
      </div>

      {/* Thumbnail strip */}
      <div className={styles.thumbs}>
        {thumbIndices.map((i) => (
          <button
            key={i}
            type="button"
            className={[styles.thumbBtn, i === active ? styles.thumbActive : ''].filter(Boolean).join(' ')}
            onClick={() => setActive(i)}
            aria-label={`View photo ${i + 1}`}
          >
            <Slot
              label={`${name} thumb ${i + 1}`}
              aspectRatio="4/3"
              src={images?.[i]}
              alt={`${name} thumbnail ${i + 1}`}
              className={styles.thumb}
            />
          </button>
        ))}
      </div>
    </div>
  );
}
