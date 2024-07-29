/**
 * @file
 * @copyright 2023
 * @author cringe (https://github.com/Laboredih123)
 * @license MIT
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Image,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface PipeDispenserData {
  disposalpipes;
  dispenser_ready;
  windowName;
  mobile;
  removing_pipe;
  laying_pipe;
  max_disposal_pipes;
}

export const PipeDispenser = () => {
  const { data } = useBackend<PipeDispenserData>();
  const disposalpipes = data.disposalpipes || [];
  const {
    dispenser_ready,
    windowName,
    mobile,
    removing_pipe,
    laying_pipe,
    max_disposal_pipes,
  } = data;
  return (
    <Window title={windowName} width={325} height={mobile ? 365 : 270}>
      <Window.Content scrollable>
        <Section>
          {disposalpipes.map((disposalpipe) => {
            return (
              <DisposalPipeRow
                key={disposalpipe.disposaltype}
                dispenser_ready={dispenser_ready}
                max_disposal_pipes={max_disposal_pipes}
                disposalpipe={disposalpipe}
              />
            );
          })}
        </Section>
        {!!mobile && (
          <AutoPipeLaying
            laying_pipe={laying_pipe}
            removing_pipe={removing_pipe}
          />
        )}
      </Window.Content>
    </Window>
  );
};

export const DisposalPipeRow = (props) => {
  const { act } = useBackend();
  const [amount, setAmount] = useState(1);
  const { dispenser_ready, max_disposal_pipes, disposalpipe } = props;

  return (
    <Stack style={{ borderBottom: '1px #555 solid' }}>
      {disposalpipe.image && (
        <Stack.Item>
          <Box style={{ overflow: 'show', height: '32px' }}>
            <Image src={`data:image/png;base64,${disposalpipe.image}`} />
          </Box>
        </Stack.Item>
      )}
      <Stack.Item grow>{disposalpipe.disposaltype}</Stack.Item>
      <Stack.Item
        style={{
          display: 'flex',
          justifyContent: 'center',
          flexDirection: 'column',
        }}
      >
        Amount:
        <NumberInput
          value={amount}
          minValue={1}
          maxValue={max_disposal_pipes}
          step={1}
          onChange={(value) => setAmount(Math.round(value))}
        />
      </Stack.Item>
      <Stack.Item
        style={{
          marginLeft: '5px',
          display: 'flex',
          justifyContent: 'center',
          flexDirection: 'column',
        }}
      >
        <Button
          color={dispenser_ready ? 'green' : 'grey'}
          disabled={!dispenser_ready}
          textAlign="center"
          width="70px"
          onClick={() =>
            act('dmake', {
              disposal_type: disposalpipe.disposaltype,
              amount: amount,
            })
          }
        >
          Dispense
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const AutoPipeLaying = (props) => {
  const { act } = useBackend<PipeDispenserData>();
  const { laying_pipe, removing_pipe } = props;

  return (
    <Section title="Automatic Pipe Options">
      <Button
        color={laying_pipe ? 'average' : 'green'}
        fluid
        align="center"
        onClick={() => act('toggle_laying')}
      >
        {laying_pipe
          ? 'Stop Laying Pipe Automatically'
          : 'Start Laying Pipe Automatically'}
      </Button>
      <Button
        color={removing_pipe ? 'average' : 'green'}
        fluid
        align="center"
        onClick={() => act('toggle_removing')}
      >
        {removing_pipe
          ? 'Stop Removing Pipe Automatically'
          : 'Start Removing Pipe Automatically'}
      </Button>
    </Section>
  );
};
