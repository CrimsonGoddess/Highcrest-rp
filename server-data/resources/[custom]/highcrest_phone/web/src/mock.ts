import type { PhoneData } from './types';

// Sample data for the browser preview (npm run dev). Never used in game.
export const mockPhone: PhoneData = {
  settings: { caseColor: '#1C1C22', accentColor: '#C8102E', wallpaper: 'preset:crimson' },
  photos: [
    { id: 1, takenAt: 1762990000 },
    { id: 2, takenAt: 1762980000 },
    { id: 3, takenAt: 1762970000 },
    { id: 4, takenAt: 1762960000 },
  ],
  phoneNumber: '5551234567',
  contacts: [
    { id: 1, name: 'Jamie Cole', number: '5559876543' },
    { id: 2, name: 'Rusty', number: '5552223333' },
    { id: 3, name: 'Gracie', number: '5554445555' },
  ],
  unreadMessages: 3,
  unreadMail: 1,
  swatches: ['#0B0B0D', '#1C1C22', '#F5F5F5', '#C8102E', '#D4AF37', '#1F4E8C', '#1E7A5A', '#6B2FA0', '#E0689A', '#E07A1F'],
  wallpapers: [
    { id: 'crimson', label: 'Crimson', css: 'radial-gradient(circle at 30% 15%, #8a0b20, #2a060c 55%, #0b0b0d)' },
    { id: 'gold', label: 'Gold Leaf', css: 'linear-gradient(155deg, #5c4a12, #1c1c22 60%, #0b0b0d)' },
    { id: 'midnight', label: 'Midnight', css: 'linear-gradient(170deg, #12233f, #0b0b0d 70%)' },
  ],
  maxPhotos: 40,
};
