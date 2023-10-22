/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { useBackend } from '../../../backend';
import { Box, Button, Divider, Section } from '../../../components';
import { BooleanLike } from 'common/react';
import type { WirePanelData } from './type';
import { WirePanelControl, WirePanelCoverStatus } from './const';
import { Window } from '../../../layouts';
import { WireList } from './Wire';
import { IndicatorList } from './Indicator';

export const WirePanel = (props, context) => {
  return (
    <Window width={350}>
      <Window.Content>
        <Section title="Maintenance Panel"><WirePanelInsert /></Section>
      </Window.Content>
    </Window>
  );
};

export const WirePanelInsert = (_, context) => {
  const { act, data } = useBackend<WirePanelData>(context);
  const { wire_panel } = data;
  const shouldDisable = getShouldDisable(
    wire_panel.is_silicon_user,
    wire_panel.is_accessing_remotely,
    wire_panel.cover_status,
    wire_panel.active_controls & WirePanelControl.Silicon
  );
  const act_wire = (wire_index: number, action) => {
    act("actwire", { wire_index, action });
  };

  return (
    <Box
      title={`Maintenance Panel${shouldDisable ? ' :: Remote Silicon Access Disabled' : ''}`}
      open={wire_panel.cover_status === WirePanelCoverStatus.Open}
      disabled={!!shouldDisable}>
      <WireList wires={wire_panel.wires} act_wire={act_wire} />
      <Divider />
      <IndicatorList controls_to_show={wire_panel.controls_to_show} active_controls={wire_panel.active_controls} />
    </Box>
  );
};

interface RemoteAccessButtonProps {
  disabled?: BooleanLike;
  icon: string;
  content: string;
  title: string;
  onClick: any;
}

export const RemoteAccessButton = (props: RemoteAccessButtonProps, context) => {
  const { disabled, title, ...rest } = props;
  const { data } = useBackend<WirePanelData>(context);
  const { is_silicon_user, active_controls, is_accessing_remotely, cover_status } = data.wire_panel;
  const shouldDisable = getShouldDisable(
    is_silicon_user,
    is_accessing_remotely,
    cover_status,
    !(active_controls & WirePanelControl.Silicon)
  );
  return <Button title={title} disabled={shouldDisable} {...rest} />;
};

const getShouldDisable = (
  is_silicon_user: BooleanLike,
  is_accessing_remotely: BooleanLike,
  cover_status: WirePanelCoverStatus,
  silicon_control_status: BooleanLike,
) => {
  let shouldDisable = false;
  if (is_silicon_user) {
    if (!silicon_control_status) {
      if (is_accessing_remotely) {
        shouldDisable = true;
      } else {
        shouldDisable = cover_status !== WirePanelCoverStatus.Open;
      }
    }
  } else {
    shouldDisable = cover_status !== WirePanelCoverStatus.Open;
  }
  return shouldDisable;
};
