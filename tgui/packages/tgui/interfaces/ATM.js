import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Icon , Input, LabeledList, NoticeBox, Section} from '../components';
import { Window } from '../layouts';

export const ATM = (props, context) => {
  const { data } = useBackend(context);
  const { scannedCard, loggedIn } = data;
  let body
  if (loggedIn == "STATE_LOGGEDIN") {
    body = <LoggedIn />;
  } else {
    body = <InputPIN />;
  }
  return (
    <Window
      title="Automatic Teller Machine"
      width={375}
      height={525}>
      <Window.Content>
        <Section title="Automatic Teller Machine">
          <Box>
            <Icon name="info-circle"/> Thank you for using Nanotrasen financial services.
          </Box>
          <Divider/>
          <Box>
            { !scannedCard ? (
              <InsertCard />
              ) : (
              <Section>
                <InsertedCard/>
                <Box>
                  {body}
                </Box>
              </Section>
            )}
          </Box>
        </Section>
        { loggedIn &&(
          <Lottery />
        )}
        <SpacebuxMenu />
      </Window.Content>
    </Window>
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
  const { act, data } = useBackend(context);
  const { scannedCard } = data;
  return (
    <Box>
      <Button
        icon="eject"
        content={scannedCard}
        onClick={() => act('eject')} />
    </Box>
  );
};

const InputPIN = (props, context) => {
  const { act } = useBackend(context);
  const [enteredPIN, setEnteredPIN] = useLocalState(context, "enteredPIN", null);
  return (
    <Box>
      <Divider/>
      <LabeledList>
        <LabeledList.Item label="Enter your PIN">
          <Input
            placeholder="4 Digit Number"
            onInput={(e, value) => setEnteredPIN(value)}/>
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
        Welcome, <strong>USR</strong>. Your account balance is <strong>$0</strong>.
      </Box>
      <Box>
        Withdrawal amount: <Input placeholder="Amount"/>
        <Button
          icon="dollar-sign"
          content={'Withdraw cash'}
          onClick={() => act('withdrawal_attempt')} />
      </Box>
    </Section>
  );
};

const Lottery = (props, context) => {
  return (
    <Section title="Lottery">
      <Box>
        <Icon name="info-circle"/> To claim your winnings, you'll need to insert your lottery ticket.
      </Box>
      <Divider/>
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
    <Section title="Spacebux Menu">
      <Box>
        <NoticeBox info>
          This menu is only here for you. Other players cannot access your Spacebux!
        </NoticeBox>
        <Icon name ="exclamation-circle"/> Deposit Spacebux at any time by inserting a token. It will always go to <strong>your</strong> account!
      </Box>
      <Divider/>
      <Box>
        Current balance: <strong>0</strong> Spacebux
      </Box>
      <Divider/>
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
  );
};
