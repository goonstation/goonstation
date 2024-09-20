/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Button, LabeledList, Section, Stack } from '../../../components';
import { BankAccount } from '../type';
import { formatMoney } from '../../../format';

export type CardInfoProps = {
  actionCardLogin: () => void;
  actionCardLogout: () => void;
  banking_info: BankAccount
}

export const CardInfo = (props:CardInfoProps) => {
  const {
    actionCardLogin,
    actionCardLogout,
    banking_info,
  } = props;
  return (banking_info === null) ? (
    <Section
      textAlign="center"
    >
      <Stack vertical>
        <Stack.Item>
          No Account Found.
        </Stack.Item>
        <Stack.Item>
          <Button icon="add" onClick={() => actionCardLogin()}>Add Account</Button>
        </Stack.Item>
      </Stack>
    </Section>
  ) : (
    <Section
      title="Account Info"
      buttons={<Button icon="minus" onClick={() => actionCardLogout()}>Log Out</Button>}
    >
      <LabeledList>
        <LabeledList.Item
          label="Owner"
        >
          {banking_info?.name}
        </LabeledList.Item>
        <LabeledList.Item
          label="Balance"
        >
          {formatMoney(banking_info?.current_money)}⪽
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
