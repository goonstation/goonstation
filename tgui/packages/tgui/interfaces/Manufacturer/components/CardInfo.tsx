/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MyNameIsRomayne)
 * @license ISC (https://choosealicense.com/licenses/isc/)
 */

import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { formatMoney } from '../../../format';
import { BankAccount } from '../type';

export type CardInfoProps = {
  actionCardLogin: () => void;
  actionCardLogout: () => void;
  banking_info: BankAccount;
};

export const CardInfo = (props: CardInfoProps) => {
  const { actionCardLogin, actionCardLogout, banking_info } = props;
  return banking_info === null ? (
    <Section textAlign="center">
      <Stack vertical>
        <Stack.Item>No Account Found.</Stack.Item>
        <Stack.Item>
          <Button icon="add" onClick={() => actionCardLogin()}>
            Add Account
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  ) : (
    <Section
      title="Account Info"
      buttons={
        <Button icon="minus" onClick={() => actionCardLogout()}>
          Log Out
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Owner">{banking_info?.name}</LabeledList.Item>
        <LabeledList.Item label="Balance">
          {formatMoney(banking_info?.current_money)}⪽
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
