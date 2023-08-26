/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Box, LabeledList, NumberInput, Button, Section, Dimmer } from "../components";
import { Window } from '../layouts';
import { VendorCashTable } from './common/VendorCashTable';
import { GasTankInfo } from './GasTank';

const minRelease = 0;
const maxRelease = 1013.25;

const VendorSection = (_props, context) => {
  const { act, data } = useBackend(context);
  const { cash, bankMoney, fill_cost, target_pressure } = data;

  const handleFillClick = () => act('o2_fill');
  const handleChangePressure = (pressure) => act('o2_changepressure', { pressure: pressure });

  const canVend = () => (fill_cost > 0 && (bankMoney > fill_cost || cash > fill_cost));

  return (
    <Section title={"Status"}>
      <LabeledList>
        <LabeledList.Item label="Fill">
          <Button
            content={(<>{fill_cost || 0}⪽</>)}
            color={canVend() ? "green" : "grey"}
            disabled={!canVend()}
            onClick={handleFillClick} />
        </LabeledList.Item>
        <LabeledList.Item label="Desired pressure">
          <Button
            onClick={() => handleChangePressure(minRelease)}
            content="Min" />
          <NumberInput
            animated
            width="7em"
            value={target_pressure}
            minValue={minRelease}
            maxValue={maxRelease}
            onChange={(_e, target_pressure) => handleChangePressure(target_pressure)} />
          <Button
            onClick={() => handleChangePressure(maxRelease)}
            content="Max" />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TankSection = (_props, context) => {
  const { act, data } = useBackend(context);
  const { holding, holding_pressure } = data;

  const handleTankEject = () => act('o2_eject');
  const handleTankInsert = () => act('o2_insert');

  return (
    <Section title={"Holding Tank"} buttons={
      <Button onClick={handleTankEject} icon="eject">Eject</Button>
    }>
      {holding ? (
        <GasTankInfo pressure={holding_pressure} maxPressure={maxRelease} name={holding} />
      ) : (
        <Box height={5}>
          <Dimmer>
            <Button
              icon="eject"
              fontSize={1.5}
              onClick={handleTankInsert}
              bold>
              Insert Gas Tank
            </Button>
          </Dimmer>
        </Box>
      )}
    </Section>
  );
};

export const AirVendor = (_props, context) => {
  const { act, data } = useBackend(context);
  const { cash, cardname, bankMoney } = data;

  const handleCardEject = () => act('logout');
  const handleCashEject = () => act('returncash');

  return (
    <Window
      width={310}
      height={320}>
      <Window.Content>
        <VendorSection />
        <TankSection />
        <VendorCashTable cardname={cardname} onCardClick={handleCardEject} bankMoney={bankMoney}
          cash={cash} onCashClick={handleCashEject} />
      </Window.Content>
    </Window>
  );
};
