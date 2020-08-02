import { useBackend } from '../backend';
import { Button, LabeledList, Section, NoticeBox, Box, Icon, ProgressBar, NumberInput, AnimatedNumber, LabeledControls, Flex } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReleaseValve } from './common/ReleaseValve';

export const GasCanister = (props, context) => {
  const { data } = useBackend(context);
  const {
    holding,
    has_valve,
    valve_open,
    release_pressure,
    min_release,
    max_release,
    detonator,
  } = data;
  return (
    <Window
      key={holding}
      width={400}
      height={holding ? 370 : 330}>
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
        <PortableHoldingTank />
      </Window.Content>
    </Window>
  );
};


