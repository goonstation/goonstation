import { Button, Divider, LabeledList, Section } from "./../../components";
import { MaintenancePanel } from "./type";
import { is_set } from './../common/bitflag';

const ManufacturerWireData = [
  { name: "Teal", colorName: "teal" },
  { name: "Red", colorName: "red" },
  { name: "Gold", colorName: "gold" },
  { name: "Lime", colorName: "lime" },
];

export const CollapsibleWireMenu = (props:MaintenancePanel) => {
  const {
    actionWirePulse,
    actionWireCutOrMend,
    indicators,
    wires,
    wire_bitflags,
  } = props;

  return (
    <Section
      textAlign="center"
      title="Maintenance Panel"
    >
      <LabeledList>
        {wires.map((_, i: number) => (
          <LabeledList.Item
            key={i}
            label={ManufacturerWireData[i].name}
            labelColor={ManufacturerWireData[i].colorName}
            buttons={[(<Button
              textAlign="center"
              width={4}
              key={i}
              content="Pulse"
              onClick={() => actionWirePulse(i)}
            />),
            (<Button
              textAlign="center"
              width={4}
              key={i}
              content={is_set(wire_bitflags, wires[i]-1) ? "Cut" : "Mend"}
              onClick={() => actionWireCutOrMend(i, is_set(wire_bitflags, wires[i]-1))}
            />)]}
          />
        ))}
      </LabeledList>
      <Divider />
      <LabeledList>
        <LabeledList.Item
          label="Electrification Risk"
        >
          {indicators.electrified ? "High" : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="System Stability"
        >
          {indicators.malfunctioning ? "Unstable" : "Stable"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Inventory"
        >
          {indicators.hacked ? "Expanded" : "Standard"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Power"
        >
          {indicators.hasPower ? "Sufficient" : "Insufficient"}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
