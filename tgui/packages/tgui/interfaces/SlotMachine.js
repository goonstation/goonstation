/**
 * Copyright (c) 2020 @ZeWaka
 * SPDX-License-Identifier: ISC
 */

import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Divider, BlockQuote, Icon } from '../components';
import { Window } from '../layouts';

export const SlotMachine = (props, context) => {
  const { data } = useBackend(context);
  const { scannedCard, busy } = data;
  return (
    <Window
      title="Slot Machine"
      width={375}
      height={190}>
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
  const { scannedCard, money, plays } = data;

  return (
    <Box>
      <NoticeBox success>
        <marquee> Twenty credits to play! </marquee>
      </NoticeBox>
      <Box mb="0.5em">
        <strong>Your card: </strong>
        <Button
          icon="eject"
          content={scannedCard}
          tooltip="Eject Card"
          tooltipPosition="bottom-right"
          onClick={() => act('eject')} />
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
        onClick={() => act('play')} />
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

