import { createContext, useContext, useMemo, useRef, useState, type ReactNode } from 'react';
import { fetchNui, useNuiEvent } from '../nui';
import type { Contact, PhoneData } from '../types';
import { usePhone } from './phone';

export type Call = { number: string; name?: string | null; state: 'ringing' | 'active'; incoming: boolean };
export type Card = { name: string; number: string };
export type ChatMessage = { id?: number; body: string; mine: number | boolean; sentAt: number; x?: number | null; y?: number | null; from?: string; name?: string };

type CommsState = {
  call: Call | null;
  callError: string;
  startCall: (number: string) => Promise<void>;
  cards: Card[];
  dismissCard: (card: Card) => void;
  /** The conversation open on screen, so new messages from that number go straight in. */
  openChat: string | null;
  setOpenChat: (number: string | null) => void;
  onChatMessage: React.MutableRefObject<((m: ChatMessage) => void) | null>;
  setContacts: (contacts: Contact[]) => void;
};

const Ctx = createContext<CommsState | null>(null);

export function CommsProvider({ children, visible }: { children: ReactNode; visible: boolean }) {
  const { open, push, route, setPhone, phone, unlock } = usePhone();
  const [call, setCall] = useState<Call | null>(null);
  const [callError, setCallError] = useState('');
  const [cards, setCards] = useState<Card[]>([]);
  const [openChat, setOpenChat] = useState<string | null>(null);
  const onChatMessage = useRef<((m: ChatMessage) => void) | null>(null);

  const showCall = () => {
    unlock();
    open('phone', 'call');
  };

  // The phone was taken out during a call: go straight to it.
  useNuiEvent<{ action: string; data: PhoneData }>('open', () => {
    if (call) setTimeout(showCall, 0);
  });
  useNuiEvent<{ action: string; call: { number: string; name?: string } }>('incomingCall', (m) => {
    setCall({ number: m.call.number, name: m.call.name, state: 'ringing', incoming: true });
    setCallError('');
    if (visible) showCall();
  });
  useNuiEvent('callConnected', () => setCall((c) => (c ? { ...c, state: 'active' } : c)));
  useNuiEvent<{ action: string; reason?: string }>('callEnded', (m) => {
    const onCallScreen = route?.app === 'phone' && route.page === 'call';
    setCall(null);
    if (onCallScreen) {
      setCallError(m.reason || '');
      open('phone');
    }
  });
  useNuiEvent<{ action: string; message: ChatMessage & { from: string } }>('message', ({ message }) => {
    if (visible && openChat === message.from && onChatMessage.current) {
      onChatMessage.current({ ...message, mine: 0 });
      fetchNui('getConversation', openChat); // marks it read
      return;
    }
    setPhone((p) => ({ ...p, unreadMessages: (p.unreadMessages || 0) + 1 }));
    if (visible) fetchNui('notifyMessage', { name: message.name || message.from, body: message.body });
  });
  useNuiEvent<{ action: string; card: Card }>('numberShared', ({ card }) => {
    setCards((list) => [card, ...list.filter((c) => c.number !== card.number)].slice(0, 5));
  });

  const value = useMemo<CommsState>(() => ({
    call,
    callError,
    startCall: async (number: string) => {
      if (!number) return;
      setCallError('');
      const result = await fetchNui<{ number: string; name?: string; error?: string } | false>('startCall', number,
        { number, name: phone?.contacts.find((c) => c.number === number)?.name });
      if (!result || result.error) {
        setCallError((result && result.error) || 'The call could not be placed.');
        open('phone');
        return;
      }
      setCall({ number: result.number, name: result.name, state: 'ringing', incoming: false });
      if (route?.app === 'phone') push('call'); else open('phone', 'call');
    },
    cards,
    dismissCard: (card) => setCards((list) => list.filter((c) => c !== card)),
    openChat,
    setOpenChat,
    onChatMessage,
    setContacts: (contacts) => setPhone((p) => ({ ...p, contacts })),
  }), [call, callError, cards, openChat, phone, route, open, push, setPhone]);

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useComms() {
  const value = useContext(Ctx);
  if (!value) throw new Error('useComms outside CommsProvider');
  return value;
}

export function formatNumber(n?: string | null) {
  if (!n) return '';
  return /^\d{10}$/.test(n) ? `(${n.slice(0, 3)}) ${n.slice(3, 6)}-${n.slice(6)}` : n;
}

export const displayName = (name?: string | null, number?: string | null) => name || formatNumber(number);

export const timeOf = (seconds: number) => new Date(seconds * 1000).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

const AVATAR_COLORS = ['red', 'pink', 'grape', 'violet', 'indigo', 'blue', 'cyan', 'teal', 'green', 'lime', 'yellow', 'orange'];
export function avatarColor(seed: string) {
  let h = 0;
  for (const ch of seed) h = (h * 31 + ch.charCodeAt(0)) >>> 0;
  return AVATAR_COLORS[h % AVATAR_COLORS.length];
}
export function initials(name?: string | null) {
  if (!name) return '#';
  const parts = name.trim().split(/\s+/);
  return ((parts[0]?.[0] || '') + (parts.length > 1 ? parts[parts.length - 1][0] : '')).toUpperCase() || '#';
}
