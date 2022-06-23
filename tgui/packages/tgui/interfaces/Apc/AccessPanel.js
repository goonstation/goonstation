import { Window } from '../../layouts';
import { useBackend } from "../../backend";

import {
  Stack,
  BlockQuote,
  Box,
  Button,
  Divider,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  LabeledControls,
} from '../../components';

import {
  Wire,
  WIRE_ORANGE,
  WIRE_DARK_RED,
  WIRE_WHITE,
  WIRE_YELLOW,
} from './Wire';


export const AccessPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    net_id,
    locked,
    shorted,
    aidisabled,
  } = data;

  return (
    <Section title="Access Panel">
      <BlockQuote><b>An identifier is engraved above the APC{"'"}s wires: {net_id}</b></BlockQuote>
      <Flex direction="column">
        <LabeledList>
          <Wire wire={WIRE_ORANGE} />
          <Wire wire={WIRE_DARK_RED} />
          <Wire wire={WIRE_WHITE} />
          <Wire wire={WIRE_YELLOW} />
        </LabeledList>
        <Divider />
        <LabeledList>
          <LabeledList.Item label="Controls">
            <font color={locked ? "green" : "red"}>
              {locked ? "Locked" : "Unlocked"}
            </font>
          </LabeledList.Item>
          <LabeledList.Item label="Circuitry">
            <font color={shorted ? "red" : "green"}>
              {shorted ? "Shorted" : "Working"}
            </font>
          </LabeledList.Item>
          <LabeledList.Item label="AI Control">
            <font color={aidisabled ? "red" : "green"}>
              {aidisabled ? "Disabled" : "Enabled"}
            </font>
          </LabeledList.Item>
        </LabeledList>
      </Flex>
    </Section>
  );
};

