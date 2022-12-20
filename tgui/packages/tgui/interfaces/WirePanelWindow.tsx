import { Window } from '../layouts';
import { Collapsible } from "../components";
import { WirePanelCoverStatus, WirePanelData, WirePaneThemes } from './common/WirePanel/type';
import { WirePanelShowIndicators, WirePanelShowControls } from './common/WirePanel';
import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';

interface WirePanelTheme {
  wirePanelTheme: number,
}

interface WirePanelComponentProps extends WirePanelTheme {
    cover_status: number
    can_access_remotely: BooleanLike
}

export const WirePanelWindow = (props, context) => {
  const { data } = useBackend<WirePanelData>(context);
  const calcHeight = 0
    + (data.wirePanel.wires.length * 36) // height per wire
    + (data.wirePanelTheme === WirePaneThemes.WPANEL_THEME_INDICATORS ? 110 : 50); // indicators need more space
  return (
    <Window
      width={340}
      height={calcHeight}
    >
      <Window.Content>
        <WirePaneThemeselector wirePanelTheme={data.wirePanelTheme} />
      </Window.Content>
    </Window>
  );
};

export const WirePanelCollapsible = (props: WirePanelComponentProps) => {
  const { wirePanelTheme, cover_status, can_access_remotely } = props;
  return (
    (cover_status === WirePanelCoverStatus.WPANEL_COVER_OPEN || can_access_remotely) && (
      <Collapsible
        title="Wire Panel"
        open>
        <WirePaneThemeselector wirePanelTheme={wirePanelTheme} />
      </Collapsible>
    )
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
