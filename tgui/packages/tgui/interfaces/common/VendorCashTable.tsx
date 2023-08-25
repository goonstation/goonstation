import { Table, Button } from '../../components';
import { InfernoNode } from 'inferno';

interface VendorCashTableProps {
  cardname: string,
  onCardClick: Function,
  bankMoney: number,
  cash: number,
  onCashClick: Function,
}

export const VendorCashTable: InfernoNode = (props: VendorCashTableProps) => {
  const {
    cardname,
    onCardClick,
    bankMoney,
    cash,
    onCashClick,
  } = props;

  return (
    <Table font-size="9pt" direction="row">
      <Table.Row>
        <Table.Cell bold>
          {cardname && (
            <Button icon="id-card"
              mr="100%"
              content={cardname ? cardname : ""}
              onClick={onCardClick}
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
