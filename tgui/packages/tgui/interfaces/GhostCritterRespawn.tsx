/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/sovexe)
 * @license ISC
 */

import { Button, ImageButton, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const CRITTER_IMAGE_SIZE = 96;

enum CritterCategory {
  Normal = 'normal',
  Antagonist = 'antagonist',
  Spacebux = 'spacebux',
}

interface CritterBadge {
  color: string;
  icon: string;
  tooltip: string;
}

const CRITTER_BADGES: Record<CritterCategory, CritterBadge | undefined> = {
  [CritterCategory.Normal]: undefined,
  [CritterCategory.Antagonist]: {
    color: 'bad',
    icon: 'a',
    tooltip: 'Antagonist critter',
  },
  [CritterCategory.Spacebux]: {
    color: 'yellow',
    icon: 'star',
    tooltip: 'Unlocked by your Spacebux purchase',
  },
};

interface Critter {
  type: string;
  name: string;
  icon: string | null;
  iconState: string;
  iconDirection: number;
  category: CritterCategory;
}

interface GhostCritterRespawnData {
  critters: Critter[];
}

export const GhostCritterRespawn = () => {
  const { act, data } = useBackend<GhostCritterRespawnData>();

  return (
    <Window width={475} height={data.critters.length > 4 ? 320 : 185}>
      <Window.Content>
        <Section fill scrollable>
          <Stack wrap justify="center">
            {data.critters.map((critter) => {
              const badge = CRITTER_BADGES[critter.category];

              return (
                <Stack.Item key={critter.type}>
                  <ImageButton
                    dmIcon={critter.icon}
                    dmIconState={critter.iconState}
                    dmDirection={critter.iconDirection}
                    imageSize={CRITTER_IMAGE_SIZE}
                    buttons={
                      badge && <Button {...badge} tooltipPosition="top" />
                    }
                    tooltip={`Respawn as ${critter.name}`}
                    onClick={() => act('respawn', { type: critter.type })}
                  >
                    {critter.name}
                  </ImageButton>
                </Stack.Item>
              );
            })}
            {!data.critters.length && (
              <Stack.Item>No critters are available.</Stack.Item>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
