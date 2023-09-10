/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Button } from '../components';

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
      height={140}>
      <Window.Content textAlign="center" fontSize="16px">
        <Section width="70%" mx="auto">
          Elevator Location: {location}
        </Section>
        <Section width="70%" mx="auto">
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
