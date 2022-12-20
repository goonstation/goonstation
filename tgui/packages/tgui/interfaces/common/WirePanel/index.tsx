
import { useBackend } from "../../../backend";
import { Blink, Box, Button, Divider, Flex, Stack } from "../../../components";
import { IndicatorProps, WirePanelActions, WirePanelControlLabels, WirePanelData, WireProps } from "./type";

export const WirePanelShowControls = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanel, wirePanelStatic } = data;
  return (
    <Box>
      <Box className="WirePanel-wires-container">
        {wirePanelStatic.wires.map((wire, i) => {
          return (
            <SimpleWire
              key={i}
              index={i}
              name={wire.name}
              value={wire.value}
              cut={wirePanel.wires[i].cut}
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
              name={indicator.name}
              value={indicator.value}
              control={indicator.control}
              status={wirePanel.indicators[i].status}
              pattern={wirePanel.indicators[i].pattern}
            />
          );
        })}
      </Box>
    </Box>
  );
};

export const WirePanelShowIndicators = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanel, wirePanelStatic } = data;
  return (
    <Box>
      <Box className="WirePanel-wires-container">
        {wirePanelStatic.wires.map((wire, i) => {
          return (
            <SimpleWire
              key={i}
              index={i}
              name={wire.name}
              value={wire.value}
              cut={wirePanel.wires[i].cut}
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
                pattern={wirePanel.indicators[i].pattern}
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
              <Button
                mr={3}
                icon="bolt"
                color="yellow"
                content="Pulse"
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_PULSE })}
              />
              <Button
                icon="cut"
                color="red"
                content={"Cut"}
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_CUT })}
              />

            </>
          )}
          { !!cut && (
            <Button
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
