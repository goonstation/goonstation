import { useBackend, useLocalState } from '../backend';
import { Button, Section, Flex, Box, NumberInput } from '../components';
import { Window } from '../layouts';

export const PipeDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const disposalpipes = data.disposalpipes || [];
  const [amount, setAmount] = useLocalState(context, 'amount', 1);
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
      width="300"
      height={mobile ? 330 : 235}>
      <Window.Content scrollable>
        <Section>
          {disposalpipes.map(disposalpipe => {
            return (
              <Flex key={disposalpipe.disposaltype} justify="space-between" align="stretch" style={{ "border-bottom": "1px #555 solid" }}>
                <Flex.Item>
                  {disposalpipe.image && (
                    <Box style={{ "overflow": "show", "height": "32px" }}>
                      <img
                        src={`data:image/png;base64,${disposalpipe.image}`}
                      />
                    </Box>)}
                </Flex.Item>
                <Flex.Item
                  grow style={{
                    "display": "flex",
                    "justify-content": "center",
                    "flex-direction": "column",
                  }}>
                  <Box>
                    <Box inline>
                      {disposalpipe.disposaltype}
                    </Box>
                  </Box>
                </Flex.Item>
                <Flex.Item
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
                </Flex.Item>
                <Flex.Item bold style={{
                  "margin-left": "5px",
                  "display": "flex",
                  "justify-content": "center",
                  "flex-direction": "column",
                }}>
                  <Button
                    color={dispenser_ready ? "green" : "grey"}
                    content="Dispense"
                    disabled={!dispenser_ready}
                    style={{ "width": "70px", "text-align": "center", "padding": "0px" }}
                    onClick={() => act('dmake', { 'disposal_type': disposalpipe.disposaltype, 'amount': amount })}
                  />
                </Flex.Item>
              </Flex>
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
