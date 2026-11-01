import { Box, Button, NoticeBox } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface LaundryData {
  door;
  on;
}

export const Laundry = () => {
  const { data } = useBackend<LaundryData>();
  const { on } = data;
  return (
    <Window title="Washman 550" width={400} height={100}>
      <Window.Content>
        <Box textAlign="center" mb={1}>
          {on ? <StatusActive /> : <StatusInactive />}
        </Box>
        <Box textAlign="center">
          <ButtonCycle />
          <ButtonDoor />
        </Box>
      </Window.Content>
    </Window>
  );
};

const StatusActive = () => (
  <NoticeBox info>Please wait, machine is currently running.</NoticeBox>
);

const StatusInactive = () => (
  <NoticeBox info>
    Insert items and press &quot;Turn On&quot; to start.
  </NoticeBox>
);

const ButtonCycle = () => {
  const { act, data } = useBackend<LaundryData>();
  const { on } = data;
  return (
    <Button
      disabled={on}
      color={on ? '' : 'good'}
      icon="fas fa-power-off"
      onClick={() => act('cycle')}
    >
      Turn On
    </Button>
  );
};

const ButtonDoor = () => {
  const { act, data } = useBackend<LaundryData>();
  const { on, door } = data;
  return (
    <Button
      disabled={on}
      color={door ? 'orange' : ''}
      icon={door ? 'fas fa-door-open' : 'fas fa-door-closed'}
      onClick={() => act('door')}
    >
      {door ? 'Open' : 'Closed'}
    </Button>
  );
};
