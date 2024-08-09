import { LabeledList, RoundGauge, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatPressure } from '../format';
import { Window } from '../layouts';
import { ReleaseValve } from './common/ReleaseValve';

interface GasTankData {
  pressure;
  maxPressure;
  maxRelease;
  releasePressure;
  valveIsOpen;
}

export const GasTank = () => {
  const { act, data } = useBackend<GasTankData>();

  const { pressure, maxPressure, valveIsOpen, releasePressure, maxRelease } =
    data;

  const handleSetPressure = (releasePressure) => {
    act('set-pressure', {
      releasePressure,
    });
  };

  const handleToggleValve = () => {
    act('toggle-valve');
  };

  return (
    <Window width={400} height={220}>
      <Window.Content>
        <Section title="Status">
          <GasTankInfo pressure={pressure} maxPressure={maxPressure} />
        </Section>
        <Section>
          <ReleaseValve
            valveIsOpen={valveIsOpen}
            releasePressure={releasePressure}
            maxRelease={maxRelease}
            onToggleValve={handleToggleValve}
            onSetPressure={handleSetPressure}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const GasTankInfo = (props) => {
  const { pressure, maxPressure, name } = props;

  return (
    <LabeledList>
      <LabeledList.Item label="Pressure">
        <RoundGauge
          size={1.75}
          value={pressure}
          minValue={0}
          maxValue={maxPressure}
          alertAfter={maxPressure * 0.7}
          ranges={{
            good: [0, maxPressure * 0.7],
            average: [maxPressure * 0.7, maxPressure * 0.85],
            bad: [maxPressure * 0.85, maxPressure],
          }}
          format={formatPressure}
        />
      </LabeledList.Item>
      {name ? <LabeledList.Item label="Label">{name}</LabeledList.Item> : null}
    </LabeledList>
  );
};
