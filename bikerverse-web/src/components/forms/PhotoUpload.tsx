'use client';

import { useRef, useState } from 'react';
import styles from './PhotoUpload.module.css';

interface PhotoUploadProps {
  label?: string;
  maxPhotos?: number;
  hint?: string;
}

interface PhotoSlot {
  id: string;
  url: string;
  file: File;
}

/**
 * PhotoUpload — grid of dashed slots.
 * Click any empty slot → file picker. First slot = "Cover photo".
 * Uploaded photos show a preview with ×-remove button.
 * Max photos configurable (default 8).
 */
export function PhotoUpload({ label = 'PHOTOS', maxPhotos = 8, hint }: PhotoUploadProps) {
  const [photos, setPhotos] = useState<PhotoSlot[]>([]);
  const inputRef = useRef<HTMLInputElement>(null);
  const [activatingSlot, setActivatingSlot] = useState<number | null>(null);

  function handleSlotClick(index: number) {
    if (index <= photos.length) {
      setActivatingSlot(index);
      inputRef.current?.click();
    }
  }

  function handleFiles(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []);
    if (!files.length) return;

    const newPhotos: PhotoSlot[] = files.slice(0, maxPhotos - photos.length).map((file) => ({
      id: `${Date.now()}-${file.name}`,
      url: URL.createObjectURL(file),
      file,
    }));

    setPhotos((prev) => [...prev, ...newPhotos].slice(0, maxPhotos));
    e.target.value = '';
  }

  function removePhoto(id: string) {
    setPhotos((prev) => {
      const removed = prev.find((p) => p.id === id);
      if (removed) URL.revokeObjectURL(removed.url);
      return prev.filter((p) => p.id !== id);
    });
  }

  const slots = Array.from({ length: maxPhotos }, (_, i) => i);

  return (
    <div className={styles.wrap}>
      <div className={styles.labelRow}>
        <span className={styles.label}>{label}</span>
        <span className={styles.count}>{photos.length} / {maxPhotos}</span>
      </div>

      {hint && <p className={styles.hint}>{hint}</p>}

      <div className={styles.grid}>
        {slots.map((i) => {
          const photo = photos[i];
          const isFirst = i === 0;
          const isEmpty = !photo;
          const isAddable = isEmpty && i <= photos.length;

          return (
            <div
              key={i}
              className={[
                styles.slot,
                isAddable ? styles.slotClickable : '',
                photo ? styles.slotFilled : '',
              ].filter(Boolean).join(' ')}
              onClick={() => isAddable && handleSlotClick(i)}
              role={isAddable ? 'button' : undefined}
              tabIndex={isAddable ? 0 : undefined}
              aria-label={isAddable ? `Add photo ${i + 1}` : undefined}
              onKeyDown={(e) => e.key === 'Enter' && isAddable && handleSlotClick(i)}
            >
              {photo ? (
                <>
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={photo.url} alt={`Photo ${i + 1}`} className={styles.preview} />
                  <button
                    type="button"
                    className={styles.removeBtn}
                    onClick={(e) => { e.stopPropagation(); removePhoto(photo.id); }}
                    aria-label={`Remove photo ${i + 1}`}
                  >
                    ×
                  </button>
                  {isFirst && <span className={styles.coverBadge}>COVER</span>}
                </>
              ) : (
                <div className={styles.emptyContent}>
                  <span className={styles.plusIcon}>+</span>
                  {isFirst && <span className={styles.slotLabel}>Cover photo</span>}
                </div>
              )}
            </div>
          );
        })}
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        multiple
        className={styles.hiddenInput}
        onChange={handleFiles}
        aria-hidden
        tabIndex={-1}
      />
    </div>
  );
}
