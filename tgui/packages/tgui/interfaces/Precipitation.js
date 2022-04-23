
/**
 * Copyright (c) 2022 @Azrun
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Box, Button, NumberInput, Tooltip, Section } from '../components';
import { Window } from '../layouts';
import { ReagentList } from './common/ReagentInfo';

export const Precipitation = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    probability,
    cooldown,
    poolDepth,
    containerData,
  } = data;

  return (
    <Window
      title="Precipitation"
      width={300}
      height={425}>
      <Window.Content scrollable>
        <Section
          title={
            <Box
              inline>
              Precipitation
            </Box>
          }>
          <Tooltip content="Cooldown for how fast ATOMs can be rained on.">
            <Box m={1}>
              Cooldown
              <NumberInput
                value={cooldown}
                width={4}
                minValue={0}
                onChange={(e, value) => act('set-cooldown', {
                  value,
                })}
              />
            </Box>
          </Tooltip>
          <Tooltip content="Chance of being rained on entering turf.">
            <Box m={1}>
              Probability
              <NumberInput
                value={probability}
                width={4}
                minValue={0}
                maxValue={100}
                onChange={(e, value) => act('set-probability', {
                  value,
                })}
              />
            </Box>
          </Tooltip>

          <Tooltip content="Maximum fluid size/depth on the tile. (0 means no pooling will form)">
            <Box m={1}>
              Maximum Pool Depth
              <NumberInput
                value={poolDepth}
                width={4}
                minValue={0}
                maxValue={100}
                onChange={(e, value) => act('set-poolDepth', {
                  value,
                })}
              />
            </Box>
          </Tooltip>

          <Section title="Reagents">
            <ReagentList container={containerData}
              renderButtons={(reagent) => {
                return (
                  <>
                    <Button
                      px={0.75}
                      mr={1.5}
                      icon="filter"
                      color="red"
                      title="Isolate"
                      onClick={() => act('isolate', { container_id: containerData.id, reagent_id: reagent.id })}
                    />
                    <Button
                      px={0.75}
                      icon="times"
                      color="red"
                      title="Flush"
                      onClick={() => act('flush_reagent', { container_id: containerData.id, reagent_id: reagent.id })}
                    />
                  </>
                );
              }}
            />
            <Box m={1}>
              <Button
                ml={1}
                onClick={() => act("add_reagents")}
              >
                Add Reagents
              </Button>
              <Button
                ml={1}
                onClick={() => act("flush")}
              >
                Clear Reagents
              </Button>

            </Box>
          </Section>

          <Section title="Particle">
            <Box m={1}>
              <Button
                fluid
                onClick={() => act("particle_editor")}
              >
                Edit Particle
              </Button>
            </Box>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
