import { Window } from '../layouts';
import { useBackend } from "../backend";

import { clamp, round } from 'common/math';

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
} from '../components';


const OFF = 0;
const ON = 1;
const AUTO = 2;

const POWER_CHANNEL_EQUIPMENT = 1;
const POWER_CHANNEL_LIGHTING = 2;
const POWER_CHANNEL_ENVIRONMENTAL = 3;

const POWER_CHANNEL_STATUS_OFF = 0;
const POWER_CHANNEL_STATUS_AUTO_OFF = 1;
const POWER_CHANNEL_STATUS_ON = 2;
const POWER_CHANNEL_STATUS_AUTO_ON = 3;

const WIRE_ORANGE = 1;
const WIRE_DARK_RED = 2;
const WIRE_WHITE = 3;
const WIRE_YELLOW = 4;

const MAIN_STATUS_NONE = 0;
const MAIN_STATUS_LOW = 1;
const MAIN_STATUS_GOOD = 2;

const CHARGE_MODE_OFF = 0;
const CHARGE_MODE_AUTO = 1;

export const PowerChannelSection = (props) => {
  const {
    powerChannel,
    act,
    data,
  } = props;

  const powerChannelToLabel = () => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return "Equipment";
      case POWER_CHANNEL_LIGHTING:
        return "Lighting";
      case POWER_CHANNEL_ENVIRONMENTAL:
        return "Environmental";
      default:
        return "Unknown";
    }
  };

  const getPowerChannelStatus = () => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return data["equipment"];
      case POWER_CHANNEL_LIGHTING:
        return data["lighting"];
      case POWER_CHANNEL_ENVIRONMENTAL:
        return data["environ"];
    }
  };

  const powerChannelLabel = powerChannelToLabel(powerChannel);

  // ------------ Events ------------
  const onPowerChannelStatusChange = (status) => {
    switch (powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        act("onPowerChannelEquipmentStatusChange", { status });
        break;
      case POWER_CHANNEL_LIGHTING:
        act("onPowerChannelLightingStatusChange", { status });
        break;
      case POWER_CHANNEL_ENVIRONMENTAL:
        act("onPowerChannelEnvironStatusChange", { status });
        break;
      default:
        return;
    }
  };
  // ------------ End Events ------------

  const getPowerChannelStatusAutoDisplay = () => {
    switch (getPowerChannelStatus()) {
      case POWER_CHANNEL_STATUS_AUTO_OFF:
        return <Box align="center">{"Auto (Off)"}</Box>;
      case POWER_CHANNEL_STATUS_AUTO_ON:
        return <Box align="center">{"Auto (On)"}</Box>;
      default:
        return <Button content="Auto" disabled={!hasPermission()} onClick={() => onPowerChannelStatusChange(POWER_CHANNEL_STATUS_AUTO_ON)} />;
    }
  };

  const hasPermission = () => {
    if (data["is_ai"] || data["is_silicon"] || data["can_access_remotely"]) {
      return data["aidisabled"] ? false : true;
    }
    return data["locked"] ? false : true;
  };

  return (
    <Stack>
      <Stack.Item align="center">
        <Box align="center">
          {powerChannelLabel}
        </Box>
      </Stack.Item>
      <Stack.Item align="center">
        {getPowerChannelStatus() === POWER_CHANNEL_STATUS_OFF ? <Box>Off</Box> : <Button content="Off" disabled={!hasPermission()} onClick={() => { onPowerChannelStatusChange(POWER_CHANNEL_STATUS_OFF); }} />}
      </Stack.Item>
      <Stack.Item align="center">
        {getPowerChannelStatus() === POWER_CHANNEL_STATUS_ON ? <Box>On</Box> : <Button content="On" disabled={!hasPermission()} onClick={() => { onPowerChannelStatusChange(POWER_CHANNEL_STATUS_ON); }} />}
      </Stack.Item>
      <Stack.Item align="center">
        {getPowerChannelStatusAutoDisplay()}
      </Stack.Item>
    </Stack>
  );
};

export const Wire = (props) => {
  const {
    wire,
    act,
    data,
  } = props;

  const wireColorToString = (wire) => {
    switch (wire) {
      case WIRE_ORANGE:
        return "Orange";
      case WIRE_DARK_RED:
        return "Dark red";
      case WIRE_WHITE:
        return "White";
      case WIRE_YELLOW:
        return "Yellow";
      default:
        return "unknown";
    }
  };

  const color = wireColorToString(wire);

  // ------------ Events ------------
  const onMend = (e) => {
    act("onMendWire", { wire });
  };

  const onCut = (e) => {
    act("onCutWire", { wire });
  };

  const onPulse = (e) => {
    act("onPulseWire", { wire });
  };

  const onBite = (e) => {
    act("onBiteWire", { wire });
  };
  // ------------ End Events ------------

  const isCut = (wire) => {
    // Logic is slightly different since dm doesn't 0 index for some reason
    switch (wire) {
      case WIRE_ORANGE:
        return data["orange_cut"];
      case WIRE_DARK_RED:
        return data["dark_red_cut"];
      case WIRE_WHITE:
        return data["white_cut"];
      case WIRE_YELLOW:
        return data["yellow_cut"];
    }
  };

  const toggleCutButton = () => {
    if (isCut(wire)) {
      return <Button content="mend" onClick={onMend} align="center" />;
    } else {
      return <Button content="cut" icon="cut" onClick={onCut} />;
    }
  };

  const actionsDisplay = () => {
    if (isCut(wire)) {
      return (
        <Box height={1.8}>
          <Button content="Mend" onClick={onMend} selected />
        </Box>
      );
    } else {
      return (
        <Box height={1.8}>
          <Button content="Cut" icon="cut" onClick={onCut} />
          <Button content="Pulse" icon="bolt" onClick={onPulse} />
          <Button content="Bite" icon="tooth" onClick={onBite} />
        </Box>
      );
    }
  };

  return (
    <LabeledList.Item key={wire} label={color} labelColor={color.toLowerCase().replace(' ', '')} >
      {actionsDisplay()}
    </LabeledList.Item>
  );
};

export const AccessPanel = (props) => {
  const {
    act,
    data,
  } = props;

  return (
    <Section title="Access Panel">
      <BlockQuote>An identifier is engraved above the APC{"'"}s wires: {data["net_id"]}</BlockQuote>
      <Flex direction="column">
        <LabeledList>
          <Wire wire={WIRE_ORANGE} act={act} data={data} />
          <Wire wire={WIRE_DARK_RED} act={act} data={data} />
          <Wire wire={WIRE_WHITE} act={act} data={data} />
          <Wire wire={WIRE_YELLOW} act={act} data={data} />
        </LabeledList>
        <Divider />
        <LabeledList>
          <LabeledList.Item label="APC Lock">
            {data["locked"] ? <font color="green">Locked</font> : <font color="red">Unlocked</font>}
          </LabeledList.Item>
          <LabeledList.Item label="Status">
            {data["shorted"] ? <font color="red">Shorted</font> : <font color="green">Working</font>}
          </LabeledList.Item>
          <LabeledList.Item label="AI Control">
            {data["aidisabled"] ? <font color="red">Disabled</font> : <font color="green">Enabled</font>}
          </LabeledList.Item>
        </LabeledList>
      </Flex>
    </Section>
  );
};

export const Apc = (props, context) => {
  const { act, data } = useBackend(context);

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
    if (data["setup_networkapc"] < 2 && !data["can_access_remotely"]) {
      return (
        <Box align="center" bold fill>Swipe ID card to {data["locked"] ? "unlock" : "lock"} interface</Box>
      );
    } else {
      return (
        <>
          <Stack.Item align="center">
            <Box>Host Connection:</Box>
          </Stack.Item>
          <Stack.Item align="center">
            <Box>{data["host_connected"] ? <font color="green">OK</font> : <font color="red">NONE</font>}</Box>
          </Stack.Item>
        </>
      );
    }
  };

  const mainStatusToText = () => {
    switch (data["main_status"]) {
      case MAIN_STATUS_GOOD:
        return <font color="green">Good</font>;
      case MAIN_STATUS_LOW:
        return <font color="yellow">Low</font>;
      case MAIN_STATUS_NONE:
        return <font color="red">None</font>;
    }
  };

  const chargingStatusToText = () => {
    switch (data["charging"]) {
      case 0:
        return data["chargecount"] ? "Performing self-test" : "Not charging";
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
          <Box>{data["chargemode"] ? "Auto" : "Off"}</Box>
        </Stack.Item>
      );
    } else {
      return (
        <>
          <Stack.Item align="center">
            {data["chargemode"] ? <Button content="Off" onClick={() => { onChargeModeChange(CHARGE_MODE_OFF); }} /> : <Box>Off</Box>}
          </Stack.Item>
          <Stack.Item align="center">
            {data["chargemode"] ? <Box>Auto</Box> : <Button content="Auto" onClick={() => { onChargeModeChange(CHARGE_MODE_AUTO); }} />}
          </Stack.Item>
        </>
      );
    }
  };

  const cellDisplay = () => {
    if (data["cell_present"]) {
      return (
        <Stack>
          <Stack.Item align="center">
            <Box>Power Cell:</Box>
          </Stack.Item>
          <Stack.Item align="center">
            <Box>{round(data["cell_percent"])}%</Box>
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
    let coverLockText = data["coverlocked"] ? "Engaged" : "Disengaged";
    if (!hasPermission()) {
      return <Box>{coverLockText}</Box>;
    } else {
      return <Button content={coverLockText} onClick={() => { onCoverLockedChange(!data["coverlocked"]); }} />;
    }
  };

  const overloadDisplay = () => {
    if (data["can_access_remotely"]) {
      return (
        <Button content="Overload lighting circuit" onClick={() => { onOverload(); }} />
      );
    } else {
      return null;
    }
  };

  const hasPermission = () => {
    if (data["is_ai"] || data["is_silicon"] || data["can_access_remotely"]) {
      return data["aidisabled"] ? false : true;
    }
    return data["locked"] ? false : true;
  };

  const renderPoweredAreaApc = () => {
    return (
      <Window title="Area Power Controller" width={400} height={data["wiresexposed"] ? 500 : 350}>
        <Window.Content>
          <Section title={"Area Power Controller (" + data["area_name"] + ")"}>
            <Stack>
              {swipeOrHostDisplay()}
            </Stack>
            <Stack>
              <Stack.Item align="center">
                <Box>Main Breaker</Box>
              </Stack.Item>
              <Stack.Item align="center">
                {data["operating"] ? <Button content="off" disabled={!hasPermission()} onClick={() => { onOperatingChange(OFF); }} /> : <Box>off</Box>}
              </Stack.Item>
              <Stack.Item align="center">
                {data["operating"] ? <Box>on</Box> : <Button content="on" disabled={!hasPermission()} onClick={() => { onOperatingChange(ON); }} />}
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
            <PowerChannelSection powerChannel={POWER_CHANNEL_EQUIPMENT} act={act} data={data} />
            <PowerChannelSection powerChannel={POWER_CHANNEL_LIGHTING} act={act} data={data} />
            <PowerChannelSection powerChannel={POWER_CHANNEL_ENVIRONMENTAL} act={act} data={data} />
            <Stack>
              <Stack.Item align="center">
                <Box>Total Load:</Box>
              </Stack.Item>
              <Stack.Item align="center">
                <Box>{data["lastused_total"]} W</Box>
              </Stack.Item>
            </Stack>
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
            {overloadDisplay()}
          </Section>
          {data["wiresexposed"] && !data["is_ai"] ? <AccessPanel act={act} data={data} /> : null}
        </Window.Content>
      </Window>
    );
  };

  const renderUnPoweredAreaApc = () => {
    return (
      <Window title="Area Power Controller" width={400} height={data["wiresexposed"] ? 500 : 350}>
        <Window.Content>
          <Section title={"Area Power Controller (" + data["area_name"] + ")"}>
            <Box>This APC has no configurable settings.</Box>
          </Section>
          {data["wiresexposed"] && !data["is_ai"] ? <AccessPanel act={act} data={data} /> : null}
        </Window.Content>
      </Window>
    );
  };

  return data["area_requires_power"] ? renderPoweredAreaApc() : renderUnPoweredAreaApc();
};
