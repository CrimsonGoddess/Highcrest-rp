import { useEffect, useRef } from 'react';
import { Kbd, Text } from '@mantine/core';
import { appById } from '../apps/registry';
import { usePhoto } from '../photos';
import { IconPhone } from '@tabler/icons-react';
import { useCamera } from '../state/camera';
import { displayName, useComms } from '../state/comms';
import { usePhone } from '../state/phone';
import { ComingSoon } from './ComingSoon';
import { HomeScreen } from './HomeScreen';
import { LockScreen } from './LockScreen';
import { StatusBar } from './StatusBar';

function useWallpaper(): string {
  const { phone } = usePhone();
  const [kind, value] = (phone?.settings.wallpaper || 'preset:').split(':');
  const photo = usePhoto(kind === 'photo' ? Number(value) : null);
  if (kind === 'photo') return photo ? `url("${photo}") center / cover no-repeat` : '#0b0b0d';
  return phone?.wallpapers.find((w) => w.id === value)?.css || '#0b0b0d';
}

/** A green pill at the top while on a call in another app. Tap to go back to the call. */
function CallStrip() {
  const { call } = useComms();
  const { route, open, locked } = usePhone();
  if (!call || locked || (route?.app === 'phone' && route.page === 'call')) return null;
  return (
    <button className="call-strip" onClick={() => open('phone', 'call')}>
      <IconPhone size={14} /> {call.state === 'active' ? 'On a call' : call.incoming ? 'Incoming call' : 'Calling'} · {displayName(call.name, call.number)}
    </button>
  );
}

function Content() {
  const { route, locked } = usePhone();
  if (locked) return <LockScreen />;
  if (!route) return <HomeScreen />;
  const app = appById(route.app);
  if (!app) return <HomeScreen />;
  const Screen = app.component;
  return (
    <div className="app-screen" key={route.app}>
      {Screen ? <Screen /> : <ComingSoon app={app} />}
    </div>
  );
}

export function Phone() {
  const { phone, home, locked } = usePhone();
  const camera = useCamera();
  const wallpaper = useWallpaper();
  const flashRef = useRef<HTMLDivElement>(null);

  // Restart the flash animation each time a photo is taken.
  useEffect(() => {
    const el = flashRef.current;
    if (!el || camera.flashKey === 0) return;
    el.classList.remove('go');
    void el.offsetWidth;
    el.classList.add('go');
  }, [camera.flashKey]);

  if (!phone) return null;
  const classes = ['phone', camera.active && 'camera', camera.active && camera.landscape && 'landscape'].filter(Boolean).join(' ');

  return (
    <>
      <div className={classes} style={{ ['--case' as string]: phone.settings.caseColor }}>
        <span className="side-button power" />
        <span className="side-button volume" />
        <div className="screen" style={{ background: camera.active ? 'transparent' : wallpaper }}>
          {!camera.active && <StatusBar hideClock={locked} />}
          {!camera.active && <CallStrip />}
          <div className="content"><Content /></div>
          {!camera.active && !locked && <button className="home-indicator" onClick={home} aria-label="Home" />}
          <div ref={flashRef} className="flash" />
        </div>
      </div>

      {camera.active && (
        <div className="camera-bar">
          <Text size="sm" c="gold.6" mih="1.2em">{camera.message}</Text>
          <Text size="xs">
            <Kbd>Enter</Kbd> Photo <Kbd>Scroll</Kbd> / <Kbd>Q</Kbd><Kbd>E</Kbd> Zoom <Kbd>L</Kbd> Rotate <Kbd>↑</Kbd> Selfie{' '}
            {camera.pose && <><Kbd>←</Kbd><Kbd>→</Kbd> Pose: <b className="gold">{camera.pose}</b>{' '}</>}
            <Kbd>Backspace</Kbd> Exit
          </Text>
        </div>
      )}
    </>
  );
}
