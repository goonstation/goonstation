import { useBackend } from "../../backend";
import { Button, Divider, LabeledList, Section } from "../../components";
import { ManufacturerData } from "./type";

const is_set = (bits, bit) => bits & (1 << bit);

const ManufacturerWireData = [
  { name: "Teal", colorName: "teal" },
  { name: "Red", colorName: "red" },
  { name: "Gold", colorName: "gold" },
  { name: "Lime", colorName: "lime" },
];

export const CollapsibleWireMenu = (props, context) => {
  const { act } = useBackend<ManufacturerData>(context);
  const { wirePanel } = props;

  return (
    <Section
      textAlign="center"
      title="Maintenance Panel"
    >
      <LabeledList>
        {wirePanel.wires.map((_, i: number) => (
          <LabeledList.Item
            key={i}
            label={ManufacturerWireData[i].name}
            labelColor={ManufacturerWireData[i].colorName}
            buttons={[(<Button
              textAlign="center"
              width={4}
              key={i}
              content="Pulse"
              onClick={() => act('wire', { action: "pulse", wire: i+1 })}
            />),
            (<Button
              textAlign="center"
              width={4}
              key={i}
              content={is_set(wirePanel.wire_bitflags, wirePanel.wires[i]-1) ? "Cut" : "Mend"}
              onClick={() => act("wire", { action: (is_set(wirePanel.wire_bitflags, wirePanel.wires[i]-1) ? "cut" : "mend"), wire: i+1 })}
            />)]}
          />
        ))}
      </LabeledList>
      <Divider />
      <LabeledList>
        <LabeledList.Item
          label="Electrification Risk"
        >
          {wirePanel.indicators.electrified ? "High" : "None"}
        </LabeledList.Item>
        <LabeledList.Item
          label="System Stability"
        >
          {wirePanel.indicators.malfunctioning ? "Unstable" : "Stable"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Inventory"
        >
          {wirePanel.indicators.hacked ? "Expanded" : "Standard"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Power"
        >
          {wirePanel.indicators.hasPower ? "Sufficient" : "Insufficient"}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
