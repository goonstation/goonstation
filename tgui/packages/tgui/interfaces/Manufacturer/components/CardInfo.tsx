/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { Button, LabeledList, Section, Stack } from '../../../components';
import { formatMoney } from '../../../format';

export type CardInfoProps = {
  actionCardLogin: () => void;
  actionCardLogout: () => void;
  card_owner: string;
  card_balance: number;
}

export const CardInfo = (props:CardInfoProps) => {
  const {
    actionCardLogin,
    actionCardLogout,
    card_owner,
    card_balance,
  } = props;
  return (card_owner === null || card_balance === null) ? (
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
          {card_owner}
        </LabeledList.Item>
        <LabeledList.Item
          label="Balance"
        >
          {formatMoney(card_balance)}⪽
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
