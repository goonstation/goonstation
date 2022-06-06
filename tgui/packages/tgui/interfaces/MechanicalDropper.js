import { Window } from '../layouts';
import { useBackend } from "../backend";

import { clamp, round } from 'common/math';

import {
  Stack,
  Box,
  Button,
  Section,
  Slider,
  Tabs,
  ProgressBar,
} from '../components';

const TO_SELF = 0;
const TO_TARGET = 1;

const DropperModeSection = (props) => {
  const {
    transferMode,
    onTransferModeChange,
  } = props;
  return (
    <Section fitted py={0.6} pl={0.6} pr={1.2}>
      <Tabs vertical>
        <Tabs.Tab
          selected={transferMode === TO_SELF}
          color="green"
          onClick={() => onTransferModeChange(TO_SELF)}
        >
          Draw
        </Tabs.Tab>
        <Tabs.Tab
          selected={transferMode === TO_TARGET}
          color="red"
          onClick={() => onTransferModeChange(TO_TARGET)}
        >
          Drop
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};

const DropperAmountSection = (props) => {
  const {
    curTransferAmt,
    minTransferAmt,
    maxTransferAmt,
    onTransferAmtChange,
    curReagentVol,
    reagentColor,
  } = props;

  return (
    <Section>
      <Stack align="center" pb={1}>
        <Stack.Item>
          <Box
            textAlign="right"
            width="3em"
          >
            {`${curReagentVol}u`}
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <ProgressBar
            value={curReagentVol}
            minValue={0}
            maxValue={maxTransferAmt}
            color={reagentColor}
          />
        </Stack.Item>
        <Stack.Item>
          <Box
            textAlign="left"
            width="3em"
          >
            {`${maxTransferAmt}u`}
          </Box>
        </Stack.Item>
      </Stack>
      <Stack align="center">
        <Stack.Item>
          <Button
            textAlign="center"
            width="3em"
            content="Min"
            onClick={() => onTransferAmtChange(minTransferAmt)}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Slider
            minValue={minTransferAmt}
            maxValue={maxTransferAmt}
            stepPixelSize={20}
            step={1}
            value={curTransferAmt}
            onChange={(_e, value) => onTransferAmtChange(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            textAlign="center"
            width="3em"
            content="Max"
            onClick={() => onTransferAmtChange(maxTransferAmt)}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const MechanicalDropper = (_props, context) => {
  const { act, data } = useBackend(context);

  const {
    curTransferAmt,
    minTransferAmt,
    maxTransferAmt,
    transferMode,
    curReagentVol,
    reagentColor,
  } = data;

  const onTransferModeChange = (mode) => {
    act("mode", { mode });
  };

  const onTransferAmtChange = (amt) => {
    amt = round(clamp(amt, minTransferAmt, maxTransferAmt), 1);
    act("amt", { amt });
  };

  return (
    <Window title="Mechanical Dropper" width={400} height={105}>
      <Window.Content>
        <Stack>
          <Stack.Item align="center">
            <DropperModeSection
              transferMode={transferMode}
              onTransferModeChange={onTransferModeChange}
            />
          </Stack.Item>
          <Stack.Item grow>
            <DropperAmountSection
              curTransferAmt={curTransferAmt}
              minTransferAmt={minTransferAmt}
              maxTransferAmt={maxTransferAmt}
              onTransferAmtChange={onTransferAmtChange}
              curReagentVol={curReagentVol}
              reagentColor={reagentColor}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
