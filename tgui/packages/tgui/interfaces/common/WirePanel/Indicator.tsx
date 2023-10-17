/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from "common/react";
import { LabeledList } from "../../../components";
import { WirePanelControl, WirePanelControlLabelMap } from "./const";

interface IndicatorListProps {
  controls_to_show: number,
  active_controls: number,
}

export const IndicatorList = (props: IndicatorListProps) => {
  const { controls_to_show, active_controls } = props;
  return (
    <LabeledList>
      {
        Object.keys(WirePanelControl).map((control) => {
          if (controls_to_show & WirePanelControl[control]) {
            return (
              <Indicator
                key={control}
                control={WirePanelControl[control]}
                status={active_controls & WirePanelControl[control]}
              />
            );
          }
        })
      }
    </LabeledList>
  );
};

interface IndicatorProps {
  control: WirePanelControl,
  status: BooleanLike,
}

const Indicator = (props: IndicatorProps) => {
  const { control, status } = props;
  return (
    <LabeledList.Item label={WirePanelControlLabelMap[control]}>{status ? "Active" : "Inactive"}</LabeledList.Item>
  );
};
