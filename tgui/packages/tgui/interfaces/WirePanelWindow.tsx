import { Window } from '../layouts';
import { Box, Collapsible, Dimmer, Icon, Section, Stack } from "../components";
import { WirePanelControls, WirePanelCoverStatus, WirePanelData, WirePanelDynamic, WirePanelTheme, WirePanelThemes } from './common/WirePanel/type';
import { SimpleWires, SkeuomorphicWires, SimpleControls, SkeuomorphicControls } from './common/WirePanel';
import { useBackend } from '../backend';
import { InfernoNode } from 'inferno';

interface WirePanelComponentProps {
  wirePanelDynamic: WirePanelDynamic
  wirePanelTheme?: WirePanelTheme
}

export const WirePanelWindow = (props, context) => {
  const { data } = useBackend<WirePanelData>(context);
  const { wireTheme, controlTheme, windowTheme } = data.wirePanelTheme;
  const theme = windowTheme ? windowTheme : "default";
  let calcHeight = 78;

  switch (wireTheme) {
    case WirePanelThemes.WPANEL_THEME_TEXT:
      calcHeight += data.wirePanelDynamic.wires.length * 27; // height per wire
      break;
    case WirePanelThemes.WPANEL_THEME_PHYSICAL:
      calcHeight += data.wirePanelDynamic.wires.length * 36; // height per wire
      break;
  }
  switch (controlTheme) {
    case WirePanelThemes.WPANEL_THEME_TEXT:
      calcHeight += (data.wirePanelDynamic.indicators.length / 2) * 55; // dynamic; paired
      break;
    case WirePanelThemes.WPANEL_THEME_PHYSICAL:
      calcHeight += 80; // static height
      break;
  }
  return (
    <Window
      width={350}
      height={calcHeight}
      theme={theme}
    >
      <Window.Content>
        <Section title="Maintenance Panel">
          <WirePanelThemeSelector wireTheme={wireTheme} controlTheme={controlTheme} />
        </Section>
      </Window.Content>
    </Window>
  );
};

export interface WirePanelStackProps {
  children?: InfernoNode
}

export const WirePanelStack = (props, context) => {
  const { children, ...rest } = props;
  const { data } = useBackend<WirePanelData>(context);
  const { wirePanelTheme, wirePanelDynamic } = data;
  return (
    <Stack {...rest}>
      <WirePanelStackItem wirePanelTheme={wirePanelTheme} wirePanelDynamic={wirePanelDynamic} />
      { children }
      <RemoteAccessBlocker wirePanelDynamic={wirePanelDynamic} />
    </Stack>
  );
};

export const WirePanelStackItem = (props: WirePanelComponentProps) => {
  const { wirePanelTheme, wirePanelDynamic } = props;
  if (wirePanelDynamic.cover_status === WirePanelCoverStatus.WPANEL_COVER_OPEN || !!wirePanelDynamic.is_silicon_user) {
    return (
      <Stack.Item>
        <WirePanelCollapsible wirePanelTheme={wirePanelTheme} wirePanelDynamic={wirePanelDynamic} />
      </Stack.Item>
    );
  }
};

const WirePanelCollapsible = (props: WirePanelComponentProps) => {
  const { wirePanelTheme, wirePanelDynamic } = props;
  let shouldDisable = wirePanelDynamic.cover_status !== WirePanelCoverStatus.WPANEL_COVER_OPEN;
  if (wirePanelDynamic.is_silicon_user) {
    if (!(wirePanelDynamic.active_wire_controls & WirePanelControls.WIRE_CONTROL_SILICON)) {
      if (wirePanelDynamic.is_accessing_remotely) {
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
      open={wirePanelDynamic.cover_status === WirePanelCoverStatus.WPANEL_COVER_OPEN}
      disabled={!!shouldDisable}
    >
      <WirePanelThemeSelector wireTheme={wirePanelTheme.wireTheme} controlTheme={wirePanelTheme.controlTheme} />
    </Collapsible>
  );
};

const WirePanelThemeSelector = (props: WirePanelTheme) => {
  const { wireTheme, controlTheme } = props;
  return (
    <>
      { (wireTheme === WirePanelThemes.WPANEL_THEME_TEXT || !wireTheme) && (
        <SimpleWires />
      )}
      { (wireTheme === WirePanelThemes.WPANEL_THEME_PHYSICAL) && (
        <SkeuomorphicWires />
      )}
      {(controlTheme === WirePanelThemes.WPANEL_THEME_TEXT || !controlTheme) && (
        <SimpleControls />
      )}
      {(controlTheme === WirePanelThemes.WPANEL_THEME_PHYSICAL) && (
        <SkeuomorphicControls />
      )}
    </>
  );
};

export const RemoteAccessBlocker = (props:WirePanelComponentProps) => {
  const { is_accessing_remotely, active_wire_controls } = props.wirePanelDynamic;
  if (!!is_accessing_remotely
    && !(active_wire_controls & WirePanelControls.WIRE_CONTROL_SILICON)) {
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
