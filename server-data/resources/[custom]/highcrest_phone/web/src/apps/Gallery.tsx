import { useState } from 'react';
import { Badge, Button, Center, Image, Loader, SimpleGrid, Stack, Text, UnstyledButton } from '@mantine/core';
import { IconPhotoOff, IconTrash, IconWallpaper } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { fetchNui, isBrowser } from '../nui';
import { forgetPhoto, usePhoto } from '../photos';
import { usePhone } from '../state/phone';
import type { Photo, PhoneSettings } from '../types';

function Thumb({ photo }: { photo: Photo }) {
  const { push } = usePhone();
  const src = usePhoto(photo.id);
  return (
    <UnstyledButton className="thumb" style={src ? { backgroundImage: `url("${src}")` } : undefined}
      onClick={() => push('viewer', { id: photo.id })}>
      {!src && <Loader size="xs" color="gray" />}
    </UnstyledButton>
  );
}

function Viewer({ id }: { id: number }) {
  const { phone, setPhone, saveSettings, back, home } = usePhone();
  const src = usePhoto(id);
  const [armed, setArmed] = useState(false);
  const photo = phone?.photos.find((p) => p.id === id);

  const remove = async () => {
    if (!armed) return setArmed(true);
    const settings = await fetchNui<PhoneSettings | false>('deletePhoto', { id }, phone?.settings);
    if (!settings && !isBrowser) return setArmed(false);
    forgetPhoto(id);
    setPhone((p) => ({ ...p, settings: settings || p.settings, photos: p.photos.filter((x) => x.id !== id) }));
    back();
  };

  return (
    <AppPage title="Photo" subtitle={photo ? new Date(photo.takenAt * 1000).toLocaleString() : undefined}>
      <Stack gap="sm">
        <div className="viewer-frame">
          {src ? <Image src={src} radius="md" /> : <Center h={300}><Loader color="gray" /></Center>}
        </div>
        <Button leftSection={<IconWallpaper size={18} />} onClick={() => { saveSettings({ wallpaper: `photo:${id}` }); home(); }}>
          Set as wallpaper
        </Button>
        <Button variant={armed ? 'filled' : 'light'} color={armed ? 'red' : 'gray'} leftSection={<IconTrash size={18} />} onClick={remove}>
          {armed ? 'Tap again to delete' : 'Delete'}
        </Button>
      </Stack>
    </AppPage>
  );
}

export function GalleryApp() {
  const { phone, route } = usePhone();
  if (!phone) return null;
  if (route?.page === 'viewer') return <Viewer id={Number(route.params?.id)} />;

  return (
    <AppPage title="Gallery" right={<Badge variant="light" color="gray">{phone.photos.length} / {phone.maxPhotos}</Badge>}>
      {phone.photos.length === 0 ? (
        <Stack align="center" mt="35%" gap={6}>
          <IconPhotoOff size={44} opacity={0.5} />
          <Text c="dimmed" size="sm" ta="center">No photos yet. Open the Camera to take one.</Text>
        </Stack>
      ) : (
        <SimpleGrid cols={3} spacing={4}>
          {phone.photos.map((photo) => <Thumb key={photo.id} photo={photo} />)}
        </SimpleGrid>
      )}
    </AppPage>
  );
}
