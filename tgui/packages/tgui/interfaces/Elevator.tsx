/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Section } from '../components';

type ElevatorParams = {
  location: string,
  active: boolean
}

export const Elevator = (_props, context) => {
  const { act, data } = useBackend<ElevatorParams>(context);
  const { location, active } = data;

  const handleSend = () => act('send', { });

  return (
    <Window
      theme="ntos"
      width={400}
      height={130}>
      <Window.Content textAlign="center">
        <Section width="70%" mx="auto">
          Location: <em>{location}</em>
        </Section>
        <Section width="70%" mx="auto" fontSize="16px">
          <Button onClick={handleSend}
            enabled={!active} color={active ? "grey" : "green"}
            icon="elevator" fluid>
            {active ? "Moving" : "Move Elevator"}
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
