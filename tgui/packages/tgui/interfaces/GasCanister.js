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
    on,
    pressure,
    max_pressure,
  } = data;
  return (
    <Window
      width={400}
      height={700}>
      <Window.Content>
        <PortableBasicInfo />
        <Section>
          <ReleaseValve
            valve_open={on}
            release_pressure={0}
            min_release={0}
            max_release={0} />
        </Section>
      </Window.Content>
    </Window>
  );
};


