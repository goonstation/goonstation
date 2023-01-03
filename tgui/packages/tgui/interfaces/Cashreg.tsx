/**
 * @file
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

import { useBackend } from '../backend';
import { Box, Button, Tooltip } from '../components';
import { Window } from '../layouts';

export interface CashregData {
  active_transaction: boolean;
  amount: number;
  name: string;
  owner: string;
  tip: number;
  total: number;
}

export const Cashreg = (_, context) => {
  const { act, data } = useBackend<CashregData>(context);
  const { active_transaction, amount, name, owner, tip, total } = data;

  return (
    <Window title={name} theme="ntos" height={240} width={300}>
      <Window.Content>
        <Box className="cashreg__wrapper">
          <Button
            className="cashreg__ownerbutton"
            color="blue"
            disabled={active_transaction}
            onClick={owner ? () => act('reset') : () => act('swipe_owner')}
            tooltip={owner ? 'Click to remove ownership' : 'Click to register ownership'}>
            {owner ? 'Owner: ' + owner : 'Swip ID to own'}
          </Button>
          <Tooltip content="Click to edit price">
            <Box className="cashreg__amount" onClick={() => act('set_amount')}>
              {owner ? (
                amount ? (
                  <table className="cashreg__table">
                    <tbody>
                      <tr>
                        <td>Amount</td>
                        <td className="cashreg__table_cellright">{amount + '⪽'}</td>
                      </tr>
                      {!!tip && (
                        <tr>
                          <td>Tip</td>
                          <td className="cashreg__table_cellright">{tip * 100 + '%'}</td>
                        </tr>
                      )}
                      <tr>
                        <td>Total</td>
                        <td className="cashreg__table_cellright">{total + '⪽'}</td>
                      </tr>
                    </tbody>
                  </table>
                ) : (
                  'Click to enter amount'
                )
              ) : (
                'Please register owner'
              )}
            </Box>
          </Tooltip>
          {owner && (
            <Box className="cashreg__bottombutt_holder">
              <Box className="cashreg__bottombutt">
                <Button
                  className="cashreg__tip"
                  color="blue"
                  disabled={!amount || active_transaction}
                  onClick={() => act('set_tip')}
                  tooltip="Click to set tip percentage">
                  Tip: {tip * 100}%
                </Button>
              </Box>
              <Box className="cashreg__bottombutt">
                <Button
                  className="cashreg__pay"
                  color="blue"
                  disabled={!amount || active_transaction}
                  onClick={() => act('swipe_payer')}>
                  Swipe ID to pay
                </Button>
              </Box>
            </Box>
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};
