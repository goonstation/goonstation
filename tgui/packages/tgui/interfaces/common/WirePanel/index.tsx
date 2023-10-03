
import { useBackend } from "../../../backend";
import { Box, Button, Collapsible, Dimmer, Icon } from "../../../components";
import type { WirePanelData } from './type';
import { WirePanelActions, WirePanelControlLabels, WirePanelControls, WirePanelCoverStatus } from './const';
import { BooleanLike } from "common/react";
import { Fragment } from "inferno";

export const WirePanel = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wire_panel } = data;

  const act_wire = (wire_index: number, action) => {
    act("actwire", { wire_index, action });
  };

  return (
    <Box className="wire_panel">
      {
        wire_panel.wires.map((wire, i) => {
          return (
            <Wire
              key={wire.color_name}
              dm_index={i+1}
              color_name={wire.color_name}
              color_value={wire.color_value}
              act_wire={act_wire}
              is_cut={wire.is_cut}
            />
          ); }
        )
      }
      <Indicators
        control_lights={wire_panel.control_lights}
        hacked_controls={wire_panel.hacked_controls}
      />
    </Box>
  );
};

interface WireProps {
  dm_index: number
  color_name: string,
  color_value: string,
  is_cut: BooleanLike,
  act_wire: any
}

const Wire = (data: WireProps) => {
  const { dm_index, color_name, color_value, is_cut, act_wire } = data;
  return (
    <Fragment>
      <Box className="wire_label" label={color_name} color={color_value}>{color_name}</Box>
      <Box className="wire_buttons">
        { !!is_cut && (
          <RemoteAccessButton
            icon="route"
            content={"Mend"}
            onClick={() => act_wire(dm_index, WirePanelActions.WIRE_ACT_MEND)}
          />
        )}
        { !is_cut && (
          <>
            <RemoteAccessButton
              icon="cut"
              content={"Cut"}
              onClick={() => act_wire(dm_index, WirePanelActions.WIRE_ACT_CUT)}
            />
            <RemoteAccessButton
              icon="bolt"
              content="Pulse"
              onClick={() => act_wire(dm_index, WirePanelActions.WIRE_ACT_PULSE)}
            />
          </>
        )}
      </Box>
    </Fragment>
  );
};

interface IndicatorProperties {
  control_lights: number,
  hacked_controls: number
}

const Indicators = (data: IndicatorProperties) => {
  const { control_lights, hacked_controls } = data;
  return (
    <Box className="panel_indicators">
      { (control_lights & WirePanelControls.WIRE_CONTROL_GROUND) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_GROUND]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_GROUND && "On" || "Off"}</Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_POWER_A) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_POWER_A]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_POWER_A && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_POWER_B) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_POWER_B]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_POWER_B && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_BACKUP_A) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_BACKUP_A]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_BACKUP_A && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_BACKUP_B) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_BACKUP_B]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_BACKUP_B && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_SILICON) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_SILICON]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_SILICON && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_ACCESS) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_ACCESS]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_ACCESS && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_SAFETY) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_SAFETY]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_SAFETY && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_LIMITER) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_LIMITER]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_LIMITER && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_TRIGGER) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_TRIGGER]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_TRIGGER && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_RECEIVE) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_RECEIVE]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_RECEIVE && "On" || "Off"} </Box>}
      { (control_lights & WirePanelControls.WIRE_CONTROL_TRANSMIT) && <Box className="indicator_label">{WirePanelControlLabels[WirePanelControls.WIRE_CONTROL_TRANSMIT]}: {hacked_controls & WirePanelControls.WIRE_CONTROL_TRANSMIT && "On" || "Off"} </Box>}
    </Box>
  );
};

// remote silicon wire checks
const RemoteAccessButton = (props, context) => {
  const {
    disabled,
    ...rest
  } = props;
  const { data } = useBackend<WirePanelData>(context);
  const { is_silicon_user, hacked_controls, is_accessing_remotely, cover_status } = data.wire_panel;
  let shouldDisable = false;
  if (is_silicon_user) {
    if ((hacked_controls & WirePanelControls.WIRE_CONTROL_SILICON)) {
      if (is_accessing_remotely) {
        shouldDisable = true;
      } else {
        shouldDisable = cover_status !== WirePanelCoverStatus.WPANEL_COVER_OPEN;
      }
    }
  } else {
    shouldDisable = cover_status !== WirePanelCoverStatus.WPANEL_COVER_OPEN;
  }
  return (
    <Button
      className="WirePanel-wires-generic-button"
      disabled={shouldDisable}
      {...rest}
    />
  );
};

// visually block the entire TGUI window based on silicon control
export const RemoteAccessBlocker = (is_accessing_remotely: BooleanLike, hacked_controls: number) => {
  if (!!is_accessing_remotely
    && (hacked_controls & WirePanelControls.WIRE_CONTROL_SILICON)) {
    return (
      <Dimmer fillPositionedParent>
        <Box
          verticalAlign="top"
          textAlign="center"
          fontSize={2.5}
          fontFamily="Courier"
          bold
          color="red"
        >
          <Box className="fa-stack" fontSize={2} mr={1} height={7}>
            <Icon name="wifi" className="fa-stack-1x" color="blue" />
            <Icon name="ban" className="fa-stack-2x WirePanel-silicon-disabled" />
          </Box>
          <Box inline>REMOTE SILICON<br />ACCESS DISABLED</Box>
          <Box className="fa-stack" fontSize={2} ml={1} height={7}>
            <Icon name="wifi" className="fa-stack-1x" color="blue" />
            <Icon name="ban" className="fa-stack-2x WirePanel-silicon-disabled" />
          </Box>
        </Box>
      </Dimmer>
    );
  }
};

// collapsible wire panel to add into your existing TGUI
export const WirePanelCollapsible = (props, context) => {
  const { data } = useBackend<WirePanelData>(context);
  const { wire_panel } = data;

  let shouldDisable = wire_panel.cover_status !== WirePanelCoverStatus.WPANEL_COVER_OPEN;
  if (wire_panel.is_silicon_user) {
    if ((wire_panel.hacked_controls & WirePanelControls.WIRE_CONTROL_SILICON)) {
      if (wire_panel.is_accessing_remotely) {
        shouldDisable = true;
      }
    }
    else {
      shouldDisable=false;
    }
  }

  return (
    <Collapsible
      title={`Maintenance Panel${shouldDisable ? " :: Remote Silicon Access Disabled": ""}`}
      open={wire_panel.cover_status === WirePanelCoverStatus.WPANEL_COVER_OPEN}
      disabled={!!shouldDisable}
    >
      <WirePanel />
    </Collapsible>
  );
};
