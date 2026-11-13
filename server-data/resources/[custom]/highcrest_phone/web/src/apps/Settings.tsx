import { ColorInput, Group, Paper, SimpleGrid, Stack, Text, UnstyledButton } from '@mantine/core';
import { IconCheck, IconPhone } from '@tabler/icons-react';
import { AppPage } from '../components/AppPage';
import { usePhone } from '../state/phone';
import { contrastText } from '../theme';

function formatNumber(n: string) {
  return n.length === 10 ? `(${n.slice(0, 3)}) ${n.slice(3, 6)}-${n.slice(6)}` : n;
}

function Swatches({ value, colors, onPick }: { value: string; colors: string[]; onPick: (c: string) => void }) {
  return (
    <Group gap={8}>
      {colors.map((color) => {
        const on = value.toLowerCase() === color.toLowerCase();
        return (
          <UnstyledButton key={color} className={`swatch ${on ? 'on' : ''}`} style={{ background: color }} onClick={() => onPick(color)} aria-label={color}>
            {on && <IconCheck size={16} color={contrastText(color)} />}
          </UnstyledButton>
        );
      })}
    </Group>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Paper className="glass" p="md" radius="lg">
      <Text size="xs" tt="uppercase" fw={700} c="dimmed" mb="xs" style={{ letterSpacing: '0.08em' }}>{title}</Text>
      {children}
    </Paper>
  );
}

export function SettingsApp() {
  const { phone, saveSettings } = usePhone();
  if (!phone) return null;
  const { settings } = phone;

  return (
    <AppPage title="Settings">
      <Stack gap="md">
        <Section title="My number">
          <Group gap="xs"><IconPhone size={18} /><Text fw={700} size="lg">{formatNumber(phone.phoneNumber || '')}</Text></Group>
        </Section>

        <Section title="Phone colour">
          <Swatches value={settings.caseColor} colors={phone.swatches} onPick={(c) => saveSettings({ caseColor: c })} />
          <ColorInput mt="sm" size="xs" label="Custom" value={settings.caseColor} format="hex" withEyeDropper={false}
            onChangeEnd={(c) => saveSettings({ caseColor: c.toUpperCase() })} />
        </Section>

        <Section title="Accent colour">
          <Swatches value={settings.accentColor} colors={phone.swatches} onPick={(c) => saveSettings({ accentColor: c })} />
          <ColorInput mt="sm" size="xs" label="Custom" value={settings.accentColor} format="hex" withEyeDropper={false}
            onChangeEnd={(c) => saveSettings({ accentColor: c.toUpperCase() })} />
        </Section>

        <Section title="Wallpaper">
          <SimpleGrid cols={3} spacing={8}>
            {phone.wallpapers.map((w) => {
              const on = settings.wallpaper === `preset:${w.id}`;
              return (
                <UnstyledButton key={w.id} className={`wallpaper-tile ${on ? 'on' : ''}`} style={{ background: w.css }}
                  onClick={() => saveSettings({ wallpaper: `preset:${w.id}` })}>
                  <span>{w.label}</span>
                </UnstyledButton>
              );
            })}
          </SimpleGrid>
          <Text size="xs" c="dimmed" mt="xs">To use a photo, open it in Gallery and tap "Set as wallpaper".</Text>
        </Section>
      </Stack>
    </AppPage>
  );
}
