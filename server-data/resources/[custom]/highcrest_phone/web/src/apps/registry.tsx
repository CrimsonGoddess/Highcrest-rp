import type { ComponentType } from 'react';
import {
  IconAddressBook, IconBolt, IconCamera, IconCar, IconCrown, IconDeviceGamepad2, IconHeart, IconHome, IconMail,
  IconMapPin, IconMessageCircle, IconPhone, IconPhoto, IconSettings, IconShoppingBag, IconSpy, IconSteeringWheel,
  IconUrgent, type Icon,
} from '@tabler/icons-react';
import type { PhoneData } from '../types';
import { SettingsApp } from './Settings';
import { GalleryApp } from './Gallery';
import { CameraApp } from './Camera';

export type AppDef = {
  id: string;
  label: string;
  icon: Icon;
  /** Icon tile gradient [from, to]. */
  colors: [string, string];
  /** The app's screen. Apps without one are still on the old phone (shown as "coming soon"). */
  component?: ComponentType;
  /** Show in the dock at the bottom of the home screen instead of the grid. */
  dock?: boolean;
  badge?: (phone: PhoneData) => number;
  /** Opening it does something other than showing a page (the camera). */
  fullscreen?: boolean;
};

export const APPS: AppDef[] = [
  { id: 'phone', label: 'Phone', icon: IconPhone, colors: ['#3ddc84', '#1e9e57'], dock: true },
  { id: 'messages', label: 'Messages', icon: IconMessageCircle, colors: ['#4cd964', '#1f8f3a'], dock: true, badge: (p) => p.unreadMessages },
  { id: 'contacts', label: 'Contacts', icon: IconAddressBook, colors: ['#9aa0a6', '#5f6368'] },
  { id: 'camera', label: 'Camera', icon: IconCamera, colors: ['#3a3d44', '#16171b'], dock: true, component: CameraApp, fullscreen: true },
  { id: 'gallery', label: 'Gallery', icon: IconPhoto, colors: ['#ffb347', '#e0479e'], component: GalleryApp },
  { id: 'pulse', label: 'Pulse', icon: IconBolt, colors: ['#ff4d6d', '#8a0b20'] },
  { id: 'market', label: 'Market', icon: IconShoppingBag, colors: ['#ffa94d', '#e8590c'] },
  { id: 'spark', label: 'Spark', icon: IconHeart, colors: ['#ff8fab', '#d6336c'] },
  { id: 'darkweb', label: 'Darkweb', icon: IconSpy, colors: ['#2b2b30', '#050506'] },
  { id: 'empire', label: 'Empire', icon: IconCrown, colors: ['#f2d16b', '#a8811c'] },
  { id: 'housing', label: 'Housing', icon: IconHome, colors: ['#74c0fc', '#1c64c8'] },
  { id: 'mail', label: 'Mail', icon: IconMail, colors: ['#5eb0ff', '#1f4e8c'], badge: (p) => p.unreadMail },
  { id: 'garage', label: 'Garage', icon: IconCar, colors: ['#868e96', '#343a40'] },
  { id: 'findFriends', label: 'Find Friends', icon: IconMapPin, colors: ['#69db7c', '#2b8a3e'] },
  { id: 'taxi', label: 'Taxi', icon: IconSteeringWheel, colors: ['#ffe066', '#f59f00'] },
  { id: 'emergency', label: '911', icon: IconUrgent, colors: ['#ff6b6b', '#c8102e'] },
  { id: 'snake', label: 'Snake', icon: IconDeviceGamepad2, colors: ['#a9e34b', '#5c940d'] },
  { id: 'settings', label: 'Settings', icon: IconSettings, colors: ['#adb5bd', '#495057'], dock: true, component: SettingsApp },
];

export const appById = (id: string) => APPS.find((app) => app.id === id);
