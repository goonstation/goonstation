/**
 * @file
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

import { useBackend } from '../backend';
import { Button } from '../components';
import { Window } from '../layouts';

export interface CashregData {
  owner: any;
  amount: number;
}

export const Cashreg = (_, context) => {
  const { act, data } = useBackend<CashregData>(context);
  const { owner, amount } = data;

  return (
    <Window title="AAAAAAA" width={300} height={200}>
      <Window.Content>
        <Button icon="id-card" onClick={() => act('swipe_owner')}>
          {owner ? owner : 'Swipe ID to own'}
        </Button>
        <Button icon="dollar-sign" onClick={() => act('set_amount')}>
          {amount ? amount + '⪽' : 'Enter amount'}
        </Button>
        <Button icon="id-card" onClick={() => act('swipe_payee')}>
          {'Pay'}
        </Button>
      </Window.Content>
    </Window>
  );
};
