import {
  Box,
  Button,
  LabeledList,
  RoundGauge,
  Section,
} from 'tgui-core/components';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { formatPressure } from '../../format';

export const TankInfo = (_props) => {
  const { act } = useBackend();
  const { tank, tankNum } = _props;
  let button_eject = (
    <Button
      disabled={tank.name === null}
      icon="eject"
      onClick={() => act(tankNum === 1 ? 'remove_tank_one' : 'remove_tank_two')}
    >
      Eject
    </Button>
  );
  let button_add = (
    <Button icon="add" onClick={() => act('add_item', { tank: tankNum })}>
      Add
    </Button>
  );
  let maxPressure = tank.maxPressure !== null ? tank.maxPressure : 999;
  return (
    <Box minWidth="12rem">
      <Section
        title={tankNum === 1 ? 'Tank One' : 'Tank Two'}
        buttons={tank.name !== null ? button_eject : button_add}
      >
        <LabeledList>
          <LabeledList.Item label="Holding">
            {tank.name !== null ? toTitleCase(tank.name) : 'None'}
          </LabeledList.Item>
          <LabeledList.Item label="Pressure">
            <RoundGauge
              size={1.75}
              value={tank.pressure !== null ? tank.pressure : 0}
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
        </LabeledList>
      </Section>
    </Box>
  );
};
