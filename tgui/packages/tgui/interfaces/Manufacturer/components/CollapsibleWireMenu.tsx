/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { Button, Divider, LabeledList, Section } from 'tgui-core/components';

import { is_set } from '../../common/bitflag';
import { WIRE_PANEL_BUTTONS_WIDTH } from '../constant';
import { WireIndicatorsData } from '../type';

const ManufacturerWireData = [
  { name: 'Teal', colorName: 'teal' },
  { name: 'Red', colorName: 'red' },
  { name: 'Gold', colorName: 'gold' },
  { name: 'Lime', colorName: 'lime' },
];

export type MaintenanceProps = {
  onWirePulse: (index: number) => void;
  onWireCutOrMend: (index: number) => void;
  indicators: WireIndicatorsData;
  wires: number[];
  wire_bitflags: number;
};

export const CollapsibleWireMenu = (props: MaintenanceProps) => {
  const { onWirePulse, onWireCutOrMend, indicators, wires, wire_bitflags } =
    props;

  return (
    <Section textAlign="center" title="Maintenance Panel">
      <LabeledList>
        {wires?.map((_, i: number) => (
          <LabeledList.Item
            key={i}
            label={ManufacturerWireData[i].name}
            labelColor={ManufacturerWireData[i].colorName}
            buttons={
              <>
                <Button
                  width={WIRE_PANEL_BUTTONS_WIDTH}
                  textAlign="center"
                  key={i}
                  onClick={() => onWirePulse(i)}
                >
                  Pulse
                </Button>
                <Button
                  width={WIRE_PANEL_BUTTONS_WIDTH}
                  textAlign="center"
                  key={i}
                  onClick={() => onWireCutOrMend(i)}
                >
                  {is_set(wire_bitflags, wires[i] - 1) ? 'Cut' : 'Mend'}
                </Button>
              </>
            }
          />
        ))}
      </LabeledList>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Electrification Risk">
          {indicators?.electrified ? 'High' : 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="System Stability">
          {indicators?.malfunctioning ? 'Unstable' : 'Stable'}
        </LabeledList.Item>
        <LabeledList.Item label="Inventory">
          {indicators?.hacked ? 'Expanded' : 'Standard'}
        </LabeledList.Item>
        <LabeledList.Item label="Power">
          {indicators?.hasPower ? 'Sufficient' : 'Insufficient'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
