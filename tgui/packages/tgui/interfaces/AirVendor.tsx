/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { LabeledList, NumberInput, Button, Section, Dimmer } from "../components";
import { Window } from '../layouts';
import { VendorCashTable } from './common/VendorCashTable';
import { GasTankInfo } from './GasTank';

type AirVendorParams = {
  cash: number,
  cardname: string,
  bankMoney: number,

  holding: string,
  holding_pressure: number,
  min_pressure: number,
  max_pressure: number,
  fill_cost: number,
  target_pressure: number,
}

const VendorSection = (_props, context) => {
  const { act, data } = useBackend<AirVendorParams>(context);
  const { cash, bankMoney, fill_cost, target_pressure, min_pressure, max_pressure } = data;

  const handleFillClick = () => act('o2_fill');
  const handleChangePressure = (pressure) => act('o2_changepressure', { pressure: pressure });

  const canVend = fill_cost > 0 && (bankMoney > fill_cost || cash > fill_cost);

  return (
    <Section title={"Buy Oxygen!"}>
      <LabeledList>
        <LabeledList.Item label="Cost">
          <Button
            content={(<>{fill_cost || 0}⪽</>)}
            color={canVend ? "green" : "grey"}
            disabled={!canVend}
            onClick={handleFillClick} />
        </LabeledList.Item>
        <LabeledList.Item label="Pressure">
          <Button
            onClick={() => handleChangePressure(min_pressure)}
            content="Min" />
          <NumberInput
            animated
            width={6}
            value={target_pressure}
            minValue={min_pressure}
            maxValue={max_pressure}
            onChange={(_e, new_pressure) => handleChangePressure(new_pressure)} />
          <Button
            onClick={() => handleChangePressure(max_pressure)}
            content="Max" />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TankSection = (_props, context) => {
  const { act, data } = useBackend<AirVendorParams>(context);
  const { holding, holding_pressure, max_pressure } = data;

  const handleTankEject = () => act('o2_eject');
  const handleTankInsert = () => act('o2_insert');

  return (
    <Section title={"Holding Tank"} buttons={
      <Button onClick={handleTankEject} icon="eject" disabled={!holding}>Eject</Button>
    }>
      <GasTankInfo pressure={holding_pressure || 0} maxPressure={max_pressure || 1} name={holding || "N/A"} />
      {!holding && (
        <Dimmer>
          <Button
            icon="eject"
            fontSize={1.5}
            onClick={handleTankInsert}
            bold>
            Insert Gas Tank
          </Button>
        </Dimmer>
      )}
    </Section>
  );
};

export const AirVendor = (_props, context) => {
  const { act, data } = useBackend<AirVendorParams>(context);
  const { cash, cardname, bankMoney } = data;

  const handleCardEject = () => act('logout');
  const handleCashEject = () => act('returncash');

  return (
    <Window
      width={350}
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
