import { Window } from '../layouts';
import { useBackend } from "../backend";

import { clamp, round } from 'common/math';

import {
  Stack,
  Box,
  Button,
  ProgressBar,
  Section,
  Slider,
  Tabs,
  ProgressBar,
  LabeledControls,
} from '../components';


const OFF = 0
const ON = 1
const AUTO = 2

const POWER_CHANNEL_EQUIPMENT = 1
const POWER_CHANNEL_LIGHTING = 2
const POWER_CHANNEL_ENVIRONMENTAL = 3

const POWER_CHANNEL_STATUS_OFF = 0
const POWER_CHANNEL_STATUS_AUTO_OFF = 1
const POWER_CHANNEL_STATUS_ON = 2
const POWER_CHANNEL_STATUS_AUTO_ON = 3

const WIRE_ORANGE = 1
const WIRE_DARK_RED = 2
const WIRE_WHITE = 3
const WIRE_YELLOW = 4

const WIRE_ACTION_CUT = 1
const WIRE_ACTION_PULSE = 2
const WIRE_ACTION_BITE = 3
const WIRE_ACTION_MEND = 4

const WIRE_STATE_CUT = 1
const WIRE_STATE_WHOLE = 2
const WIRE_STATE_PULSED = 3

const MAIN_STATUS_NONE = 0
const MAIN_STATUS_LOW = 1
const MAIN_STATUS_GOOD = 2

const CHARGE_MODE_OFF = 0
const CHARGE_MODE_AUTO = 1

export const PowerChannelSection = (props) => {
  const {
    powerChannel,
    act,
    data,
  }

  const powerChannelToLabel = () => {
    switch(powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return "Equipment"
      case POWER_CHANNEL_LIGHTING:
        return "Lighting"
      case POWER_CHANNEL_ENVIRONMENTAL:
        return "Environmental"
      default:
        return "Unknown"
    }
  }

  const getPowerChannelStatus = () => {
    switch(powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        return data["equipment"]
      case POWER_CHANNEL_LIGHTING:
        return data["lighting"]
      case POWER_CHANNEL_ENVIRONMENTAL:
        return data["environ"]
    }
  }

  const powerChannelLabel = powerChannelToLabel(powerChannel)

  const onPowerChannelStatusChange = (value) => {
    switch(powerChannel) {
      case POWER_CHANNEL_EQUIPMENT:
        act("onPowerChannelEquipmentStatusChange", { value })
      case POWER_CHANNEL_LIGHTING:
        act("onPowerChannelLightingStatusChange", { value })
      case POWER_CHANNEL_ENVIRONMENTAL:
        act("onPowerChannelEnvironmentalStatusChange", { value })
      default:
        return
    }
  }

  const getPowerChannelStatusAutoDisplay = () => {
    switch(getPowerChannelStatus()) {
      case POWER_CHANNEL_STATUS_AUTO_OFF:
        return <Box>{"Auto (Off)"}</Box>
      case POWER_CHANNEL_STATUS_AUTO_ON:
        return <Box>{"Auto (On)"}</Box>
      default:
        return <Button label="Auto" onClick={() => onPowerChannelUpdate(POWER_CHANNEL_STATUS_AUTO_ON)} />
    }
  }

  return (
    <Stack>
      <Stack.Item>
        <Box>
          {powerChannelLabel}
        </Box>
      </Stack.Item>
      <Stack.Item>
        {getPowerChannelStatus() == POWER_CHANNEL_STATUS_OFF ? <>
          <Box>Off</Box>
        </> : <>
          <Button label="Off" onClick={() => {onPowerChannelUpdate(POWER_CHANNEL_STATUS_OFF)}}/>
        </>}
      </Stack.Item>
     <Stack.Item>
        {getPowerChannelStatus() == POWER_CHANNEL_STATUS_ON ? <>
          <Box>On</Box>
        </> : <>
          <Button label="On" onClick={() => {onPowerChannelUpdate(POWER_CHANNEL_STATUS_ON)}}/>
        </>}
      </Stack.Item>
      <Stack.Item>
        {getPowerChannelStatusAutoDisplay()}
      </Stack.Item>
    </Stack>
  )
}

export const Wire = (props) => {
  const {
    wire,
    act,
    data,
  }

  const wireColorToString = (wire) => {
    switch (wire) {
      case WIRE_ORANGE:
        return "Orange"
      case WIRE_DARK_RED:
        return "Dark red"
      case WIRE_WHITE:
        return "White"
      case WIRE_YELLOW:
        return "Yellow"
      default:
        return "unknown"
    }
  }

  const color = wireColorToString(wire)

  const onMend = (e) => {
    act("onMendWire", { wire })
  }

  const onCut = (e) => {
    act("onCutWire", { wire })
  }

  const onPulse = (e) => {
    act("onPulseWire", { wire })
  }

  const onBite = (e) => {
    act("onBiteWire", { wire })
  }

  const isCut = () => {
    return data.apcwires & wire
  }

  const toggleCutButton = () => {
    if (isCut(wire)) {
      return <Button label="mend" onClick={onMend}/>
    } else {
      return <Button label="cut" onClick={onCut}/>
    }
  }

  return (
    <Stack>
      <Stack.Item>
        <Box>{color} wire:</Box>
      </Stack.Item>
      <Stack.Item>
        {toggleCutButton()}
      </Stack.Item>
      <Stack.Item>
        <Button label="pulse" onClick={onPulse}/>
      </Stack.Item>
      <Stack.Item>
        <Button label="bite" onClick={onBite}/>
      </Stack.Item>
    </Stack>
  )
}

export const AccessPanel = (props) => {
  const {
    act,
    data,
  } = props;
  return (
    <Section label="Access Panel">
      <Box>An identifier is engraved above the APC's wires: {data["net_id"]}</Box>
      <Stack>
        <Stack.Item>
          <Wire wireColor={WIRE_ORANGE} act={act} data={data}/>
          <Wire wireColor={WIRE_DARK_RED} act={act} data={data}/>
          <Wire wireColor={WIRE_WHITE} act={act} data={data}/>
          <Wire wireColor={WIRE_YELLOW} act={act} data={data}/>
        </Stack.Item>
        <Stack.Item>
          <Box>The APC is {data["locked"] ? "locked" : "unlocked"}.</Box>
          <Box>{data["shorted"] ? "The APC's power has been shorted." : "The APC is working properly!"}</Box>
          <Box>The 'AI control allowed' light is {data["aidisabled"] ? "off" : "on"}.</Box>
        </Stack.Item>
      </Stack>
    </Section>
  )
}

export const Apc = (props, context) => {
  const { act, data } = useBackend(context);

  let accessPanel;
  if (data.accessPanel) {
    accessPanel = <AccessPanel act={act} data={data}/>
  } else {
    accessPanel = <></>
  }

  const onMainBreakerChange = (value) => {
    act("onMainBreakerChange", { value });
  }

  const onChargeModeChange = (value) => {
    act("onChargeModeChange", { value });
  }

  const mainStatusToText = () => {
    switch (data["main_status"]) {
      case MAIN_STATUS_GOOD:
        return "Good"
      case MAIN_STATUS_LOW:
        return "Low"
      case MAIN_STATUS_NONE:
        return "None"
    }
  }

  const chargingStatusToText = () => {
    switch (data["charging"]) {
      case 0:
        return "Not charging"
      case 1:
        return "Fully Charged"
      default:
        return "Charging"
    }
  }

  const chargeModeDisplay = () => {
    if (data["locked"]) {
      return <>
        <Stack.Item>
          <Box>{data["chargemode"] ? "Auto" : "Off"}</Box>
        </Stack.Item>
      </>
    } else {
      return <>
        <Stack.Item>
          {data["chargemode"] ? <>
            <Button label="Off" onClick={() => {() => {onChargeModeChange(CHARGE_MODE_OFF)}}}/>
          </> : <>
            <Box>Off</Box>
          </>}
        </Stack.Item>
        <Stack.Item>
          {data["chargemode"] ? <>
            <Box>Auto</Box>
          </> : <>
            <Button label="Auto" onClick={() => {() => {onChargeModeChange(CHARGE_MODE_AUTO)}}}/>
          </>}
        </Stack.Item>
      </>
    }
  }

  const cellDisplay = () => {
    if (data["cell"]) {
      return <Stack>
        <Stack.Item>
          <Box>Power Cell:</Box>
        </Stack.Item>
        <Stack.Item>
          <Box>{'(' + data["cell"].percent + ')'}</Box>
        </Stack.Item>
        <Stack.Item>
          <Box>{chargingStatusToText()}</Box>
        </Stack.Item>
        {chargeModeDisplay()}
      </Stack>
    } else {
      return <Stack>
        <Stack.Item>
          <Box>Power Cell:</Box>
        </Stack.Item>
        <Stack.Item>
          <Box>Not Connected</Box>
        </Stack.Item>
      </Stack>
    }
  }

  return (
    <Window title="Area Power Controller">
      <Section title="Main">
        <Stack>
          <Stack.Item>
            <Box>Main Breaker</Box>
          </Stack.Item>
          <Stack.Item>
            <Button label="off" disabled={data["locked"]} onClick={() => {onMainBreakerChange(OFF)}}/>
          </Stack.Item>
          <Stack.Item>
            <Button label="on" disabled={data["locked"]} onClick={() => {onMainBreakerChange(ON)}}/>
          </Stack.Item>
        </Stack>
        <Stack>
          <Stack.Item>
            <Box>External Power:</Box>
          </Stack.Item>
          <Stack.Item>
            <Box>{mainStatusToText()}</Box>
          </Stack.Item>
        </Stack>
        {cellDisplay()}
      </Section>

      <Section title="PowerChannel">
        <PowerChannelSection powerChannel={POWER_CHANNEL_EQUIPMENT} act={act} data={data}/>
        <PowerChannelSection powerChannel={POWER_CHANNEL_LIGHTING} act={act} data={data}/>
        <PowerChannelSection powerChannel={POWER_CHANNEL_ENVIRONMENTAL} act={act} data={data}/>
        <Stack>
          <Stack.Item>
            <Box>Total Load:</Box>
          </Stack.Item>
          <Stack.Item>
            <Box>{data["lastused_total"]} W</Box>
          </Stack.Item>
        </Stack>
      </Section>
      {accessPanel ? data["wiresexposed"] : <></>}
    </Window>
  )
}
