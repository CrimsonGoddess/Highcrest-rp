export type PhoneSettings = {
  caseColor: string;
  accentColor: string;
  wallpaper: string; // 'preset:<id>' or 'photo:<id>'
};

export type Photo = { id: number; takenAt: number };

export type Wallpaper = { id: string; label: string; css: string };

export type Contact = { id: number; name: string; number: string };

/** What highcrest_phone:server:getPhone returns when the phone opens. */
export type PhoneData = {
  settings: PhoneSettings;
  photos: Photo[];
  phoneNumber: string;
  contacts: Contact[];
  unreadMessages: number;
  unreadMail: number;
  swatches: string[];
  wallpapers: Wallpaper[];
  maxPhotos: number;
};

export type Crop = { x: number; y: number; w: number; h: number };
