/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { useBackend } from "../backend";
import { Button, Section, VendorCashTable } from "../components";
import { Window } from '../layouts';

export const AirVendor = (_props, context) => {
  const { act, data } = useBackend(context);
  const { cash, cardname, bankMoney, holding, holding_pressure, fill_cost, target_pressure } = data;

  return (
    <Window
      width={360}
      height={520}
      theme={"neutral"}>
      <Window.Content>
        <Section title={"Status"}>
          <Button onClick={() => act('o2_fill')}>fill</Button>
          {fill_cost};
          {target_pressure}kPa
          <Button onClick={() => act('o2_changepressure')}>changepressure</Button>
        </Section>
        <Section title={"Holding Tank"} buttons={
          <Button onClick={() => act('o2_eject')} icon="eject">Eject</Button>
        }>
          {holding_pressure}kPa;{holding}
        </Section>
        <VendorCashTable cardname={cardname} onCardClick={() => act('logout')} bankMoney={bankMoney}
          cash={cash} onCashClick={() => act('returncash')} />
      </Window.Content>
    </Window>
  );
};
