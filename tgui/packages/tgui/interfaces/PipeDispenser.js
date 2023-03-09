/**
 * @file
 * @copyright 2023
 * @author Laboredih123 (https://github.com/Laboredih123)
 * @license MIT
 */

import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, Box, NumberInput, Image } from '../components';
import { Window } from '../layouts';

export const PipeDispenser = (props, context) => {
  const { data } = useBackend(context);
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
    <Window
      title={windowName}
      width="325"
      height={mobile ? 365 : 270}>
      <Window.Content scrollable>
        <Section>
          {disposalpipes.map(disposalpipe => {
            return (
              <DisposalPipeRow
                key={disposalpipe.disposaltype}
                dispenser_ready={dispenser_ready}
                max_disposal_pipes={max_disposal_pipes}
                disposalpipe={disposalpipe} />
            );
          })}
        </Section>
        {!!mobile && (
          <AutoPipeLaying
            laying_pipe={laying_pipe}
            removing_pipe={removing_pipe} />
        )}
      </Window.Content>
    </Window>
  );
};

export const DisposalPipeRow = (props, context) => {
  const { act } = useBackend(context);
  const [amount, setAmount] = useLocalState(context, 'amount', 1);
  const {
    dispenser_ready,
    max_disposal_pipes,
    disposalpipe,
  } = props;

  return (
    <Stack style={{ "border-bottom": "1px #555 solid" }}>
      {disposalpipe.image && (
        <Stack.Item>
          <Box style={{ "overflow": "show", "height": "32px" }}>
            <Image
              pixelated
              src={`data:image/png;base64,${disposalpipe.image}`}
            />
          </Box>
        </Stack.Item>)}
      <Stack.Item grow>
        {disposalpipe.disposaltype}
      </Stack.Item>
      <Stack.Item
        style={{
          "display": "flex",
          "justify-content": "center",
          "flex-direction": "column",
        }}>
        Amount:
        <NumberInput
          value={amount}
          minValue={1}
          maxValue={max_disposal_pipes}
          onChange={(e, value) => setAmount(Math.round(value))} />
      </Stack.Item>
      <Stack.Item style={{
        "margin-left": "5px",
        "display": "flex",
        "justify-content": "center",
        "flex-direction": "column",
      }}>
        <Button
          color={dispenser_ready ? "green" : "grey"}
          content="Dispense"
          disabled={!dispenser_ready}
          style={{ "width": "70px", "text-align": "center" }}
          onClick={() => act('dmake', { 'disposal_type': disposalpipe.disposaltype, 'amount': amount })}
        />
      </Stack.Item>
    </Stack>
  );
};

export const AutoPipeLaying = (props, context) => {
  const { act } = useBackend(context);
  const {
    laying_pipe,
    removing_pipe,
  } = props;

  return (
    <Section
      title="Automatic Pipe Options">
      <Button
        color={laying_pipe ? "average" : "green"}
        content={laying_pipe ? "Stop Laying Pipe Automatically" : "Start Laying Pipe Automatically"}
        fluid
        align="center"
        onClick={() => act('toggle_laying')}
      />
      <Button
        color={removing_pipe ? "average" : "green"}
        content={removing_pipe ? "Stop Removing Pipe Automatically" : "Start Removing Pipe Automatically"}
        fluid
        align="center"
        onClick={() => act('toggle_removing')}
      />
    </Section>
  );
};
