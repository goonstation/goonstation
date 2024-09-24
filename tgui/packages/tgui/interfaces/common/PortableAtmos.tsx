import {
  Box,
  Button,
  LabeledList,
  RoundGauge,
  Section,
} from 'tgui-core/components';

import { formatPressure } from '../../format';

export const PortableBasicInfo = (props) => {
  const { connected, pressure, maxPressure, children } = props;

  return (
    <Section title="Status">
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
        <LabeledList.Item label="Port" color={connected ? 'good' : 'average'}>
          {connected ? 'Connected' : 'Not Connected'}
        </LabeledList.Item>
      </LabeledList>
      {children}
    </Section>
  );
};

export const PortableHoldingTank = (props) => {
  const { holding, onEjectTank, title } = props;

  return (
    <Section
      title={title || 'Holding Tank'}
      minHeight="115px"
      buttons={
        <Button icon="eject" disabled={!holding} onClick={() => onEjectTank()}>
          Eject
        </Button>
      }
    >
      {holding ? (
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <RoundGauge
              size={1.75}
              value={holding.pressure}
              minValue={0}
              maxValue={holding.maxPressure}
              alertAfter={holding.maxPressure * 0.7}
              ranges={{
                good: [0, holding.maxPressure * 0.7],
                average: [
                  holding.maxPressure * 0.7,
                  holding.maxPressure * 0.85,
                ],
                bad: [holding.maxPressure * 0.85, holding.maxPressure],
              }}
              format={formatPressure}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Label">{holding.name}</LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="average">
          No {title ? title.toLowerCase() : 'holding tank'}
        </Box>
      )}
    </Section>
  );
};
