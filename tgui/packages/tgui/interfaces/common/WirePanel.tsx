import { BooleanLike } from "common/react";
import { capitalize } from "common/string";
import { useBackend } from "../../backend";
import { Blink, Box, Button, Collapsible, ColorBox, Flex, Stack } from "../../components";

/*

// Wire Panel Component: Wire Controls
/// Inert wire; no effect/use
#define WIRE_INERT_TODO 0
/// Wire to electrical ground
#define WIRE_GROUND_TODO	(1<<0)
/// Used alone, the sole power wire
#define WIRE_POWER_1_TODO	(1<<1)
/// Used if there is a second power wire
#define WIRE_POWER_2_TODO	(1<<2)
/// Used alone, the sole backup wire
#define WIRE_BACKUP_1_TODO	(1<<3)
/// Used if there is a second backup wire
#define WIRE_BACKUP_2_TODO	(1<<4)
/// Silicon wireless control enabled
#define WIRE_SILICON_TODO	(1<<5)
/// Access restrictions
#define WIRE_ACCESS_TODO	(1<<6)
/// Safety sensors
#define WIRE_SAFETY_TODO	(1<<7)
/// Enforces some limit
#define WIRE_RESTRICT_TODO	(1<<8)
/// Activate the thing
#define WIRE_ACTIVATE_TODO	(1<<9)
/// Recieve data
#define WIRE_RECIEVE_TODO	(1<<10)
/// Transmit data
#define WIRE_TRANSMIT_TODO	(1<<11)

// Wire Panel Component: Cover Status
/// Cover is open and you can access wires
#define PANEL_COVER_OPEN	0
/// Cover closed; default state
#define PANEL_COVER_CLOSED	1
/// Cover is broken; requires repair before opening
#define PANEL_COVER_BROKEN	2
/// Cover is locked; requires unlocking before opening
#define PANEL_COVER_LOCKED	3


*/

interface WireStatic {
    name: string,
    value: string,
}

interface IndicatorsStatic {
  name: string,
  value: string,
  active: string,
  inactive: string,
}

interface WirePanelStatic {
  wires: WireStatic[]
  indicators: IndicatorsStatic[]
}


interface WireDynamic {
  cut: BooleanLike
}

interface IndicatorsDynamic {
  status: BooleanLike,
}

interface WirePanelDynamic {
  wires: WireDynamic[]
  indicators: IndicatorsDynamic[]
  cover_status: number,
  active_wire_controls: number, // bitfield
}

interface WirePanelProps {
  wirePanel: WirePanelDynamic,
  wirePanelStatic: WirePanelStatic
}


// Button-based wire panels
export const WirePanelButtons = (props, context) => {
  const { act, data } = useBackend<WirePanelProps>(context);
  const { wirePanel, wirePanelStatic } = data;
  return (
    (wirePanel.cover_status === 0) && (
      <Collapsible
        open
        mb="1%"
        width="100%"
        title="Wire Panel">
        {wirePanel.wires.map((wire, i) => {
          return (
            <Flex key={i}>
              <Box
                bold
                width="100%"
                mb="5px"
                style={{
                  "border-top": "2px inset black",
                  "border-bottom": "2px inset black",
                }}
              >
                <Box
                  position="absolute"
                  height="22px"
                  ml="10px"
                  pt="3px"
                  pl="4px"
                  pr="9px"
                  fontFamily="cursive"
                  textAlign="center"
                  fontSize="0.9em"
                  backgroundColor="rgba(182,162,142,0.8)"
                  color="black">
                  { capitalize(wirePanelStatic.wires[i].name)}
                </Box>
                <Box
                  align="center"
                  backgroundColor={wirePanelStatic.wires[i].value}
                  height="22px">
                  <Button
                    mt="1px"
                    content={wire.cut ? "Mend" : "Cut"}
                    onClick={() => act("snipwire", {
                      wire: i+1,
                    })}
                  />
                  { !wire.cut && (
                    <Button
                      content="Pulse"
                      ml="20px"
                      onClick={() => act('pulsewire', {
                        wire: i+1,
                      })}
                    />
                  )}
                </Box>
              </Box>
            </Flex>
          );
        })}
        <Stack mt="10px">
          <Stack.Item width="100%" />
          {wirePanel.indicators.map((indicator, i) => {
            return (
              <Stack.Item key={i}>
                { !!indicator.status && (
                  <IndicatorFrame
                    pattern={wirePanelStatic.indicators[i].active}
                    colorValue={wirePanelStatic.indicators[i].value}
                    colorName={wirePanelStatic.indicators[i].name}
                  />
                ) }
                { !indicator.status && (
                  <IndicatorFrame
                    pattern={wirePanelStatic.indicators[i].inactive}
                    colorValue={wirePanelStatic.indicators[i].value}
                    colorName={wirePanelStatic.indicators[i].name}
                  />
                )}
              </Stack.Item>
            );
          })}
        </Stack>
      </Collapsible>
    )
  );
};

const IndicatorFrame = (props) => {
  const { pattern, colorValue, colorName } = props;
  const size = 35;
  return (
    <Box
      width={`${size}px`}
      height={`${size}px`}
      mr="7px"
      position="relative"
      left="-2px"
      top="-2px"
      style={{
        "border-radius": `${size}px`,
        "border": "2px solid rgb(107,108,109)",
      }}
    >
      {
        !!(pattern === "flashing") && <FlashingIndicator color={colorValue} size={size} />
      }
      {
        !!(pattern === "on") && <OnIndicator color={colorValue} size={size} />
      }
      {
        !!(pattern === "off") && <OffIndicator color={colorValue} size={size} />
      }
      <Box textAlign="center"
        p="2px"
        width="130%"
        position="relative"
        top="-9px"
        left="-6px"
        backgroundColor="black"
        fontSize="1em"
        fontFamily="monospace"
        color={colorValue}
        bold
        style={{
          "font-variant": "small-caps",
        }}>
        {colorName}
      </Box>
    </Box>
  );
};


const FlashingIndicator = (props) => {
  const { color, size } = props;

  return (
    <ColorBox
      as="inline-block"
      width={`${size-3}px`}
      height={`${size-3}px`}
      backgroundColor={color}
      style={{
        "border-radius": `${size}px`,
        "border": "2px solid rgba(0,0,0,0.5)",
      }}
      content={
        <Blink>
          <ColorBox
            position="relative"
            left="-2px"
            top="-2px"
            width={`${size-3}px`}
            height={`${size-3}px`}
            backgroundColor="rgba(0,0,0,0.5)"
            style={{
              "border-radius": `${size}px`,
              "border": "6px solid rgba(0,0,0,0.1)",
            }} />
        </Blink>
      }
    />
  );
};

const OffIndicator = (props) => {
  const { color, size } = props;
  return (
    <ColorBox
      as="inline-block"
      width={`${size-3}px`}
      height={`${size-3}px`}
      backgroundColor={color}
      style={{
        "border-radius": `${size-3}px`,
        "border": "2px solid rgba(70,70,70,0.9)",
      }}
      content={
        <ColorBox
          width={`${size-3}px`}
          height={`${size-3}px`}
          position="relative"
          top="-2px"
          left="-2px"
          backgroundColor="rgba(0,0,0,0.8)"
          style={{
            "border-radius": `${size-3}px`,
            "border": "2px solid rgba(200,200,200,0.2)",
          }} />
      }
    />
  );
};
const OnIndicator = (props) => {
  const { color, size } = props;
  return (
    <ColorBox
      as="inline-block"
      width={`${size-3}px`}
      height={`${size-3}px`}
      backgroundColor={color}
      style={{
        "border-radius": `${size}px`,
        "border": "2px solid rgba(0,0,0,0.1)",
      }}
      content={
        <ColorBox
          width={`${size-3}px`}
          height={`${size-3}px`}
          position="relative"
          top="-2px"
          left="-2px"
          backgroundColor="rgba(0,0,0,0.1)"
          style={{
            "border-radius": `${size}px`,
            "border": "2px solid rgba(200,200,200,0.2)",
          }} />
      }
    />
  );
};

// More physical looking wire panels
export const WirePanelSkuemorphic = (props: WirePanelProps) => {

};

export const panelStatus = ["open", "closed", "broken", "locked"];
