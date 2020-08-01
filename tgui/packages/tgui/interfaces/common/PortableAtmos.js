import { useBackend } from '../../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber } from '../../components';
import { PressureBar } from './PressureBar';
import { GasTankInfo } from './GasTankInfo';

export const PortableBasicInfo = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    holding,
    on,
    pressure,
    max_pressure,
  } = data;

  return (
    <Fragment>
      <Section
        title="Status"
        buttons={(
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('toggle-on')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Port"
            color={connected ? 'good' : 'average'}>
            {connected ? 'Connected' : 'Not Connected'}
          </LabeledList.Item>
        </LabeledList>
        <br />
        <PressureBar
          pressure={pressure}
          max_pressure={max_pressure} />
      </Section>
      <Section
        title="Holding Tank"
        minHeight="82px"
        buttons={(
          <Button
            icon="eject"
            content="Eject"
            disabled={!holding}
            onClick={() => act('eject-tank')} />
        )}>
        {holding ? (
          <Fragment>
            <LabeledList>
              <LabeledList.Item label="Label">
                {holding.name}
              </LabeledList.Item>
              <LabeledList.Item label="Pressure">
                <AnimatedNumber
                  value={holding.pressure} />
                {' kPa'}
              </LabeledList.Item>
            </LabeledList>
            <br />
            <PressureBar
              pressure={holding.pressure}
              max_pressure={holding.max_pressure} />
          </Fragment>
        ) : (
          <Box color="average">
            No holding tank
          </Box>
        )}
      </Section>
    </Fragment>
  );
};
