import { useBackend } from '../backend';
import { Box, Button, Flex, LabeledList, Section, Divider } from '../components';
import { Window } from '../layouts';

export const Airlock = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    signalers,
    wireColors,
    wireStates,
    netId,
    powerIsOn,
    boltsAreUp,
    aiControlDisabled,
    safety,
  } = data;

  const handleWireInteract = (wireColorIndex, action) => {
    act(action, { wireColorIndex });
  };

  const wires = Object.keys(wireColors);

  return (
    <Window
      height={460}
      width={370}>
      <Window.Content>
        <Section
          title="Access Panel">
          <Box>
            {"An identifier is engraved under the airlock's card sensors:"} <Box inline italic>{netId}</Box>
          </Box>
          <Divider />
          <LabeledList>
            { wires.map((entry, i) => (
              <LabeledList.Item
                key={entry}
                label={(entry + " wire")}
                labelColor={entry.toLowerCase()}>
                {
                  !wireStates[i]
                    ? (
                      <Box
                        height={1.8} >
                        <Button
                          icon="cut"
                          content="Cut"
                          onClick={() => handleWireInteract(i, "cut")} />
                        <Button
                          icon="bolt"
                          content={"Pulse"}
                          onClick={() => handleWireInteract(i, "pulse")} />
                        <Button
                          icon="broadcast-tower"
                          width={10.5}
                          className="airlock-wires-btn"
                          selected={!!(signalers[i])}
                          content={!(signalers[i]) ? "Attach Signaler" : "Detach Signaler"}
                          onClick={() => handleWireInteract(i, "signaler")} />
                      </Box>
                    )
                    : (
                      <Button
                        content={"Mend"}
                        color="green"
                        height={1.8}
                        onClick={() => handleWireInteract(i, "mend")} />
                    )
                }
              </LabeledList.Item>
            )) }
          </LabeledList>
          <Divider />
          <Flex
            direction="row">
            <Flex.Item>
              <LabeledList>
                <LabeledList.Item
                  label="Door bolts"
                  color={boltsAreUp ? "green" : "red"}>
                  {boltsAreUp ? "Disengaged" : "Engaged"}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Test light"
                  color={powerIsOn ? "green" : "red"}>
                  {powerIsOn ? "Active" : "Inactive"}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
            <Flex.Item>
              <LabeledList>
                <LabeledList.Item
                  label="AI control"
                  color={!aiControlDisabled ? "green" : "red"}>
                  {!aiControlDisabled ? "Enabled" : "Disabled"}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Safety light"
                  color={safety ? "green" : "red"}>
                  {safety ? "Active" : "Inactive"}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
