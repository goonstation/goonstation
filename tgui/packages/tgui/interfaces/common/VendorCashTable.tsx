/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { Button, Table } from '../../components';

interface VendorCashTableProps {
  cardname: string,
  onCardClick: Function,
  bankMoney: number,
  cash: number,
  onCashClick: Function,
}

export const VendorCashTable = (props: VendorCashTableProps) => {
  const {
    cardname,
    onCardClick,
    bankMoney,
    cash,
    onCashClick,
  } = props;

  return (
    <Table font-size="9pt" direction="row" style={{ maxWidth: "100%", "table-layout": "fixed" }} >
      <Table.Row>
        <Table.Cell bold>
          {cardname && (
            <Button icon="id-card"
              mr="100%"
              content={cardname ? cardname : ""}
              title={cardname ? cardname : ""}
              onClick={onCardClick}
              ellipsis
              maxWidth="100%"
            />
          )}
          {(cardname && bankMoney >= 0) && ("Money on account: " + bankMoney + "⪽")}
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell bold direction="row">
          {(cash > 0) && ("Cash: " + cash + "⪽")}
          {(cash > 0 && cash) && (
            <Button icon="eject"
              ml="1%"
              content={"eject"}
              onClick={onCashClick} />
          )}
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};
