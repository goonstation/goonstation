/**
 * @file
 * @copyright 2020, 2026
 * @author Original ZeWaka (https://github.com/ZeWaka)
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SoundLibraryRow } from './SoundLibraryRow';
import type { DJPanelData } from './types';

export const SoundLibrary = () => {
  const { act, data } = useBackend<DJPanelData>();
  const { sounds, soundsEnabled } = data;
  const [search, setSearch] = useState('');
  const matchingSounds = sounds.filter(({ name }) =>
    name.toLowerCase().includes(search.trim().toLowerCase()),
  );
  return (
    <Section fill title="Sound Library">
      <Stack vertical fill>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item>
              <Button
                bold
                icon="upload"
                color="blue"
                disabled={!soundsEnabled}
                tooltip="Add to the shared library"
                onClick={() => act('set-file')}
              >
                Upload sound
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Input
                fluid
                placeholder="Search..."
                value={search}
                onChange={setSearch}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow minHeight={0} overflowY="auto">
          <Stack vertical>
            {matchingSounds.map((sound) => (
              <Stack.Item key={sound.name}>
                <SoundLibraryRow sound={sound} />
              </Stack.Item>
            ))}
          </Stack>
          {!matchingSounds.length && (
            <Box color="label" textAlign="center">
              {sounds.length
                ? 'No sounds match your search.'
                : 'No sounds uploaded.'}
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
