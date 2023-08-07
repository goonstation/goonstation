import { useBackend } from '../backend';
import { LabeledList, Section } from '../components';
import { Window } from '../layouts';


export const ArtemisEngine = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    fuel_tank,
    fuel_buffer,
    exciter_stat,
    casing_integrity,
    casing_rate,
    coil_strength,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Fuel">
          <LabeledList>
            <LabeledList.Item label="Fuel Tank">
              {fuel_tank}
            </LabeledList.Item>
            <LabeledList.Item label="Fuel in buffer">
              {fuel_buffer}
            </LabeledList.Item>
            <LabeledList.Divider>
              what does this do
            </LabeledList.Divider>
            <LabeledList.Item label="Total Fuel">{fuel_buffer+fuel_tank}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="engine statistics">
          <LabeledList.Item label="exciter coversion rate">
            {exciter_stat}
          </LabeledList.Item>
          <LabeledList.Item label="casing integrity">
            {casing_integrity}
          </LabeledList.Item>
          <LabeledList.Item label="casing degredation rate">
            {casing_rate}
          </LabeledList.Item>
          <LabeledList.Item label="Coil field strength">
            {coil_strength}
          </LabeledList.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};
