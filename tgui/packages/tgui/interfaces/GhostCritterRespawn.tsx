import { ImageButton, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const CRITTER_CHOICE_WIDTH = 8;
const CRITTER_IMAGE_SIZE = 64;

interface Critter {
  type: string;
  name: string;
  icon: string | null;
  iconState: string;
  isAntagonist: BooleanLike;
}

interface GhostCritterRespawnData {
  critters: Critter[];
}

export const GhostCritterRespawn = () => {
  const { act, data } = useBackend<GhostCritterRespawnData>();

  return (
    <Window width={460} height={380}>
      <Window.Content>
        <Section title="Available Critters" fill scrollable>
          <Stack wrap justify="center">
            {data.critters.map((critter) => (
              <Stack.Item key={critter.type} width={CRITTER_CHOICE_WIDTH}>
                <Stack vertical align="center">
                  <Stack.Item>
                    <ImageButton
                      dmIcon={critter.icon}
                      dmIconState={critter.iconState}
                      imageSize={CRITTER_IMAGE_SIZE}
                      tooltip={`Respawn as ${critter.name}`}
                      onClick={() => act('respawn', { type: critter.type })}
                    />
                  </Stack.Item>
                  <Stack.Item textAlign="center" preserveWhitespace>
                    <Stack vertical lineHeight={1}>
                      <Stack.Item>{critter.name}</Stack.Item>
                      {!!critter.isAntagonist && (
                        <Stack.Item italic>Antagonist</Stack.Item>
                      )}
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
            {!data.critters.length && (
              <Stack.Item>No critters are available.</Stack.Item>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
