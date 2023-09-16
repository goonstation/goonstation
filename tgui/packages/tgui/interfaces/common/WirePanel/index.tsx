
import { useBackend } from "../../../backend";
import { Blink, Box, Button, Divider, Flex, Section, Stack, Tooltip } from "../../../components";
import { capitalize } from "../stringUtils";
import type { WirePanelData, WireProps, IndicatorProps } from './type';
import { WirePanelControls, WirePanelCoverStatus, WirePanelActions, WirePanelControlLabels } from './const';

export const TextWires = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Box className="WirePanel-wires-container">
      {wirePanelStatic.wires.map((wire, i) => {
        return (
          <TextWire
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
  );
};

export const PhysicalWires = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Box className="WirePanel-wires-container">
      {wirePanelStatic.wires.map((wire, i) => {
        return (
          <PhysicalWire
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
  );

};
export const TextControls = (props, context) => {
  const { data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <>
      <Divider />
      <Box className="WirePanel-control-container">
        {wirePanelStatic.indicators.map((indicator, i) => {
          return (
            <TextControl
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
    </>
  );
};

export const PhysicalControls = (props, context) => {
  const { data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Box className="WirePanel-indicator-container">
      <Stack>
        {wirePanelStatic.indicators.map((indicator, i) => {
          return (
            <PhysicalControl
              key={i}
              pattern={wirePanelDynamic.indicators[i].pattern}
              colorValue={wirePanelStatic.indicators[i].value}
              colorName={wirePanelStatic.indicators[i].name}
            />
          );
        })}
      </Stack>
    </Box>
  );
};

export const WirePanelShowControls = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Box>
      <Box className="WirePanel-wires-container">
        {wirePanelStatic.wires.map((wire, i) => {
          return (
            <PhysicalWire
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
            <TextControl
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
            <PhysicalWire
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
      <Box className="WirePanel-indicator-container">
        <Stack>
          {wirePanelStatic.indicators.map((indicator, i) => {
            return (
              <PhysicalControl
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

export const WirePanelAirlocks = (props, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wirePanelDynamic, wirePanelStatic } = data;
  return (
    <Section title="Maintenance Panel">
      <Box>
        <Box className="WirePanel-wires-container">
          {wirePanelStatic.wires.map((wire, i) => {
            return (
              <TextWire
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
              <TextControl
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
    </Section>
  );
};

const TextWire = (props: WireProps) => {
  const { act, name, value, cut, index } = props;
  return (
    <Box>
      <Flex fill className="WirePanel-wires-airlock-wire" >
        <Flex.Item grow className="WirePanel-wires-airlock-name">
          <Box className="WirePanel-wires-airlock-label" textColor={value}>{capitalize(name)} wire:</Box>
        </Flex.Item>
        <Flex.Item className="wirePanel-wires-airlock-buttons">
          { !!cut && (
            <RemoteAccessButton
              icon="route"
              content={"Mend"}
              onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_MEND })}
            />
          )}
          { !cut && (
            <>
              <RemoteAccessButton
                icon="cut"
                content={"Cut"}
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_CUT })}
              />
              <RemoteAccessButton
                icon="bolt"
                content="Pulse"
                onClick={() => act("actwire", { wire: index + 1, action: WirePanelActions.WIRE_ACT_PULSE })}
              />
            </>
          )}
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const PhysicalWire = (props: WireProps) => {
  const { act, name, value, cut, index } = props;
  return (
    <Box style={{ "background-color": value }}>
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

const TextControl = (props: IndicatorProps) => {
  const { name, value, control, pattern, status } = props;
  return (
    <Box className="WirePanel-control-pair">
      <Box className="WirePanel-control-label">{WirePanelControlLabels[control]}: </Box>
      { !!status && (
        <Box className="WirePanel-control-value" textColor="green">Enabled</Box>

      )}
      { !status && (
        <Box className="WirePanel-control-value" textColor="red">Disabled</Box>

      )}
    </Box>
  );
};

const PhysicalControl = (props) => {
  const { pattern, colorValue, colorName } = props;
  return (
    <Box className="WirePanel-indicator-frame">
      <Box className="WirePanel-indicator-light-backing" backgroundColor={colorValue}>
        <Tooltip content={`${capitalize(colorName)} light is ${pattern}`}>
          {!!(pattern === "on") && <OnIndicator />}
          {!!(pattern === "off") && <OffIndicator /> }
          {!!(pattern === "blink") && <BlinkIndicator />}
        </Tooltip>
      </Box>
    </Box>
  );
};


const BlinkIndicator = () => {
  return (
    <Blink>
      <Box className="WirePanel-indicator-light-off" content={<IndicatorFacing />} />
    </Blink>
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
      className="WirePanel-wires-generic-button"
      disabled={shouldDisable}
      {...rest}
    />
  );
};
