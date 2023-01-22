/**
 * @file
 * @copyright 2023
 * @author DisturbHerb (https://github.com/DisturbHerb/)
 * @license MIT
 */

import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Divider, Icon, NoticeBox, Section, Stack, Tabs } from '../../components';
import { Window } from '../../layouts';
import { AtmData, AtmTabKeys } from './types';

const LoggedInStates = {
  LoggedOut: 1,
  LoggedIn: 2,
};

const NoticeBoxTypes = {
  Danger: 'danger',
  Info: 'info',
  Success: 'success',
};

const TypedNoticeBox = (props) => {
  const { type, ...rest } = props;
  const typeProps = {
    ...(type === NoticeBoxTypes.Danger ? { danger: true } : {}),
    ...(type === NoticeBoxTypes.Info ? { info: true } : {}),
    ...(type === NoticeBoxTypes.Success ? { success: true } : {}),
  };
  return (
    <Box>
      <Divider />
      <NoticeBox {...typeProps} {...rest} />
    </Box>
  );
};

export const Atm = (_, context) => {
  const { data } = useBackend<AtmData>(context);
  const { name } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', AtmTabKeys.Teller);
  return (
    <Window title={name} width={375} height={420}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="money-bills"
                selected={tabIndex === AtmTabKeys.Teller}
                onClick={() => setTabIndex(AtmTabKeys.Teller)}>
                {`ATM`}
              </Tabs.Tab>
              <Tabs.Tab
                icon="coins"
                selected={tabIndex === AtmTabKeys.Spacebux}
                onClick={() => setTabIndex(AtmTabKeys.Spacebux)}>
                {`Spacebux`}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            {tabIndex === AtmTabKeys.Teller && <Teller />}
            {tabIndex === AtmTabKeys.Spacebux && <SpacebuxMenu />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Teller = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const { accountBalance, accountName, loggedIn, scannedCard } = data;
  const message = data.message || { text: '', status: '', position: '' };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Automatic Teller Machine">
          <Stack vertical fill>
            <Stack.Item>
              {!scannedCard && <NoticeBox info>{`Please swipe card and enter PIN to access your account.`}</NoticeBox>}
              <Button
                icon="id-card"
                content={scannedCard ? scannedCard : `Swipe ID`}
                onClick={scannedCard ? () => act('logout') : () => act('insert_card')}
              />
              {message.text && message.position === 'splash' && (
                <TypedNoticeBox type={message.status}>{message.text}</TypedNoticeBox>
              )}
            </Stack.Item>
            {loggedIn === LoggedInStates.LoggedIn ? (
              <>
                <Divider />
                <Stack.Item>
                  <Stack vertical fill>
                    <Stack.Item>
                      Welcome, <strong>{accountName}.</strong>
                    </Stack.Item>
                    <Stack.Item>
                      Your account balance is <strong>{accountBalance}⪽.</strong>
                    </Stack.Item>
                    <Stack.Item>
                      <Divider />
                      <Button icon="money-bill" content={'Withdraw cash'} onClick={() => act('withdraw_cash')} />
                      {message.text && message.position === 'atm' && (
                        <TypedNoticeBox type={message.status}>{message.text}</TypedNoticeBox>
                      )}
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </>
            ) : (
              scannedCard && (
                <Stack.Item>
                  <Button icon="sign-out-alt" content={'Enter PIN'} onClick={() => act('login_attempt')} />
                  {message.text && message.position === 'login' && (
                    <TypedNoticeBox type={message.status}>{message.text}</TypedNoticeBox>
                  )}
                </Stack.Item>
              )
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {loggedIn === LoggedInStates.LoggedIn && (
          <Section title="Lottery">
            <NoticeBox info>{`To claim your winnings, you must insert your lottery ticket.`}</NoticeBox>
            <Divider />
            <Button icon="ticket-alt" content={'Purchase Lottery Ticket (100⪽)'} onClick={() => act('buy')} />
            {message.text && message.position === 'lottery' && (
              <TypedNoticeBox type={message.status}>{message.text}</TypedNoticeBox>
            )}
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};

const SpacebuxMenu = (_, context) => {
  const { act, data } = useBackend<AtmData>(context);
  const { clientKey, spacebuxBalance } = data;
  return (
    <Section title={clientKey + "'s Spacebux Menu"}>
      <Stack vertical fill>
        <Stack.Item>
          <NoticeBox info>
            {`This menu is only visible to you. Deposit Spacebux into your account by inserting a token.`}
          </NoticeBox>
          <Divider />
        </Stack.Item>
        <Stack.Item>
          Your Spacebux balance is currently{' '}
          <strong>
            {spacebuxBalance} <Icon name="fa-solid fa-coins" />
          </strong>
        </Stack.Item>
        <Stack.Item>
          <Divider />
          <Button icon="coins" content={'Withdraw Spacebux'} onClick={() => act('withdraw_spacebux')} />
        </Stack.Item>
        <Stack.Item>
          <Button icon="envelope" content={'Securely send Spacebux'} onClick={() => act('transfer_spacebux')} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
