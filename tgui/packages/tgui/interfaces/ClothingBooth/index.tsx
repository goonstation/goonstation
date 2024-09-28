/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { CharacterPreview } from './CharacterPreview';
import { PurchaseInfo } from './PurchaseInfo';
import { StockList } from './StockList';
import { TagsModal } from './TagsModal';
import type { ClothingBoothData } from './type';

export const ClothingBooth = () => {
  const { act, data } = useBackend<ClothingBoothData>();
  const { name, accountBalance, cash, scannedID } = data;
  const [tagModal] = useState(false);

  return (
    <Window title={name} width={500} height={600}>
      <Window.Content>
        {tagModal && <TagsModal />}
        <Stack fill vertical>
          {!!(!data.everythingIsFree && (scannedID || cash)) && (
            <Stack.Item>
              <Section fill>
                <Stack fill vertical>
                  {!!cash && (
                    <Stack.Item>
                      <Stack align="center" justify="space-between">
                        <Stack.Item bold>Cash: {cash}⪽</Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="eject"
                            onClick={() => act('eject_cash')}
                          >
                            Eject Cash
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  )}
                  {!!scannedID && (
                    <Stack.Item>
                      <Stack align="center" justify="space-between">
                        <Stack.Item bold>
                          Money In Account: {accountBalance}⪽
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            ellipsis
                            icon="id-card"
                            onClick={() => {
                              act('logout');
                            }}
                          >
                            {scannedID}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  )}
                </Stack>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow={1}>
            <StockList />
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item align="center">
                <Section fill>
                  <CharacterPreview />
                </Section>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fill>
                  <Stack fill vertical justify="space-around">
                    <Stack.Item>
                      <PurchaseInfo />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
