import { useEffect } from 'react';
import { Text } from '@mantine/core';
import { fetchNui, isBrowser } from '../nui';
import { useCamera } from '../state/camera';
import type { Crop } from '../types';

/** Where the phone screen is, as fractions of the game screen. The photo is cropped to this. */
export function viewfinderCrop(): Crop | null {
  const screen = document.querySelector('.screen');
  if (!screen) return null;
  const rect = screen.getBoundingClientRect();
  return { x: rect.left / window.innerWidth, y: rect.top / window.innerHeight, w: rect.width / window.innerWidth, h: rect.height / window.innerHeight };
}

/** The camera: the phone moves to the centre and becomes a see-through viewfinder; Lua runs the game camera. */
export function CameraApp() {
  const camera = useCamera();

  useEffect(() => {
    camera.set({ active: true, landscape: false, message: isBrowser ? 'Browser preview: no game camera here' : '', pose: null });
    // Wait for the phone to move into position, then tell the game where the viewfinder is.
    const timer = setTimeout(() => fetchNui('startCamera', { crop: viewfinderCrop() }), 80);
    return () => clearTimeout(timer);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="camera-view">
      <div className="camera-grid" />
      <Text className="camera-message">{camera.message}</Text>
    </div>
  );
}
