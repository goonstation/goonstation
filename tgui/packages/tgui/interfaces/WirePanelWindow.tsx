import { Window } from '../layouts';
import { Collapsible, Stack } from "../components";
import { WirePanelControls, WirePanelCoverStatus, WirePanelData, WirePanelDynamic, WirePaneThemes } from './common/WirePanel/type';
import { WirePanelShowIndicators, WirePanelShowControls } from './common/WirePanel';
import { useBackend } from '../backend';
import { decodeHtmlEntities } from 'common/string';
import { capitalize } from './common/stringUtils';

interface WirePanelTheme {
  wirePanelTheme: number,
}

interface WirePanelComponentProps extends WirePanelTheme {
  wirePanelDynamic: WirePanelDynamic
}

export const WirePanelWindow = (props, context) => {
  const { config, data } = useBackend<WirePanelData>(context);
  const calcHeight = 0
    + (data.wirePanelDynamic.wires.length * 36) // height per wire
    + (data.wirePanelTheme === WirePaneThemes.WPANEL_THEME_INDICATORS ? 110 : 50); // indicators need more space
  const objectTitle = capitalize(decodeHtmlEntities(config.title));
  return (
    <Window
      width={340}
      height={calcHeight}
      title={objectTitle + " Wire Panel"}
    >
      <Window.Content>
        <WirePaneThemeselector wirePanelTheme={data.wirePanelTheme} />
      </Window.Content>
    </Window>
  );
};

export const WirePanelStackItem = (props, context) => {
  const { data } = useBackend<WirePanelData>(context);
  const { wirePanelTheme, wirePanelDynamic } = data;
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
      title="Wire Panel"
      open={wirePanelDynamic.cover_status === WirePanelCoverStatus.WPANEL_COVER_OPEN}
      disabled={shouldDisable}>
      <WirePaneThemeselector wirePanelTheme={wirePanelTheme} />
    </Collapsible>
  );
};



const WirePaneThemeselector = (props: WirePanelTheme) => {
  const { wirePanelTheme } = props;
  return (
    <>
      { (wirePanelTheme === WirePaneThemes.WPANEL_THEME_CONTROLS || !wirePanelTheme) && (
        <WirePanelShowControls />
      )}
      { wirePanelTheme === WirePaneThemes.WPANEL_THEME_INDICATORS && (
        <WirePanelShowIndicators />
      )}
    </>
  );
};
