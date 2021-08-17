/**
 * Copyright (c) 2020 @ZeWaka
 * SPDX-License-Identifier: ISC
 */

import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Divider, BlockQuote, Icon, NumberInput } from '../components';
import { Window } from '../layouts';

export const SlotMachine = (props, context) => {
  const { data } = useBackend(context);
  const { scannedCard, busy } = data;
  return (
    <Window
      title="Slot Machine"
      width={375}
      height={215}>
      <Window.Content>
        { !scannedCard ? (
          <InsertCard />
        ) : (
          <Box>
            { busy ? (
              <BusyWindow />
            ) : (
              <SlotWindow />
            )}
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

const InsertCard = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Box>
      <NoticeBox danger>
        You must insert your ID to continue!
      </NoticeBox>
      <Button
        icon="id-card"
        content={'Insert ID'}
        onClick={() => act('insert_card')} />
    </Box>
  );
};

const SlotWindow = (props, context) => {
  const { act, data } = useBackend(context);
  const { scannedCard, money, account_funds, plays, wager } = data;

  return (
    <Box>
      <NoticeBox success>
        <marquee> Wager some credits! </marquee>
      </NoticeBox>
      <Box mb="0.5em">
        <strong>Your card: </strong>
        <Button
          icon="eject"
          content={scannedCard}
          tooltip="Pull Funds and Eject Card"
          tooltipPosition="bottom-right"
          onClick={() => act('eject')} />
      </Box>
      <Box>
        <strong>Account Balance:</strong>
        <Icon name="dollar-sign" /> { account_funds }
        {' '}
        <Button
          content="Cash In"
          tooltip="Add Funds"
          tooltipPosition="right"
          onClick={() => act('cashin')} />
        {' '}
        <Button
          content="Cash Out"
          tooltip="Pull Funds"
          tooltipPosition="right"
          onClick={() => act('cashout')} />
      </Box>
      <Box>
        Amount Wagered:
        <NumberInput
          minValue={20}
          maxValue={1000}
          value={wager}
          format={value => "$" + value}
          onDrag={(e, value) => act('set_wager', {
            bet: value,
          })}
        />
      </Box>
      <Box mb="0.75em">
        <strong>Credits Remaining:</strong>
        <Icon name="dollar-sign" /> { money }
      </Box>
      <BlockQuote>
        { plays } attempts have been made today!
      </BlockQuote>
      <Divider />
      <Button
        icon="dice"
        content="Play!"
        tooltip="Pull the lever"
        tooltipPosition="right"
        onClick={() => act('play', {
          bet: wager,
        })} />
    </Box>
  );
};

const BusyWindow = () => {
  return (
    <NoticeBox warning>
      The Machine is busy, please wait!
    </NoticeBox>
  );
};

