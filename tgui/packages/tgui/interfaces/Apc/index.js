import { Window } from '../../layouts';
import { useBackend } from "../../backend";

import {
  Stack,
  Box,
  Button,
  Divider,
  LabeledList,
  ProgressBar,
  Section,
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
    area_requires_power,
    area_name,
    cell_percent,
    cell_present,
    operating,
    charging,
    chargemode,
    chargecount,
    locked,
    coverlocked,
    aidisabled,
    lastused_total,
    main_status,
    wiresexposed,
    setup_networkapc,
    can_access_remotely,
    is_ai,
    is_silicon,
    host_id,
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

  const cellDisplay = () => {
    if (cell_present) {
      return (
        <>
          <LabeledList.Item label="Charging" direction="row">
            <Button content="Off"
              onClick={() => { onChargeModeChange(CHARGE_MODE_OFF); }}
              disabled={!hasPermission() && (chargemode !== CHARGE_MODE_OFF)}
              selected={chargemode === CHARGE_MODE_OFF}
            />
            <Button content="Auto"
              onClick={() => { onChargeModeChange(CHARGE_MODE_AUTO); }}
              disabled={!hasPermission() && (chargemode !== CHARGE_MODE_AUTO)}
              selected={chargemode === CHARGE_MODE_AUTO}
            />
            <font>{"("}{chargingStatusToText()}{")"}</font>
          </LabeledList.Item>
          <LabeledList.Item label="Cell Power">
            <ProgressBar value={cell_percent}
              minValue={0}
              maxValue={100}
              color={cell_percent < 20 ? "red" : cell_percent < 50 ? "yellow" : "green"} />
          </LabeledList.Item>
        </>
      );
    } else {
      return (
        <LabeledList.Item label="Cell Power">
          <ProgressBar value={cell_percent}
            minValue={0}
            maxValue={100}
            color={cell_percent < 20 ? "red" : cell_percent < 50 ? "yellow" : "green"} />
          <font color="red">Not Connected</font>
        </LabeledList.Item>
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

  const isLocalAccess = () => {
    return setup_networkapc < 2 && !can_access_remotely;
  };

  const hostConnectionDisplay = () => {
    if (isLocalAccess()) {
      return null;
    } else {
      return (
        <LabeledList.Item label="Host Connection">
          <Box><font color={host_id ? "green" : "red"}>{host_id ? "OK" : "NONE"}</font></Box>
        </LabeledList.Item>
      );
    }
  };

  const renderPoweredAreaApc = () => {
    return (
      <Window title="Area Power Controller" width={400} height={data["wiresexposed"] ? 680 : 420}>
        <Window.Content>
          <Section title={area_name}>
            {isLocalAccess() ? <Box align="center" bold fill>Swipe ID card to {locked ? "unlock" : "lock"} interface</Box> : null}
            {isLocalAccess() ? <Divider /> : null}
            <LabeledList>
              <LabeledList.Item label="Main Breaker">
                <Button content="Off" disabled={!hasPermission() && operating} onClick={() => { onOperatingChange(OFF); }} selected={!operating} />
                <Button content="On" disabled={!hasPermission() && !operating} onClick={() => { onOperatingChange(ON); }} selected={operating} />
              </LabeledList.Item>
              {cellDisplay()}
              <LabeledList.Item label="External Power">
                <Box>{mainStatusToText()}</Box>
              </LabeledList.Item>
              {hostConnectionDisplay()}
            </LabeledList>
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
          {wiresexposed && !is_ai ? <AccessPanel /> : null}
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
          {wiresexposed && !is_ai ? <AccessPanel /> : null}
        </Window.Content>
      </Window>
    );
  };

  return area_requires_power ? renderPoweredAreaApc() : renderUnPoweredAreaApc();
};
