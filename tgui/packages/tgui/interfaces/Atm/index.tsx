/**
 * @copyright 2022
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Divider, Icon, NoticeBox, Section, Tabs } from '../../components';
import { Window } from '../../layouts';
import { AtmData, AtmTabKeys } from './types';

export const Atm = (_, context) => {
  const { data } = useBackend<AtmData>(context);
  const { name } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', AtmTabKeys.Teller);
  return (
    <Window title={name} width={375} height={450}>
      <Window.Content>
        <Tabs fluid>
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
        {tabIndex === AtmTabKeys.Teller && <Teller />}
        {tabIndex === AtmTabKeys.Spacebux && <SpacebuxMenu />}
      </Window.Content>
    </Window>
  );
};

const Types = {
  Danger: 'danger',
  Info: 'info',
  Success: 'success',
};

const TypedNoticeBox = (props) => {
  const {
    type,
    ...rest
  } = props;
  const typeProps = {
    ...(type === Types.Danger ? { danger: true } : {}),
    ...(type === Types.Info ? { info: true } : {}),
    ...(type === Types.Success ? { success: true } : {}),
  };
  return <NoticeBox {...typeProps} {...rest} />;
};

const Teller = (_, context) => {
  const { data } = useBackend<AtmData>(context);
  const { loggedIn, scannedCard } = data;

  return (
    <Box>
      <Section title="Automatic Teller Machine">
        {!scannedCard && <NoticeBox info>Please swipe card and enter PIN to access your account.</NoticeBox>}
        <Box>{!scannedCard ? <InsertCard /> : <InsertedCard />}</Box>
      </Section>
      {loggedIn === 2 && <Lottery />}
    </Box>
  );
};

const InsertCard = (_, context) => {
  const { act } = useBackend(context);
  return (
    <Box>
      <Button icon="id-card" content={'Swipe ID'} onClick={() => act('insert_card')} />
    </Box>
  );
};

const InsertedCard = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const { loggedIn, scannedCard } = data;
  return (
    <Box>
      <Button icon="eject" content={scannedCard} onClick={() => act('logout')} />
      <Divider />
      <Box>{loggedIn === 2 ? <LoggedIn /> : <InputPIN />}</Box>
    </Box>
  );
};

const InputPIN = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const message = data.message || { text: '', status: '', position: '' };
  return (
    <Box>
      <Button icon="sign-out-alt" content={'Enter PIN'} onClick={() => act('login_attempt')} />
      {message.text && (message.position === 'login') && (
        <Box>
          <Divider />
          <TypedNoticeBox type={message.status}>
            {message.text}
          </TypedNoticeBox>
        </Box>
      )}
    </Box>
  );
};

const LoggedIn = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const { accountBalance, accountName } = data;
  const message = data.message || { text: '', status: '', position: '' };
  return (
    <Box>
      <Box>
        <p>
          Welcome, <strong>{accountName}.</strong>
        </p>
        <p>
          Your account balance is <strong>{accountBalance}⪽.</strong>
        </p>
      </Box>
      <Divider />
      <Button icon="money-bill" content={'Withdraw cash'} onClick={() => act('withdraw_cash')} />
      {message.text && (message.position === 'atm') && (
        <Box>
          <Divider />
          <TypedNoticeBox type={message.status}>
            {message.text}
          </TypedNoticeBox>
        </Box>
      )}
    </Box>
  );
};

const Lottery = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const message = data.message || { text: '', status: '', position: '' };
  return (
    <Section title="Lottery">
      <NoticeBox info>To claim your winnings, you must insert your lottery ticket.</NoticeBox>
      <Divider />
      <Box>
        <Button icon="ticket-alt" content={'Purchase Lottery Ticket (100⪽)'} onClick={() => act('buy')} />
      </Box>
      {message.text && (message.position === 'lottery') && (
        <Box>
          <Divider />
          <TypedNoticeBox type={message.status}>
            {message.text}
          </TypedNoticeBox>
        </Box>
      )}
    </Section>
  );
};

const SpacebuxMenu = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const { clientKey, spacebuxBalance } = data;
  return (
    <Box>
      <Section title={clientKey + "'s Spacebux Menu"}>
        <NoticeBox info>
          This menu is only visible to you. Deposit Spacebux into your account at any time by inserting a token.
        </NoticeBox>
        <Divider />
        <Box>
          Your Spacebux balance is currently{' '}
          <strong>
            {spacebuxBalance} <Icon name="fa-solid fa-coins" />
          </strong>
        </Box>
        <Divider />
        <Box>
          <Button icon="coins" content={'Withdraw Spacebux'} onClick={() => act('withdraw_spacebux')} />
        </Box>
        <Box>
          <Button icon="envelope" content={'Securely send Spacebux'} onClick={() => act('transfer_spacebux')} />
        </Box>
      </Section>
    </Box>
  );
};
