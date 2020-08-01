import { useBackend } from '../backend';
import { Button, LabeledList, Section, NoticeBox, Box, Icon, ProgressBar, NumberInput, AnimatedNumber, LabeledControls, Flex } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';
import { ReleaseValve } from './common/ReleaseValve';

export const GasCanister = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    connected,
    holding,
    has_valve,
    valve_open,
    pressure,
    max_pressure,
    release_pressure,
    min_release,
    max_release,
  } = data;
  return (
    <Window
      width={400}
      height={370}>
      <Window.Content>
        <PortableBasicInfo />
        <Section>
          { has_valve
            && <ReleaseValve
              valve_open={valve_open}
              release_pressure={release_pressure}
              min_release={min_release}
              max_release={max_release} />}
        </Section>
      </Window.Content>
    </Window>
  );
};


