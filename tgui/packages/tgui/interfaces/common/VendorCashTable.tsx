/**
 * @file
 * @copyright 2023
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { MouseEventHandler } from 'react';
import { Button, LabeledList } from 'tgui-core/components';

import { asCreditsString } from './stringUtils';

interface VendorCashTableCashAcceptProps {
  cash: number;
  rejectCash?: boolean | false;
  onCashClick: MouseEventHandler;
}

interface VendorCashTableCashForbidProps {
  rejectCash: true;
}

type VendorCashTableCashProps =
  | VendorCashTableCashAcceptProps
  | VendorCashTableCashForbidProps;

interface VendorCashTableCardAcceptProps {
  bankMoney: number;
  cardname: string;
  rejectCard?: false;
  onCardClick: MouseEventHandler;
}

interface VendorCashTableCardForbidProps {
  rejectCard: true;
}

type VendorCashTableCardProps =
  | VendorCashTableCardAcceptProps
  | VendorCashTableCardForbidProps;

type VendorCashTableProps = VendorCashTableCashProps & VendorCashTableCardProps;

export const VendorCashTable = (props: VendorCashTableProps) => {
  const { rejectCard, rejectCash } = props;
  if (rejectCard && rejectCash) {
    return null;
  }
  const hasAccount = !rejectCard && !!props.cardname;
  const hasCash = !rejectCash && props.cash > 0;
  return (
    <LabeledList>
      {!rejectCard && (
        <LabeledList.Item
          label="Account"
          buttons={
            hasAccount ? (
              <Button icon="id-card" onClick={props.onCardClick}>
                {props.cardname}
              </Button>
            ) : (
              <Button icon="id-card" disabled>
                Swipe ID Card
              </Button>
            )
          }
        >
          {hasAccount ? asCreditsString(props.bankMoney) : 'No card inserted'}
        </LabeledList.Item>
      )}
      {!rejectCash && (
        <LabeledList.Item
          label="Cash"
          buttons={
            <Button
              icon="eject"
              disabled={!hasCash}
              onClick={props.onCashClick}
            >
              Eject
            </Button>
          }
        >
          {hasCash ? asCreditsString(props.cash) : 'No cash inserted'}
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};
