import { useCallback, useEffect, useState } from 'react';
import { MantineProvider } from '@mantine/core';
import { viewfinderCrop } from './apps/Camera';
import { EmergencyAlert } from './components/EmergencyAlert';
import { Phone } from './components/Phone';
import { mockPhone } from './mock';
import { fetchNui, isBrowser, mockMessage, useNuiEvent } from './nui';
import { cropPhoto, finishPhoto } from './photos';
import { CameraProvider, useCamera } from './state/camera';
import { PhoneProvider, usePhone } from './state/phone';
import { makeTheme } from './theme';
import type { Crop, Photo, PhoneData } from './types';

/** Listens to the game and keeps the phone state in step. */
function Bridge({ setVisible }: { setVisible: (v: boolean) => void }) {
  const { load, setClock, back, home, setPhone, route } = usePhone();
  const camera = useCamera();

  useNuiEvent<{ action: string; data: PhoneData }>('open', (m) => {
    load(m.data);
    camera.set({ active: false, landscape: false, message: '', pose: null });
    setVisible(true);
  });
  useNuiEvent<{ action: string; hours: number; minutes: number }>('clock', (m) => setClock(m.hours, m.minutes));
  useNuiEvent<{ action: string; id: number; src: string; crop?: Crop }>('photo', (m) => {
    cropPhoto(m.src, m.crop).then((src) => finishPhoto(m.id, src));
  });
  useNuiEvent<{ action: string; result?: { error?: string; photo?: Photo } }>('captured', ({ result }) => {
    if (!result || result.error || !result.photo) {
      camera.set({ message: result?.error || 'The photo could not be saved.' });
      return;
    }
    const photo = result.photo;
    setPhone((p) => ({ ...p, photos: [photo, ...p.photos] }));
    camera.set({ message: 'Saved to Gallery' });
    camera.flash();
  });
  useNuiEvent('cameraClosed', () => {
    camera.set({ active: false, landscape: false, pose: null });
    home();
  });
  useNuiEvent('cameraRotate', () => {
    camera.set({ landscape: !camera.landscape });
    setTimeout(() => fetchNui('cameraCrop', { crop: viewfinderCrop() }), 80);
  });
  useNuiEvent<{ action: string; label?: string }>('cameraPose', (m) => camera.set({ pose: m.label || null }));
  useNuiEvent<{ action: string; count?: number }>('newMail', () => setPhone((p) => ({ ...p, unreadMail: (p.unreadMail || 0) + 1 })));

  // Esc goes back a screen (and closes the phone from the home screen).
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key !== 'Escape' || camera.active) return;
      const t = e.target as HTMLElement | null;
      if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA')) return (t as HTMLInputElement).blur();
      back();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [back, camera.active, route]);

  return null;
}

function Themed({ visible, setVisible }: { visible: boolean; setVisible: (v: boolean) => void }) {
  const { phone } = usePhone();
  return (
    <MantineProvider theme={makeTheme(phone?.settings.accentColor || '#C8102E')} forceColorScheme="dark">
      <Bridge setVisible={setVisible} />
      {visible && <Phone />}
      <EmergencyAlert />
    </MantineProvider>
  );
}

export default function App() {
  const [visible, setVisible] = useState(false);
  const onClose = useCallback(() => {
    setVisible(false);
    // In the browser preview, bring the phone straight back.
    if (isBrowser) mockMessage({ action: 'open', data: mockPhone }, 600);
  }, []);

  useEffect(() => {
    if (!isBrowser) return;
    document.body.classList.add('preview');
    mockMessage({ action: 'clock', hours: 21, minutes: 47 });
    mockMessage({ action: 'open', data: mockPhone }, 50);
  }, []);

  return (
    <CameraProvider>
      <PhoneProvider onClose={onClose}>
        <Themed visible={visible} setVisible={setVisible} />
      </PhoneProvider>
    </CameraProvider>
  );
}
