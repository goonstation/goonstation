import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber } from '../components';
import { Window } from '../layouts';
import { PressureBar } from './common/PressureBar';
import { GasTankInfo } from './common/GasTankInfo';
import { ReleaseValve } from './common/ReleaseValve';

export const GasTank = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    pressure,
    max_pressure,
    valve_open,
    release_pressure,
    max_release,
  } = data;

  return (
    <Window width={400} height={250}>
      <Window.Content>
        <Section title="Status">
          <GasTankInfo pressure={pressure} max_pressure={max_pressure} />
        </Section>
        <Section>
          <ReleaseValve
            valve_open={valve_open}
            release_pressure={release_pressure}
            max_release={max_release} />
        </Section>
      </Window.Content>
    </Window>
  );

};
