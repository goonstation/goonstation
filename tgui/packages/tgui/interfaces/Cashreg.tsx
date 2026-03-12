/**
 * @file
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

import { classes } from 'common/react';
import { Button, Stack, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export interface CashregData {
  active_transaction: boolean;
  amount: number;
  is_authorised: boolean;
  is_owner: boolean;
  name: string;
  owner: string;
  tip_amount: number;
  tip_proportion: number;
  total: number;
}

export const Cashreg = () => {
  const { act, data } = useBackend<CashregData>();
  const {
    active_transaction,
    amount,
    is_authorised,
    is_owner,
    name,
    owner,
    tip_proportion,
  } = data;

  const ownerButtonClick = owner
    ? is_authorised || is_owner
      ? () => act('reset')
      : undefined
    : () => act('swipe_owner');

  return (
    <Window title={name} theme="ntos" height={240} width={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Button
              className="cashreg__ownerbutton"
              color="blue"
              disabled={active_transaction}
              onClick={ownerButtonClick}
              tooltip={
                owner &&
                (is_authorised || is_owner) &&
                `Click to remove ownership`
              }
              width="100%"
            >
              {owner ? `Owner: ${owner}` : `Swipe ID to own`}
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            {is_owner ? (
              <Tooltip
                content={
                  amount ? `Click to clear transaction` : `Click to set price`
                }
              >
                <CenterPart />
              </Tooltip>
            ) : (
              <CenterPart />
            )}
          </Stack.Item>
          {owner && (
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  <Button
                    align="center"
                    className="cashreg__tip"
                    color="blue"
                    disabled={!amount || active_transaction}
                    onClick={() => act('set_tip')}
                    width="100%"
                  >
                    {`Tip: ${(tip_proportion * 100).toFixed()}%`}
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    align="center"
                    className="cashreg__pay"
                    color="blue"
                    disabled={!amount || active_transaction}
                    onClick={() => act('swipe_payer')}
                    width="100%"
                  >
                    {`Swipe ID to pay`}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CenterPart = () => {
  const { act, data } = useBackend<CashregData>();
  const { amount, is_owner, owner, tip_amount, tip_proportion, total } = data;

  return (
    <Stack
      fill
      vertical
      align="center"
      justify="space-around"
      className={classes([
        'cashreg__centerpart',
        owner && is_owner && 'cashreg__amount',
      ])}
      onClick={
        owner && is_owner
          ? amount
            ? () => act('clear_transaction')
            : () => act('set_amount')
          : undefined
      }
    >
      {owner ? (
        amount ? (
          <table className="cashreg__table">
            <tbody>
              <tr>
                <td>{`Amount`}</td>
                <td className="cashreg__table_cellright">{`${amount}⪽`}</td>
              </tr>
              {!!tip_proportion && (
                <>
                  <tr>
                    <td>{`Tip (%)`}</td>
                    <td className="cashreg__table_cellright">{`${(tip_proportion * 100).toFixed()}%`}</td>
                  </tr>
                  <tr>
                    <td>{`Tip (⪽)`}</td>
                    <td className="cashreg__table_cellright">{`${tip_amount}⪽`}</td>
                  </tr>
                </>
              )}
              <tr>
                <td>{`Total`}</td>
                <td className="cashreg__table_cellright">{`${total}⪽`}</td>
              </tr>
            </tbody>
          </table>
        ) : (
          <Stack.Item align="center">
            {is_owner ? `Enter amount` : `Owner must enter amount`}
          </Stack.Item>
        )
      ) : (
        <Stack.Item align="center">{`Please register owner`}</Stack.Item>
      )}
    </Stack>
  );
};
