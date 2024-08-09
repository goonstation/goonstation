/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ElevatorData {
  active: BooleanLike;
  location: string;
}

export const Elevator = (_props: unknown, context: unknown) => {
  const { act, data } = useBackend<ElevatorData>();
  const { active, location } = data;
  const handleSend = () => act('send', {});
  return (
    <Window theme="ntos" width={300} height={130}>
      <Window.Content textAlign="center">
        <Section>
          Location: <em>{location}</em>
        </Section>
        <Section fontSize={1.5}>
          <Button
            onClick={handleSend}
            disabled={!!active}
            color={active ? 'grey' : 'green'}
            icon="elevator"
            fluid
          >
            {active ? 'Moving' : 'Move Elevator'}
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
