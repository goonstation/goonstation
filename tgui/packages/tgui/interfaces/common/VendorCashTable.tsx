/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { Button, LabeledList } from 'tgui-core/components';

import { asCreditsString } from './stringUtils';

interface VendorCashTableProps {
  cardname: string;
  onCardClick: (e: React.MouseEvent<HTMLDivElement>) => void;
  bankMoney: number;
  cash: number;
  onCashClick: (e: React.MouseEvent<HTMLDivElement>) => void;
}

export const VendorCashTable = (props: VendorCashTableProps) => {
  const { cardname, onCardClick, bankMoney, cash, onCashClick } = props;
  const hasAccount = !!cardname;
  const hasCash = cash > 0;
  return (
    <LabeledList>
      <LabeledList.Item
        label="Account"
        buttons={
          hasAccount ? (
            <Button icon="id-card" onClick={onCardClick}>
              {cardname}
            </Button>
          ) : (
            <Button icon="id-card" disabled>
              Swipe ID Card
            </Button>
          )
        }
      >
        {hasAccount ? asCreditsString(bankMoney) : 'No card inserted'}
      </LabeledList.Item>
      <LabeledList.Item
        label="Cash"
        buttons={
          <Button icon="eject" disabled={!hasCash} onClick={onCashClick}>
            Eject
          </Button>
        }
      >
        {hasCash ? asCreditsString(cash) : 'No cash inserted'}
      </LabeledList.Item>
    </LabeledList>
  );
};
