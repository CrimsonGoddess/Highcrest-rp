import { Stack, Text, ThemeIcon } from '@mantine/core';
import type { AppDef } from '../apps/registry';
import { AppPage } from './AppPage';

/** Placeholder for apps that haven't been moved to the new phone yet. */
export function ComingSoon({ app }: { app: AppDef }) {
  const Icon = app.icon;
  return (
    <AppPage title={app.label}>
      <Stack align="center" mt="30%" gap="sm">
        <ThemeIcon size={72} radius={22} style={{ background: `linear-gradient(145deg, ${app.colors[0]}, ${app.colors[1]})` }}>
          <Icon size={38} stroke={1.6} />
        </ThemeIcon>
        <Text fw={700} size="lg">Moving to the new phone</Text>
        <Text size="sm" c="dimmed" ta="center" maw="80%">
          {app.label} is still on the current phone and will be added here soon.
        </Text>
      </Stack>
    </AppPage>
  );
}
