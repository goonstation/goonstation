import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Divider, Input, LabeledList, NoticeBox, Section, Tabs } from '../../components';
import { Window } from '../../layouts';
import { AtmData, AtmTabKeys } from './types';

export const Atm = (props, context) => {
  const { data } = useBackend<AtmData>(context);
  const { loggedIn } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', AtmTabKeys.Teller);

  return (
    <Window
      title="Automatic Teller Machine"
      width={375}
      height={525}>
      <Window.Content>
        <Tabs fluid textAlign={'center'}>
          <Tabs.Tab
            icon="money-bills"
            selected={tabIndex === AtmTabKeys.Teller}
            onClick={() => setTabIndex(AtmTabKeys.Teller)}>
            ATM
          </Tabs.Tab>
          <Tabs.Tab
            icon="coins"
            selected={tabIndex === AtmTabKeys.Spacebux}
            onClick={() => setTabIndex(AtmTabKeys.Spacebux)}>
            Spacebux
          </Tabs.Tab>
        </Tabs>
        { tabIndex === AtmTabKeys.Teller && <Teller />}
        { tabIndex === AtmTabKeys.Spacebux && <SpacebuxMenu />}
      </Window.Content>
    </Window>
  );
};

const Teller = (props, context) => {
  const { data } = useBackend<AtmData>(context);
  const { loggedIn, scannedCard } = data;

  return (
    <Box>
      <Section title="Automatic Teller Machine">
        <NoticeBox info>
          Please insert card and enter PIN to access your account.
        </NoticeBox>
        <Box>
          { !scannedCard ? (
            <InsertCard />
          ) : (
            <InsertedCard />
          )}
        </Box>
      </Section>
      { loggedIn === 2 && <Lottery /> }
    </Box>
  );
};

const InsertCard = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Box>
      <Button
        icon="id-card"
        content={'Insert ID'}
        onClick={() => act('insert_card')} />
    </Box>
  );
};

const InsertedCard = (props, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const { loggedIn, scannedCard } = data;
  return (
    <Box>
      <Button
        icon="eject"
        content={scannedCard}
        onClick={() => act('eject')} />
      <Divider />
      <Box>
        { loggedIn === 2 ? <LoggedIn /> : <InputPIN /> }
      </Box>
    </Box>
  );
};

const InputPIN = (props, context) => {
  const { act } = useBackend(context);
  const [enteredPIN, setEnteredPIN] = useLocalState(context, "enteredPIN", null);
  return (
    <Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Enter your PIN">
          <Input
            placeholder="4 Digit Number"
            onInput={(e, value) => setEnteredPIN(value)} />
          <Button
            icon="sign-out-alt"
            content={'Login'}
            onClick={() => act('login_attempt', { entered_PIN: enteredPIN })} />
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

const LoggedIn = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section>
      <Box>
        Welcome, <strong>USR</strong>.
      </Box>
      <LabeledList>
        <LabeledList.Item label="Account Balance">
          <strong>$0</strong>
        </LabeledList.Item>
        <LabeledList.Item label="Withdrawal amount:">
          <Input placeholder="Amount" />
        </LabeledList.Item>
      </LabeledList>
      <Box>
        <Button
          icon="dollar-sign"
          content={'Withdraw cash'}
          onClick={() => act('withdrawal_attempt')} />
      </Box>
    </Section>
  );
};

const Lottery = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Section title="Lottery">
      <NoticeBox info>
        To claim your winnings, you must insert your lottery ticket.
      </NoticeBox>
      <Divider />
      <Box>
        <Button
          icon="ticket-alt"
          content={'Purchase Lottery Ticket (100 credits)'}
          onClick={() => act('purchase_lottery')} />
      </Box>
    </Section>
  );
};

const SpacebuxMenu = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Box>
      <NoticeBox info>
        This menu is only here for you. Other players cannot access your Spacebux!
      </NoticeBox>
      <Section title="Spacebux Menu">
        <NoticeBox info>
          Deposit Spacebux at any time by inserting a token. It will always go to <strong>your</strong> account!
        </NoticeBox>
        <Divider />
        <Box>
          Current balance: <strong>0</strong> Spacebux
        </Box>
        <Divider />
        <Box>
          <Button
            icon="coins"
            content={'Withdraw Spacebux'}
            onClick={() => act('withdraw_spacebux')} />
        </Box>
        <Box>
          <Button
            icon="envelope"
            content={'Securely send Spacebux'}
            onClick={() => act('send_spacebux')} />
        </Box>
      </Section>
    </Box>
  );
};
