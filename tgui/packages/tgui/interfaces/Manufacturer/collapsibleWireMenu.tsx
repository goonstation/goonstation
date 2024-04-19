import { useBackend } from "../../backend";
import { Button, Divider, LabeledList, Section } from "../../components";
import { ManufacturerData, WireData } from "./type";

const is_set = (bits, bit) => bits & (1 << bit);

export const CollapsibleWireMenu = (props, context) => {
  const { act } = useBackend<ManufacturerData>(context);
  const { wirePanel } = props;
  return (
    <Section
      textAlign="center"
      title="Maintenence Panel"
    >
      <LabeledList>
        {wirePanel.wires.map((wire: WireData, i: number) => (
          <LabeledList.Item
            key={i}
            label={wire.colorName}
            labelColor={wire.color}
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
              content={(is_set(wirePanel.wire_bitflags, i) !== 0) ? "Cut" : "Mend"}
              onClick={() => act("wire", { action: ((is_set(wirePanel.wire_bitflags, i) !== 0) ? "cut" : "mend"), wire: i+1 })}
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
