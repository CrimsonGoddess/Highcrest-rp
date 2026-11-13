import { useState } from 'react';
import { ActionIcon, Avatar, Button, Group, Image, Loader, SimpleGrid, Text, UnstyledButton, type AvatarProps } from '@mantine/core';
import { IconPhotoPlus, IconX } from '@tabler/icons-react';
import { usePhoto } from '../photos';
import { usePhone } from '../state/phone';

function PickTile({ id, onPick }: { id: number; onPick: (id: number) => void }) {
  const src = usePhoto(id);
  return (
    <UnstyledButton className="thumb" style={src ? { backgroundImage: `url("${src}")` } : undefined} onClick={() => onPick(id)}>
      {!src && <Loader size="xs" color="gray" />}
    </UnstyledButton>
  );
}

/** Choose one of your gallery photos, shown as a sheet over the app. */
export function PhotoSheet({ onPick, onClose }: { onPick: (id: number) => void; onClose: () => void }) {
  const { phone } = usePhone();
  const photos = phone?.photos || [];
  return (
    <div className="sheet-backdrop" onClick={onClose}>
      <div className="sheet" onClick={(e) => e.stopPropagation()}>
        <Group justify="space-between" mb="sm">
          <Text fw={700}>Choose a photo</Text>
          <ActionIcon variant="subtle" color="gray" radius="xl" onClick={onClose}><IconX size={18} /></ActionIcon>
        </Group>
        {photos.length === 0
          ? <Text c="dimmed" size="sm" ta="center" my="lg">No photos yet. Take one with the Camera.</Text>
          : <SimpleGrid cols={3} spacing={4}>{photos.map((p) => <PickTile key={p.id} id={p.id} onPick={(id) => { onPick(id); onClose(); }} />)}</SimpleGrid>}
      </div>
    </div>
  );
}

/** "Add photo" button with a small preview of the chosen photo. */
export function PhotoField({ value, onChange, label = 'Add photo' }: { value: number | null; onChange: (id: number | null) => void; label?: string }) {
  const [open, setOpen] = useState(false);
  const src = usePhoto(value);
  return (
    <>
      {value != null ? (
        <div className="photo-field">
          {src ? <Image src={src} radius="md" mah={160} fit="cover" /> : <Loader size="sm" />}
          <ActionIcon className="photo-field-x" radius="xl" color="dark" onClick={() => onChange(null)}><IconX size={14} /></ActionIcon>
        </div>
      ) : (
        <Button variant="light" color="gray" leftSection={<IconPhotoPlus size={18} />} onClick={() => setOpen(true)}>{label}</Button>
      )}
      {open && <PhotoSheet onPick={onChange} onClose={() => setOpen(false)} />}
    </>
  );
}

/** A photo from the gallery, shown in a post or listing. */
export function PostPhoto({ id }: { id: number }) {
  const src = usePhoto(id);
  return src ? <Image src={src} radius="md" mt="xs" /> : <div className="photo-loading"><Loader size="sm" color="gray" /></div>;
}

/** Avatar that shows a gallery photo when there is one, else initials. */
export function PhotoAvatar({ photoId, name, ...props }: { photoId?: number | null; name?: string } & AvatarProps) {
  const src = usePhoto(photoId ?? null);
  return <Avatar src={src || undefined} radius="xl" {...props}>{(name || '?').charAt(0).toUpperCase()}</Avatar>;
}
