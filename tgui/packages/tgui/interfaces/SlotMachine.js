/**
 * Copyright (c) 2020 @ZeWaka
 * SPDX-License-Identifier: ISC
 */

import { useBackend } from '../backend';
import { BlockQuote, Button, Icon, NoticeBox, NumberInput, Stack } from '../components';
import { Window } from '../layouts';

export const SlotMachine = (_props, context) => {
  const { data } = useBackend(context);
  const { busy, scannedCard } = data;
  return (
    <Window
      title="Slot Machine"
      width={375}
      height={220}
    >
      <Window.Content>
        {
          !scannedCard
            ? <InsertCard />
            : (busy ? <BusyWindow /> : <SlotWindow />)
        }
      </Window.Content>
    </Window>
  );
};

const InsertCard = (_props, context) => {
  const { act } = useBackend(context);
  return (
    <>
      <NoticeBox danger>
        You must insert your ID to continue!
      </NoticeBox>
      <Button
        icon="id-card"
        onClick={() => act('insert_card')}
      >
        Insert ID
      </Button>
    </>
  );
};

const SlotWindow = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    account_funds,
    money,
    plays,
    scannedCard,
    wager,
  } = data;

  return (
    <>
      <NoticeBox success>
        <marquee> Wager some credits! </marquee>
      </NoticeBox>
      <Stack vertical>
        <Stack.Item>
          <strong>Your card: </strong>
          <Button
            icon="eject"
            content={scannedCard}
            tooltip="Pull Funds and Eject Card"
            tooltipPosition="bottom-end"
            onClick={() => act('eject')}
          />
        </Stack.Item>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item>
              <strong>Account Balance:</strong>
            </Stack.Item>
            <Stack.Item>
              <Icon name="dollar-sign" />
              {' '}
              {account_funds}
            </Stack.Item>
            <Stack.Item>
              <Button
                tooltip="Add Funds"
                tooltipPosition="bottom"
                onClick={() => act('cashin')}
              >
                Cash In
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                tooltip="Pull Funds"
                tooltipPosition="bottom"
                onClick={() => act('cashout')}
              >
                Cash Out
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item>Amount Wagered:</Stack.Item>
            <Stack.Item>
              <NumberInput
                minValue={20}
                maxValue={1000}
                value={wager}
                format={value => value + "⪽"}
                onDrag={(_e, value) => act('set_wager', { bet: value })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack align="center">
            <Stack.Item>
              <strong>Credits Remaining:</strong>
            </Stack.Item>
            <Stack.Item>
              <Icon name="dollar-sign" />
              {' '}
              {money}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote>
            {plays} attempts have been made today!
          </BlockQuote>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Button
            icon="dice"
            tooltip="Pull the lever"
            tooltipPosition="right"
            onClick={() => act('play', { bet: wager })}
          >
            Play!
          </Button>
        </Stack.Item>
      </Stack>
    </>
  );
};

const BusyWindow = () => {
  return (
    <NoticeBox warning>
      The Machine is busy, please wait!
    </NoticeBox>
  );
};

