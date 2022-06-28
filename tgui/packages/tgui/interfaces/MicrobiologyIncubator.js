/**
 * @file
 * @copyright 2022
 * @author XyzzyThePretender (https://github.com/XyzzyThePretender)
 * @license ISC
 */

import { classes } from 'common/react';
import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Dimmer, Icon, Section, SectionEx, Stack } from '../components';
import { Window } from '../layouts';
import { NoContainer, ReagentGraph, ReagentList } from './common/ReagentInfo';

export const MicrobiologyIncubator = (props, context) => {
  const { act, data } = useBackend(context);
  const { containerData, isActive } = data;

  return (
    <Window
      title="Microbial Incubator"
      width={320}
      height={385}>
      <Window.Content>
        <ChemDisplay container={containerData} active={isActive} />
        <Section title="Control Panel">
          <Stack align="center">
            <Stack.Item basis={9.6} align="center">
              <Button
                icon="power-off"
                disabled={!containerData?.totalVolume}
                color={isActive ? "red" : "green"}
                fluid
                height="100%"
                fontSize={1.25}
                textAlign="center"
                onClick={() => act(isActive ? 'stop' : 'start')}>
                {isActive ? "Deactivate" : "Activate"}
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ChemDisplay = (props, context) => {
  const { act } = useBackend(context);
  const { active = false } = props;
  const container = props.container ?? NoContainer;
  const working = active && !container.fake;
  const { totalVolume } = container;

  return (
    <SectionEx
      capitalize
      title={container.name}
      buttons={
        <Button
          icon="eject"
          disabled={!props.container}
          onClick={() => act('eject')}>
          Eject
        </Button>
      }>
      <ReagentGraph container={container} />
      <ReagentList container={container} />
      {!props.container && (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={() => act('insert')}
            bold>
            Insert Petri Dish
          </Button>
        </Dimmer>
      )}
    </SectionEx>
  );
};
