/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import {
  Box,
  Button,
  NumberInput,
  Section,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ReagentList } from './common/ReagentInfo';

interface PrecipitationData {
  containerData;
  cooldown;
  poolDepth;
  probability;
}

export const Precipitation = () => {
  const { act, data } = useBackend<PrecipitationData>();
  const { probability, cooldown, poolDepth, containerData } = data;

  return (
    <Window title="Precipitation" width={300} height={425}>
      <Window.Content scrollable>
        <Section title="Precipitation">
          <Tooltip content="Cooldown for how fast ATOMs can be rained on.">
            <Box m={1}>
              Cooldown
              <NumberInput
                value={cooldown}
                width={'4'}
                minValue={0}
                maxValue={Infinity}
                step={1}
                onChange={(value) => {
                  act('set-cooldown', {
                    value,
                  });
                }}
              />
            </Box>
          </Tooltip>
          <Tooltip content="Chance of being rained on entering turf.">
            <Box m={1}>
              Probability
              <NumberInput
                value={probability}
                width={'4'}
                minValue={0}
                maxValue={100}
                step={1}
                onChange={(value) => {
                  act('set-probability', {
                    value,
                  });
                }}
              />
            </Box>
          </Tooltip>

          <Tooltip content="Maximum fluid size/depth on the tile. (0 means no pooling will form)">
            <Box m={1}>
              Maximum Pool Depth
              <NumberInput
                value={poolDepth}
                width={'4'}
                minValue={0}
                maxValue={100}
                step={1}
                onChange={(value) => {
                  act('set-poolDepth', {
                    value,
                  });
                }}
              />
            </Box>
          </Tooltip>

          <Section title="Reagents">
            <ReagentList
              container={containerData}
              renderButtons={(reagent) => {
                return (
                  <>
                    <Button
                      px={0.75}
                      mr={1.5}
                      icon="filter"
                      color="red"
                      tooltip="Isolate"
                      onClick={() =>
                        act('isolate', {
                          container_id: containerData.id,
                          reagent_id: reagent.id,
                        })
                      }
                    />
                    <Button
                      px={0.75}
                      icon="times"
                      color="red"
                      tooltip="Flush"
                      onClick={() =>
                        act('flush_reagent', {
                          container_id: containerData.id,
                          reagent_id: reagent.id,
                        })
                      }
                    />
                  </>
                );
              }}
            />
            <Box m={1}>
              <Button ml={1} onClick={() => act('add_reagents')}>
                Add Reagents
              </Button>
              <Button ml={1} onClick={() => act('flush')}>
                Clear Reagents
              </Button>
            </Box>
          </Section>

          <Section title="Particle">
            <Box m={1}>
              <Button fluid onClick={() => act('particle_editor')}>
                Edit Particle
              </Button>
            </Box>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
