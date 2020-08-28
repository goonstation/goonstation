import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Box, Button, Flex, LabeledList, Section, ColorBox, Divider, NoticeBox } from '../components';
import { Window } from '../layouts';
import { LabeledListDivider } from '../components/LabeledList';

export const Airlock = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    wireColors,
    netId,
  } = data;

  let wires = Object.keys(wireColors);

  return (
    <Window
      height={460}
      width={360}>
      <Window.Content>
        <Section title="Access panel">
          <Box>
            {"An identifier is engraved under the airlock's card sensors:"} <Box inline italic>{netId}</Box>
          </Box>
          <Divider />
          <LabeledList>
            { wires.map((entry, i) => (
              <LabeledList.Item
                key={entry}
                label={(entry + " wire").replace('Black', 'Olive').replace('Dark red', 'Pink').replace('Translucent', 'Teal')}
                labelColor={entry.toLowerCase().replace(/\s/g, '').replace('black', 'olive').replace('darkred', 'pink').replace('translucent', 'teal')}>
                <Button
                  icon="cut"
                  content={"Cut"} />
                <Button
                  ml={0.5}
                  icon="bolt"
                  content={"Pulse"} />
                <Button
                  ml={0.5}
                  icon="broadcast-tower"
                  content={"Attach Signaler"} />
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
                  color="green">
                  {"Disengaged"}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Test light"
                  color="green">
                  {"Active"}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
            <Flex.Item>
              <LabeledList>
                <LabeledList.Item
                  label="AI control"
                  color="green">
                  {"Enabled"}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Safety light"
                  color="green">
                  {"Active"}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
