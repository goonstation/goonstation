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
  price: number;
}

export const Cashreg = (_, context) => {
  const { act, data } = useBackend<CashregData>(context);
  const { owner, price } = data;

  return (
    <Window>
      <Window.Content>
        <Button icon="id-card" onClick={() => act('')}>
          {owner ? owner : 'Swipe ID to own'}
        </Button>
        <Button icon="dollar-sign" onClick={() => act('')}>
          {price ? price + '⪽' : 'Enter amount'}
        </Button>
        <Button icon="id-card" onClick={() => act('')}>
          {'Pay'}
        </Button>
      </Window.Content>
    </Window>
  );
};
