
import { useBackend } from "../../../backend";
import { Blink, Box, Button, Divider, Flex, Stack } from "../../../components";
import { IndicatorProps, WirePanelActions, WirePanelControlLabels, WirePanelControls, WirePanelCoverStatus, WirePanelData, WireProps } from "./type";

export const WirePanelShowControls = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Box>
      <Box className="WirePanel-wires-container">
        {wirePanelStatic.wires.map((wire, i) => {
          return (
            <SimpleWire
              key={i}
              index={i}
              name={wirePanelStatic.wires[i].name}
              value={wirePanelStatic.wires[i].value}
              cut={wirePanelDynamic.wires[i].cut}
              act={act}
            />
          );
        })}
      </Box>
      <Divider />
      <Box className="WirePanel-control-container">
        {wirePanelStatic.indicators.map((indicator, i) => {
          return (
            <SimpleControl
              key={i}
              name={wirePanelStatic.indicators[i].name}
              value={wirePanelStatic.indicators[i].value}
              control={wirePanelStatic.indicators[i].control}
              status={(wirePanelDynamic.active_wire_controls & indicator.control)}
              pattern={wirePanelDynamic.indicators[i].pattern}
            />
          );
        })}
      </Box>
    </Box>
  );
};

export const WirePanelShowIndicators = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Box>
      <Box className="WirePanel-wires-container">
        {wirePanelStatic.wires.map((wire, i) => {
          return (
            <SimpleWire
              key={i}
              index={i}
              name={wirePanelStatic.wires[i].name}
              value={wirePanelStatic.wires[i].name}
              cut={wirePanelDynamic.wires[i].cut}
              act={act}
            />
          );
        })}
      </Box>
      <Box className="WirePanel-indicator-container">
        <Stack>
          {wirePanelStatic.indicators.map((indicator, i) => {
            return (
              <IndicatorFrame
                key={i}
                pattern={wirePanelDynamic.indicators[i].pattern}
                colorValue={wirePanelStatic.indicators[i].value}
                colorName={wirePanelStatic.indicators[i].name}
              />
            );
          })}
        </Stack>
      </Box>
    </Box>
  );
};


const SimpleWire = (props: WireProps) => {
  const { act, name, value, cut, index } = props;
  return (
    <Box style={{ "background-color": value }} too>
      <Flex fill className="WirePanel-wires-wire" >
        <Flex.Item grow className="WirePanel-wires-name">
          <Box className="WirePanel-wires-label">{name}</Box>
        </Flex.Item>
        <Flex.Item className="wirePanel-wires-buttons">
          { !cut && (
            <>
              <RemoteAccessButton
                mr={3}
                icon="bolt"
                color="yellow"
                content="Pulse"
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_PULSE })}
              />
              <RemoteAccessButton
                icon="cut"
                color="red"
                content={"Cut"}
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_CUT })}
              />

            </>
          )}
          { !!cut && (
            <RemoteAccessButton
              icon="route"
              color="green"
              content={"Mend"}
              onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_MEND })}
            />
          )}
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const SimpleControl = (props: IndicatorProps) => {
  const { name, value, control, pattern, status } = props;
  return (
    <Box className="WirePanel-control-pair">
      <Box className="WirePanel-control-label">{WirePanelControlLabels[control]}: </Box>
      <Box className="WirePanel-control-value">{status ? "Enabled" : "Disabled" }</Box>
    </Box>
  );
};

const IndicatorFrame = (props) => {
  const { pattern, colorValue, colorName } = props;
  return (
    <Box className="WirePanel-indicator-frame">
      <Box className="WirePanel-indicator-light-backing" backgroundColor={colorValue}>
        {!!(pattern === "on") && <OnIndicator />}
        {!!(pattern === "off") && <OffIndicator /> }
        {!!(pattern === "flashing") && (<Blink><OffIndicator /></Blink>)}
      </Box>
    </Box>
  );
};

const OffIndicator = () => {
  return (<Box className="WirePanel-indicator-light-off" content={<IndicatorFacing />} />);
};
const OnIndicator = () => {
  return (<Box className="WirePanel-indicator-light-on" content={<IndicatorFacing />} />);
};
const IndicatorFacing = () => {
  return (<Box className="WirePanel-indicator-light-facing" />);
};

const RemoteAccessButton = (props, context) => {
  const {
    disabled,
    ...rest
  } = props;
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic } = data;
  let shouldDisable = false;
  if (wirePanelDynamic.is_silicon_user) {
    if (!(wirePanelDynamic.active_wire_controls & WirePanelControls.WIRE_CONTROL_SILICON)) {
      if (wirePanelDynamic.is_accessing_remotely) {
        shouldDisable = true;
      } else {
        shouldDisable = wirePanelDynamic.cover_status !== WirePanelCoverStatus.WPANEL_COVER_OPEN;
      }
    }
  } else {
    shouldDisable = wirePanelDynamic.cover_status !== WirePanelCoverStatus.WPANEL_COVER_OPEN;
  }
  return (
    <Button
      disabled={shouldDisable}
      {...rest}
    />
  );
};
