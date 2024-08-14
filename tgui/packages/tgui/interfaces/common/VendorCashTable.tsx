/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { Button, Table } from 'tgui-core/components';

interface VendorCashTableProps {
  cardname: string;
  onCardClick: (e: React.MouseEvent<HTMLDivElement>) => void;
  bankMoney: number;
  cash: number;
  onCashClick: (e: React.MouseEvent<HTMLDivElement>) => void;
}

export const VendorCashTable = (props: VendorCashTableProps) => {
  const { cardname, onCardClick, bankMoney, cash, onCashClick } = props;

  return (
    <Table style={{ fontSize: '9pt', maxWidth: '100%', tableLayout: 'fixed' }}>
      <Table.Row>
        <Table.Cell bold>
          {cardname && (
            <Button
              icon="id-card"
              mr="100%"
              tooltip={cardname ? cardname : ''}
              onClick={onCardClick}
              ellipsis
              maxWidth="100%"
            >
              {cardname}
            </Button>
          )}
          {cardname && bankMoney >= 0 && 'Money on account: ' + bankMoney + '⪽'}
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell bold>
          {cash > 0 && (
            <>
              {'Cash: ' + cash + '⪽ '}
              <Button icon="eject" onClick={onCashClick}>
                Eject
              </Button>
            </>
          )}
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};
