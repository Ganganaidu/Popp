'use client';

import { useState } from 'react';
import styles from './page.module.css';

type NotifType = 'approved' | 'rejected' | 'sent_back' | 'chat' | 'new_submission';

interface Notification {
  id: string;
  type: NotifType;
  title: string;
  body: string;
  timeAgo: string;
  unread: boolean;
}

const SEED: Notification[] = [
  { id: '1', type: 'approved', title: 'Your listing was approved', body: 'Your listing is now live on Bikerverse.', timeAgo: '5 min ago', unread: true },
  { id: '2', type: 'chat', title: 'New message from Ravi Kumar', body: 'Is the bike still available?', timeAgo: '12 min ago', unread: true },
  { id: '3', type: 'sent_back', title: 'Your listing was sent back for revision', body: 'Please update the description and photos.', timeAgo: '1 hour ago', unread: true },
  { id: '4', type: 'new_submission', title: 'Triumph Street Twin listed successfully', body: 'Your listing is under review.', timeAgo: '3 hours ago', unread: false },
  { id: '5', type: 'approved', title: 'Your Kawasaki listing was approved', body: 'Ninja Z900 is now live on Bikerverse.', timeAgo: '1 day ago', unread: false },
  { id: '6', type: 'chat', title: 'New message from GarageOne Performance', body: 'Appointment confirmed for Saturday.', timeAgo: '2 days ago', unread: false },
  { id: '7', type: 'rejected', title: 'Your service listing was rejected', body: 'Listing did not meet quality guidelines.', timeAgo: '3 days ago', unread: false },
  { id: '8', type: 'new_submission', title: 'Welcome to Bikerverse!', body: 'Start buying, selling, or listing services.', timeAgo: '5 days ago', unread: false },
];

const TYPE_STYLES: Record<NotifType, { bg: string; icon: string }> = {
  approved: { bg: '#16a34a22', icon: '✓' },
  rejected: { bg: '#dc262622', icon: '✕' },
  sent_back: { bg: '#d9770622', icon: '↩' },
  chat: { bg: '#2563eb22', icon: '💬' },
  new_submission: { bg: 'var(--bv-surface-hi)', icon: '🔔' },
};

const TYPE_ICON_COLOR: Record<NotifType, string> = {
  approved: '#16a34a',
  rejected: '#dc2626',
  sent_back: '#d97706',
  chat: '#2563eb',
  new_submission: 'var(--bv-text-3)',
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>(SEED);

  function markAllRead() {
    setNotifications((prev) => prev.map((n) => ({ ...n, unread: false })));
  }

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <h1 className={styles.title}>Notifications</h1>
        <button className={styles.markAll} onClick={markAllRead}>
          Mark all as read
        </button>
      </div>

      <div className={styles.list}>
        {notifications.map((n) => {
          const ts = TYPE_STYLES[n.type];
          const iconColor = TYPE_ICON_COLOR[n.type];
          return (
            <div key={n.id} className={styles.row}>
              <div
                className={styles.iconWrap}
                style={{ background: ts.bg, color: iconColor }}
              >
                {ts.icon}
              </div>
              <div className={styles.content}>
                <p className={styles.rowTitle}>{n.title}</p>
                <p className={styles.rowBody}>{n.body}</p>
                <span className={styles.rowTime}>{n.timeAgo}</span>
              </div>
              <div className={styles.rightSide}>
                {n.unread && <span className={styles.unreadDot} aria-label="Unread" />}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
