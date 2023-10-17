/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { RemoteAccessButton } from ".";
import { LabeledList } from "../../../components";
import { WirePanelAction } from "./const";
import { WireData } from "./type";

interface WireListProps {
  wires: WireData[];
  act_wire: (wire_index: number, action: WirePanelAction) => void
}

export const WireList =(props: WireListProps) => {
  const { wires, act_wire } = props;
  return (
    <LabeledList>
      {
        wires.map((wire, i) => (
          <Wire
            key={wire.color_name}
            wire={wire}
            act_wire={act_wire}
            dm_index={i + 1}
          />
        ))
      }
    </LabeledList>
  );
};

interface WireProps {
  dm_index: number;
  act_wire: (wire_index: number, action: WirePanelAction) => void
  wire: WireData;
}

export const Wire = (props: WireProps) => {
  const { dm_index, act_wire, wire } = props;
  const { color_name, color_value, is_cut } = wire;
  return (
    <LabeledList.Item label={color_name} labelColor={color_value}>
      { !!is_cut && (
        <RemoteAccessButton
          icon="route"
          content="Mend"
          title="Mend the wire with a snipping tool"
          onClick={() => act_wire(dm_index, WirePanelAction.Mend)}
        />
      )}
      { !is_cut && (
        <>
          <RemoteAccessButton
            icon="cut"
            content="Cut"
            title="Cut the wire with a snipping tool"
            onClick={() => act_wire(dm_index, WirePanelAction.Cut)}
          />
          <RemoteAccessButton
            icon="bolt"
            content="Pulse"
            title="Use a pulsing tool on the wire"
            onClick={() => act_wire(dm_index, WirePanelAction.Pulse)}
          />
        </>
      )}
    </LabeledList.Item>
  );
};
