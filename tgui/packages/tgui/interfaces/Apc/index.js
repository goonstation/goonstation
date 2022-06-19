import { Window } from '../../layouts';
import { useBackend } from "../../backend";
import { round } from 'common/math';

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
  Tabs,
  LabeledControls,
} from '../../components';

import {
  AccessPanel,
} from './AccessPanel';

import {
  PowerChannelSection,
  POWER_CHANNEL_EQUIPMENT,
  POWER_CHANNEL_LIGHTING,
  POWER_CHANNEL_ENVIRONMENTAL,
} from './PowerChannelSection';


const OFF = 0;
const ON = 1;
const AUTO = 2;

const MAIN_STATUS_NONE = 0;
const MAIN_STATUS_LOW = 1;
const MAIN_STATUS_GOOD = 2;

const CHARGE_MODE_OFF = 0;
const CHARGE_MODE_AUTO = 1;


export const Apc = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    cell_type,
    cell_percent,
    cell_present,
    opened,
    circuit_disabled,
    shorted,
    lighting,
    equipment,
    environ,
    operating,
    do_not_operate,
    charging,
    chargemode,
    chargecount,
    locked,
    coverlocked,
    aidisabled,
    noalerts,
    lastused_light,
    lastused_equip,
    lastused_environ,
    lastused_total,
    main_status,
    light_consumption,
    equip_consumption,
    environ_consumption,
    emagged,
    wiresexposed,
    apcwires,
    repair_status,
    host_id,
    setup_networkapc,
    orange_cut,
    dark_red_cut,
    white_cut,
    yellow_cut,
    can_access_remotely,
    is_ai,
    is_silicon,
  } = data;

  // ------------ Events ------------
  const onOperatingChange = (operating) => {
    act("onOperatingChange", { operating });
  };

  const onChargeModeChange = (chargemode) => {
    act("onChargeModeChange", { chargemode });
  };

  const onCoverLockedChange = (coverlocked) => {
    act("onCoverLockedChange", { coverlocked });
  };

  const onOverload = () => {
    act("onOverload", {});
  };
  // ------------ End Events ------------

  const swipeOrHostDisplay = () => {
    if (setup_networkapc < 2 && !can_access_remotely) {
      return (
        <Box align="center" bold fill>Swipe ID card to {locked ? "unlock" : "lock"} interface</Box>
      );
    } else {
      return (
        <>
          <Stack.Item align="center">
            <Box>Host Connection:</Box>
          </Stack.Item>
          <Stack.Item align="center">
            <Box>{host_connected ? <font color="green">OK</font> : <font color="red">NONE</font>}</Box>
          </Stack.Item>
        </>
      );
    }
  };

  const mainStatusToText = () => {
    switch (main_status) {
      case MAIN_STATUS_GOOD:
        return <font color="green">Good</font>;
      case MAIN_STATUS_LOW:
        return <font color="yellow">Low</font>;
      case MAIN_STATUS_NONE:
        return <font color="red">None</font>;
    }
  };

  const chargingStatusToText = () => {
    switch (charging) {
      case 0:
        return chargecount ? "Performing self-test" : "Not charging";
      case 1:
        return "Fully Charged";
      default:
        return "Charging";
    }
  };

  const chargeModeDisplay = () => {
    if (!hasPermission()) {
      return (
        <Stack.Item align="center">
          <Box>{chargemode ? "Auto" : "Off"}</Box>
        </Stack.Item>
      );
    } else {
      return (
        <>
          <Stack.Item align="center">
            {chargemode ? <Button content="Off" onClick={() => { onChargeModeChange(CHARGE_MODE_OFF); }} /> : <Box>Off</Box>}
          </Stack.Item>
          <Stack.Item align="center">
            {chargemode ? <Box>Auto</Box> : <Button content="Auto" onClick={() => { onChargeModeChange(CHARGE_MODE_AUTO); }} />}
          </Stack.Item>
        </>
      );
    }
  };

  const cellDisplay = () => {
    if (cell_present) {
      return (
        <Stack>
          <Stack.Item align="center">
            <Box>Power Cell:</Box>
          </Stack.Item>
          <Stack.Item align="center">
            <Box>{round(cell_percent)}%</Box>
          </Stack.Item>
          <Stack.Item align="center">
            <Box>{"("}{chargingStatusToText()}{")"}</Box>
          </Stack.Item>
          {chargeModeDisplay()}
        </Stack>
      );
    } else {
      return (
        <Stack>
          <Stack.Item align="center">
            <Box>Power Cell:</Box>
          </Stack.Item>
          <Stack.Item align="center">
            <Box>
              <font color="red">Not Connected</font>
            </Box>
          </Stack.Item>
        </Stack>
      );
    }
  };

  const coverLockDisplay = () => {
    let coverLockText = coverlocked ? "Engaged" : "Disengaged";
    if (!hasPermission()) {
      return <Box>{coverLockText}</Box>;
    } else {
      return <Button content={coverLockText} onClick={() => { onCoverLockedChange(!coverlocked); }} />;
    }
  };

  const hasPermission = () => {
    if (is_ai || is_silicon || can_access_remotely) {
      return aidisabled ? false : true;
    }
    return locked ? false : true;
  };

  const renderPoweredAreaApc = () => {
    return (
      <Window title="Area Power Controller">
        <Window.Content>
          <Section title={"Area Power Controller (" + area_name + ")"}>
            <Stack>
              {swipeOrHostDisplay()}
            </Stack>
            <Divider />
            <Stack>
              <Stack.Item align="center">
                <Box>Main Breaker</Box>
              </Stack.Item>
              <Stack.Item align="center">
                {operating ? <Button content="off" disabled={!hasPermission()} onClick={() => { onOperatingChange(OFF); }} /> : <Box>off</Box>}
              </Stack.Item>
              <Stack.Item align="center">
                {operating ? <Box>on</Box> : <Button content="on" disabled={!hasPermission()} onClick={() => { onOperatingChange(ON); }} />}
              </Stack.Item>
            </Stack>
            <Stack>
              <Stack.Item align="center">
                <Box>External Power:</Box>
              </Stack.Item>
              <Stack.Item align="center">
                <Box>{mainStatusToText()}</Box>
              </Stack.Item>
            </Stack>
            {cellDisplay()}
          </Section>
          <Section title="PowerChannel">
            <LabeledList>
              <PowerChannelSection powerChannel={POWER_CHANNEL_EQUIPMENT} />
              <PowerChannelSection powerChannel={POWER_CHANNEL_LIGHTING} />
              <PowerChannelSection powerChannel={POWER_CHANNEL_ENVIRONMENTAL} />
              <LabeledList.Item label="Total Load">
                <Box>{lastused_total} W</Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Section>
            <Stack>
              <Stack.Item align="center">
                <Box>Cover lock:</Box>
              </Stack.Item>
              <Stack.Item align="center">
                {coverLockDisplay()}
              </Stack.Item>
            </Stack>
            {can_access_remotely ? <Button content="Overload lighting circuit" onClick={() => { onOverload(); }} /> : null}
          </Section>
          {wiresexposed && !is_ai ? <AccessPanel act={act} data={data} /> : null}
        </Window.Content>
      </Window>
    );
  };

  const renderUnPoweredAreaApc = () => {
    return (
      <Window title="Area Power Controller" width={400} height={wiresexposed ? 500 : 350}>
        <Window.Content>
          <Section title={"Area Power Controller (" + area_name + ")"}>
            <Box>This APC has no configurable settings.</Box>
          </Section>
          {wiresexposed && !is_ai ? <AccessPanel act={act} data={data} /> : null}
        </Window.Content>
      </Window>
    );
  };

  return area_requires_power ? renderPoweredAreaApc() : renderUnPoweredAreaApc();
};
