
import { capitalize } from "common/string";
import { useBackend } from "../../../backend";
import { Blink, Box, Button, ColorBox, Divider, Flex, Stack } from "../../../components";
import { IndicatorProps, WirePanelActions, WirePanelControlLabels, WirePanelData, WireProps } from "./type";


export const WirePaneControls = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanel, wirePanelStatic } = data;
  return (
    <Box>
      <Box>
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
      <Box>
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

const SimpleWire = (props: WireProps) => {
  const { act, name, value, cut, index } = props;
  return (
    <Flex fill verticalAlign="bottom" height={2}>
      <Flex.Item
        pt={0.4}
        grow
        bold
        textColor={value}>
        {capitalize(name)}
      </Flex.Item>
      <Flex.Item verticalAlign="bottom">
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
  );
};

const SimpleControl = (props: IndicatorProps) => {
  const { name, value, control, pattern, status } = props;
  const label_distance = 1;
  const row_spacing = 0.5;
  return (
    <Box width="50%" inline mt={row_spacing} mb={row_spacing}>
      <Box inline bold width="50%" color="grey" mr={label_distance}>{WirePanelControlLabels[control]}: </Box>
      <Box inline mr={-label_distance}>{status ? "Enabled" : "Disabled" }</Box>
    </Box>
  );
};

export const WirePanelIndicators = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanel, wirePanelStatic } = data;
  return (
    <Box>
      <Box>
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
      <Box>
        <Stack>
          <Stack.Item width="100%" />
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

const IndicatorFrame = (props) => {
  const { pattern, colorValue, colorName } = props;
  return (
    <Box
      textAlign="center"
      height={4}
      width={3}
      mt={1}
      mr={1}
      style={{
        "border-radius": "30px",
        "border": "2px solid rgb(107,108,109)",
      }}
    >
      {
        !!(pattern === "flashing") && <FlashingIndicator color={colorValue} />
      }
      {
        !!(pattern === "on") && <OnIndicator color={colorValue} />
      }
      {
        !!(pattern === "off") && <OffIndicator color={colorValue} />
      }
    </Box>
  );
};

const FlashingIndicator = (props) => {
  const { color } = props;

  return (
    <ColorBox
      width="100%"
      height="100%"
      backgroundColor={color}
      style={{
        "border-radius": `30px`,
        "border": "2px solid rgba(0,0,0,0.7)",
      }}
      content={
        <Blink>
          <ColorBox
            width="100%"
            height="100%"
            backgroundColor="rgba(0,0,0,0.5)"
            style={{
              "border-radius": `30px`,
              "border": "2px solid rgba(200,200,200,0.2)",
            }} />
        </Blink>
      }
    />
  );
};
const OffIndicator = (props) => {
  const { color } = props;
  return (
    <ColorBox
      as="inline-block"
      width="100%"
      height="100%"
      backgroundColor={color}
      style={{
        "border-radius": `30px`,
        "border": "2px solid rgba(0,0,0,0.7)",
      }}
      content={
        <ColorBox
          width="100%"
          height="100%"
          backgroundColor="rgba(0,0,0,0.5)"
          style={{
            "border-radius": `30px`,

          }} />
      }
    />
  );
};
const OnIndicator = (props) => {
  const { color } = props;
  return (
    <ColorBox
      as="inline-block"
      width="100%"
      height="100%"
      backgroundColor={color}
      style={{
        "border-radius": `30px`,
        "border": "2px solid rgba(200,200,200,0.2)",

      }}
      content={
        <ColorBox
          width="100%"
          height="100%"
          backgroundColor="rgba(0,0,0,0.1)"
          style={{
            "border-radius": `30px`,
            "border": "2px solid rgba(200,200,200,0.2)",
          }} />
      }
    />
  );
};

