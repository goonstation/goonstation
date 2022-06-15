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


export const OFF = 0
export const ON = 1
export const AUTO = 2

export const POWER_CHANNEL_EQUIPMENT = 1
export const POWER_CHANNEL_LIGHTING = 2
export const POWER_CHANNEL_ENVIRONMENTAL = 3

export const WIRE_ORANGE = 1
export const WIRE_DARK_RED = 2
export const WIRE_WHITE = 3
export const WIRE_YELLOW = 4

export const WIRE_ACTION_CUT = 1
export const WIRE_ACTION_PULSE = 2
export const WIRE_ACTION_BITE = 3
export const WIRE_ACTION_MEND = 4

export const WIRE_STATE_CUT = 1
export const WIRE_STATE_WHOLE = 2
export const WIRE_STATE_PULSED = 3

export const PowerChannelSection = (props) => {
  const {
    powerChannel,
    locked,
    act,
  }

  const powerChannelToLabel = (powerChannel) => {
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

  const powerChannelLabel = powerChannelToLabel(powerChannel)

  const onPowerChannelUpdate = (value) => {
    act("updatePowerChannel", { powerChannel, value })
  }

  const offControl

  return (
    <Stack >
      <Stack.Item>
        <Box>
          {powerChannelLabel}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button label="off" onClick={() => {updatePowerChannel(OFF)}}/>
      </Stack.Item>
     <Stack.Item>
        <Button label="on" onClick={() => {updatePowerChannel(ON)}}/>
      </Stack.Item>
     <Stack.Item>
        <Button label="auto" onClick={() => {updatePowerChannel(AUTO)}}/>
      </Stack.Item>
      <Stack.Item>
        <Light></Light>
      </Stack.Item>
    </Stack>
  )
}

export const Wire = (props) => {
  const {
    wire,
    act,
  }

  const wireColorToString = (wire) => {
    switch (wire) {
      case WIRE_ORANGE:
        return "orange"
      case WIRE_DARK_RED:
        return "dark red"
      case WIRE_WHITE:
        return "white"
      case WIRE_YELLOW:
        return "yellow"
      default:
        return "unknown"
    }
  }

  const color = wireColorToString(wire)

  const onUpdate = (value) => {
    act("updateWire", { wire, value })
  }

  return (
    <Stack>
      <Stack.Item>
        <Box>{color}</Box>
      </Stack.Item>
      <Stack.Item>
        <Button label="update" onClick={onUpdate}/>
      </Stack.Item>
    </Stack>
  )
}

export const AccessPanel = (props, context) => {
  const {
    identifier,
    wires,
    act
  } = props;

  const orange_wire = wires[WIRE_ORANGE]
  const dark_red_wire = wires[WIRE_DARK_RED]
  const white_wire = wires[WIRE_WHITE]
  const yellow_wire = wires[WIRE_YELLOW]

  return (
    <Section label="Access Panel">
      <Box>An identifier is engraved above the APC's wires: {}</Box>
      <Wire wireColor={WIRE_ORANGE} onUpdate={onWireUpdate}/>
      <Wire wireColor={WIRE_DARK_RED} onUpdate={onWireUpdate}/>
      <Wire wireColor={WIRE_WHITE} onUpdate={onWireUpdate}/>
      <Wire wireColor={WIRE_YELLOW} onUpdate={onWireUpdate}/>
    </Section>
  )

}

export const Apc = (props, context) => {
  const { act, data } = useBackend(context);

  let accessPanel;
  if (data.accessPanel) {
    accessPanel = <AccessPanel identifier={data.accessPanel.identifier} wires={data.accessPanel.wires} act={act}/>
  } else {
    accessPanel = <></>
  }

  const onMainBreakerChange = (value) => {
    act("mainBreaker", { value });
  }

  return (
    <Window title="Area Power Controller">
      <Section title="Main">
        <LabeledControls></LabeledControls>
      </Section>

      <Section title="PowerChannel">
        <PowerChannelSection powerChannel={POWER_CHANNEL_EQUIPMENT} locked={} act={act}/>
        <PowerChannelSection powerChannel={POWER_CHANNEL_LIGHTING} locked={} act={act}/>
        <PowerChannelSection powerChannel={POWER_CHANNEL_ENVIRONMENTAL} locked={} act={act}/>
      </Section>
      {accessPanel}
    </Window>
  )



}
