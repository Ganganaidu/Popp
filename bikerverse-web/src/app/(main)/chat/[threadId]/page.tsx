'use client';

import { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import styles from './page.module.css';

interface Message {
  id: string;
  text: string;
  direction: 'sent' | 'received';
  time: string;
  date: string;
}

const SEED_MESSAGES: Message[] = [
  { id: '1', text: 'Is the Triumph Street Twin still available?', direction: 'received', time: '10:02 AM', date: 'TODAY' },
  { id: '2', text: 'Yes, it is! One careful owner.', direction: 'sent', time: '10:05 AM', date: 'TODAY' },
  { id: '3', text: "What's the lowest you'd go?", direction: 'received', time: '10:07 AM', date: 'TODAY' },
  { id: '4', text: 'I can do 7 lakhs for a quick sale.', direction: 'sent', time: '10:09 AM', date: 'TODAY' },
  { id: '5', text: 'Can I come see it this weekend?', direction: 'received', time: '10:11 AM', date: 'TODAY' },
  { id: '6', text: 'Sure, Saturday works. Jubilee Hills.', direction: 'sent', time: '10:12 AM', date: 'TODAY' },
];

const THREAD_META: Record<string, { name: string; product: string }> = {
  'ravi-kumar': { name: 'Ravi Kumar', product: 'Triumph Street Twin' },
  'priya-sharma': { name: 'Priya Sharma', product: 'Arai RX-7V Helmet' },
  'garageone': { name: 'GarageOne Performance', product: 'Service Appointment' },
  'vikram-singh': { name: 'Vikram Singh', product: 'KTM 390 Duke' },
  'support': { name: 'Bikerverse Support', product: 'Help & Support' },
};

interface PageProps {
  params: { threadId: string };
}

function now(): string {
  const d = new Date();
  let h = d.getHours();
  const m = d.getMinutes().toString().padStart(2, '0');
  const ampm = h >= 12 ? 'PM' : 'AM';
  h = h % 12 || 12;
  return `${h}:${m} ${ampm}`;
}

export default function ChatThreadPage({ params }: PageProps) {
  const { threadId } = params;
  const meta = THREAD_META[threadId] ?? { name: threadId, product: '' };
  const router = useRouter();

  const [messages, setMessages] = useState<Message[]>(SEED_MESSAGES);
  const [input, setInput] = useState('');
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  function sendMessage() {
    const text = input.trim();
    if (!text) return;
    setMessages((prev) => [
      ...prev,
      { id: String(Date.now()), text, direction: 'sent', time: now(), date: 'TODAY' },
    ]);
    setInput('');
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  }

  // Group messages by date separators
  let lastDate = '';

  return (
    <div className={styles.shell}>
      {/* Header */}
      <div className={styles.header}>
        <button className={styles.backBtn} onClick={() => router.back()} aria-label="Go back">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M12 5L7 10L12 15" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <div className={styles.headerInfo}>
          <p className={styles.headerName}>{meta.name}</p>
          {meta.product && <p className={styles.headerProduct}>{meta.product}</p>}
        </div>
      </div>

      {/* Message list */}
      <div className={styles.messageList}>
        {messages.map((msg) => {
          const showDate = msg.date !== lastDate;
          lastDate = msg.date;
          return (
            <div key={msg.id}>
              {showDate && <div className={styles.dateSep}>{msg.date}</div>}
              <div className={[styles.msgRow, msg.direction === 'sent' ? styles.msgRowSent : styles.msgRowReceived].join(' ')}>
                <div className={[styles.bubble, msg.direction === 'sent' ? styles.bubbleSent : styles.bubbleReceived].join(' ')}>
                  <p className={styles.bubbleText}>{msg.text}</p>
                  <span className={styles.bubbleTime}>{msg.time}</span>
                </div>
              </div>
            </div>
          );
        })}
        <div ref={bottomRef} />
      </div>

      {/* Input bar */}
      <div className={styles.inputBar}>
        <input
          className={styles.input}
          type="text"
          placeholder="Type a message…"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
        />
        <button className={styles.sendBtn} onClick={sendMessage} disabled={!input.trim()} aria-label="Send message">
          <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
            <path d="M3 9L15 9M15 9L10 4M15 9L10 14" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
      </div>
    </div>
  );
}
