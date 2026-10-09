/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/sovexe)
 * @license ISC
 */

import { Button, ImageButton, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const CRITTER_IMAGE_SIZE = 96;

interface Critter {
  type: string;
  name: string;
  icon: string | null;
  iconState: string;
  iconDirection: number;
  isAntagonist: BooleanLike;
  isPremium: BooleanLike;
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
            {data.critters.map((critter) => (
              <Stack.Item key={critter.type}>
                <ImageButton
                  dmIcon={critter.icon}
                  dmIconState={critter.iconState}
                  dmDirection={critter.iconDirection}
                  imageSize={CRITTER_IMAGE_SIZE}
                  buttons={
                    (!!critter.isAntagonist || !!critter.isPremium) && (
                      <Button
                        color={critter.isAntagonist ? 'bad' : 'yellow'}
                        icon={critter.isAntagonist ? 'a' : 'star'}
                        tooltip={
                          critter.isAntagonist
                            ? 'Antagonist critter'
                            : 'Unlocked by your Spacebux purchase'
                        }
                        tooltipPosition="top"
                      />
                    )
                  }
                  tooltip={`Respawn as ${critter.name}`}
                  onClick={() => act('respawn', { type: critter.type })}
                >
                  {critter.name}
                </ImageButton>
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
