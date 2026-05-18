'use client';

import { useState } from 'react';
import Link from 'next/link';
import styles from './page.module.css';

interface ChatThread {
  id: string;
  name: string;
  initials: string;
  lastMessage: string;
  product: string;
  timeAgo: string;
  unread: number;
}

const SEED_CHATS: ChatThread[] = [
  { id: 'ravi-kumar', name: 'Ravi Kumar', initials: 'RK', lastMessage: 'Is the bike still available?', product: 'Triumph Street Twin', timeAgo: '5 min ago', unread: 2 },
  { id: 'priya-sharma', name: 'Priya Sharma', initials: 'PS', lastMessage: 'Can you do 45k?', product: 'Arai RX-7V Helmet', timeAgo: '2 hours ago', unread: 0 },
  { id: 'garageone', name: 'GarageOne Performance', initials: 'GP', lastMessage: 'Appointment confirmed for Saturday', product: 'Service', timeAgo: '1 day ago', unread: 0 },
  { id: 'vikram-singh', name: 'Vikram Singh', initials: 'VS', lastMessage: "What's the last price?", product: 'KTM 390 Duke', timeAgo: '3 days ago', unread: 1 },
];

type Tab = 'messages' | 'support';

export default function ChatListPage() {
  const [activeTab, setActiveTab] = useState<Tab>('messages');

  return (
    <div className={styles.page}>
      <h1 className={styles.title}>Chat</h1>

      <div className={styles.tabs}>
        <button
          className={[styles.tab, activeTab === 'messages' ? styles.tabActive : ''].join(' ')}
          onClick={() => setActiveTab('messages')}
        >
          Messages
        </button>
        <button
          className={[styles.tab, activeTab === 'support' ? styles.tabActive : ''].join(' ')}
          onClick={() => setActiveTab('support')}
        >
          Support
        </button>
      </div>

      {activeTab === 'messages' && (
        <div className={styles.list}>
          {SEED_CHATS.map((chat) => (
            <Link key={chat.id} href={`/chat/${chat.id}`} className={styles.row}>
              <div className={styles.avatar}>{chat.initials}</div>
              <div className={styles.center}>
                <p className={styles.name}>{chat.name}</p>
                <p className={styles.lastMsg}>{chat.lastMessage}</p>
                <span className={styles.productTag}>{chat.product}</span>
              </div>
              <div className={styles.right}>
                <span className={styles.timestamp}>{chat.timeAgo}</span>
                {chat.unread > 0 && (
                  <span className={styles.badge}>{chat.unread}</span>
                )}
              </div>
            </Link>
          ))}
        </div>
      )}

      {activeTab === 'support' && (
        <div className={styles.list}>
          <Link href="/chat/support" className={styles.row}>
            <div className={styles.avatar} style={{ background: 'var(--bv-green)', color: 'var(--bv-green-ink)', fontSize: 12 }}>BV</div>
            <div className={styles.center}>
              <p className={styles.name}>Bikerverse Support</p>
              <p className={styles.supportSubtitle}>Ask us anything</p>
            </div>
          </Link>
        </div>
      )}
    </div>
  );
}
