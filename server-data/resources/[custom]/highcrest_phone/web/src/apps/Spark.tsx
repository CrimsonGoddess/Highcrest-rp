import { useEffect, useState } from 'react';
import { ActionIcon, Button, Group, NumberInput, Stack, Text, TextInput, Textarea } from '@mantine/core';
import { IconHeart, IconHeartFilled, IconMessageCircle, IconPencil, IconPhone, IconX } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { PhotoAvatar, PhotoField } from '../components/PhotoPicker';
import { fetchNui } from '../nui';
import { usePhoto } from '../photos';
import { useComms } from '../state/comms';
import { usePhone } from '../state/phone';
import { ConfirmButton, Card, ErrorText, SectionTitle, failure, type Result } from '../kit';

type SparkProfile = { id?: number; name: string; age: number | string; bio: string; photoId?: number | null; phone?: string };
type Data = { profile: SparkProfile | null; nextProfile?: SparkProfile | null; matches: SparkProfile[] };

const MOCK: Data = {
  profile: { name: 'Crim', age: 27, bio: 'Night drives and good food.', photoId: 1 },
  nextProfile: { id: 5, name: 'Jamie', age: 25, bio: 'Looking for someone to watch the sunset at Vespucci with.', photoId: 3 },
  matches: [{ id: 6, name: 'Gracie', age: 24, bio: '', photoId: 4, phone: '5554445555' }],
};

function Form({ profile, onSaved }: { profile: SparkProfile | null; onSaved: (d: Data) => void }) {
  const { home } = usePhone();
  const [form, setForm] = useState<SparkProfile>(profile || { name: '', age: '', bio: '', photoId: null });
  const [error, setError] = useState<string | null>(null);
  return (
    <AppPage title={profile ? 'Edit my profile' : 'Join Spark'} subtitle={profile ? undefined : 'Make a profile to start matching'}>
      <Stack gap="sm">
        <TextInput label="Name" maxLength={40} value={form.name} onChange={(e) => setForm({ ...form, name: e.currentTarget.value })} />
        <NumberInput label="Age" min={18} max={120} hideControls value={form.age} onChange={(v) => setForm({ ...form, age: v })} />
        <Textarea label="Bio" maxLength={300} autosize minRows={3} value={form.bio} onChange={(e) => setForm({ ...form, bio: e.currentTarget.value })} />
        <PhotoField value={form.photoId ?? null} onChange={(id) => setForm({ ...form, photoId: id })} />
        <ErrorText>{error}</ErrorText>
        <Button color="pink" onClick={async () => {
          const result = await fetchNui<Result<Data>>('datingSave', form, { ...MOCK, profile: form });
          const err = failure(result);
          setError(err);
          if (!err && result) onSaved(result as Data);
        }}>Save</Button>
        {profile && (
          <ConfirmButton variant="subtle" color="red" confirmLabel="Tap again to delete" label="Delete my profile"
            onConfirm={async () => { await fetchNui('datingDelete', {}, true); home(); }} />
        )}
      </Stack>
    </AppPage>
  );
}

function Candidate({ person, onSwipe }: { person: SparkProfile; onSwipe: (liked: boolean) => void }) {
  const src = usePhoto(person.photoId ?? null);
  const [leaving, setLeaving] = useState<'left' | 'right' | null>(null);
  const swipe = (liked: boolean) => {
    setLeaving(liked ? 'right' : 'left');
    setTimeout(() => onSwipe(liked), 220);
  };
  return (
    <div className={`spark-card ${leaving ? `leave-${leaving}` : ''}`}>
      <div className="spark-photo" style={src ? { backgroundImage: `url("${src}")` } : undefined}>
        <div className="spark-info">
          <Text fw={700} size="xl">{person.name}, {person.age}</Text>
          {person.bio && <Text size="sm" lineClamp={3}>{person.bio}</Text>}
        </div>
      </div>
      <Group justify="center" gap="xl" mt="sm">
        <ActionIcon size={56} radius="xl" variant="light" color="gray" onClick={() => swipe(false)} aria-label="Pass"><IconX size={28} /></ActionIcon>
        <ActionIcon size={56} radius="xl" color="pink" onClick={() => swipe(true)} aria-label="Like"><IconHeartFilled size={26} /></ActionIcon>
      </Group>
    </div>
  );
}

export function SparkApp() {
  const { route, push, open, back } = usePhone();
  const { startCall } = useComms();
  const [data, setData] = useState<Data | null>(null);

  useEffect(() => {
    if (route?.page === 'edit') return;
    fetchNui<Data | false>('datingGet', {}, MOCK).then((d) => { if (d) setData(d); });
  }, [route?.page]);

  if (!data) return <AppPage title="Spark"><span /></AppPage>;
  if (!data.profile || route?.page === 'edit') return <Form profile={data.profile} onSaved={(d) => { setData(d); if (route?.page === 'edit') back(); }} />;

  return (
    <AppPage title="Spark" right={<ActionIcon size="lg" radius="xl" variant="light" color="pink" onClick={() => push('edit')} aria-label="Edit profile"><IconPencil size={18} /></ActionIcon>}>
      <Stack gap="sm">
        {data.nextProfile ? (
          <Candidate key={data.nextProfile.id} person={data.nextProfile} onSwipe={async (liked) => {
            const d = await fetchNui<Data | false>('datingSwipe', { id: data.nextProfile!.id, liked }, { ...MOCK, nextProfile: null });
            if (d) setData(d);
          }} />
        ) : (
          <Card><Stack align="center" gap={4} py="lg"><IconHeart size={36} opacity={0.6} /><Text c="dimmed" size="sm">No one new right now. Check back later.</Text></Stack></Card>
        )}
        <SectionTitle>Matches</SectionTitle>
        {data.matches.length === 0 && <Text size="sm" c="dimmed">No matches yet.</Text>}
        {data.matches.map((m) => (
          <Card key={m.id}>
            <Group wrap="nowrap">
              <PhotoAvatar photoId={m.photoId} name={m.name} size="lg" />
              <Text fw={700} style={{ flex: 1 }}>{m.name}</Text>
              <ActionIcon variant="light" color="green" radius="xl" size="lg" onClick={() => m.phone && startCall(m.phone)}><IconPhone size={18} /></ActionIcon>
              <ActionIcon variant="light" radius="xl" size="lg" onClick={() => m.phone && open('messages', 'chat', { number: m.phone })}><IconMessageCircle size={18} /></ActionIcon>
            </Group>
          </Card>
        ))}
      </Stack>
    </AppPage>
  );
}
