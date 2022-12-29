/**
 * @file
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from '../layouts';

export interface CashregData {
  amount: number;
  name: string;
  owner: string;
}

export const Cashreg = (_, context) => {
  const { act, data } = useBackend<CashregData>(context);
  const { amount, name, owner } = data;

  return (
    <Window title={name} theme="ntos" height={200} width={300}>
      <Window.Content>
        <Box className="cashreg__wrapper">
          {owner ? (
            <Button
              className="cashreg__ownerbutton"
              color="blue"
              onClick={() => act('reset')}
              tooltip="Click to remove ownership">
              {'Owner: ' + owner}
            </Button>
          ) : (
            <Button className="cashreg__ownerbutton" color="blue" onClick={() => act('swipe_owner')}>
              Swipe ID to own
            </Button>
          )}
          <Box className="cashreg__amount" onClick={() => act('set_amount')}>
            {owner ? (amount ? 'Total: ' + amount + '⪽' : 'Click to enter amount') : 'Please register owner'}
          </Box>
          <Button className="cashreg__pay" color="blue" disabled={!amount} onClick={() => act('swipe_payer')}>
            Swipe ID to pay
          </Button>
        </Box>
      </Window.Content>
    </Window>
  );
};
