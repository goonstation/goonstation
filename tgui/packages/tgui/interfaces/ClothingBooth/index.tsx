/**
 * @file
 * @copyright 2023
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend, useLocalState } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { CharacterPreview } from './CharacterPreview';
import { StockList } from './StockList';
import { PurchaseInfo } from './PurchaseInfo';
import { TagsModal } from './TagsModal';
import type { ClothingBoothData } from './type';
import { LocalStateKey } from './utils/enum';

export const ClothingBooth = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { name, accountBalance, cash, scannedID } = data;
  const [tagModal] = useLocalState(context, LocalStateKey.TagModal, false);

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
                      <Stack fluid align="center" justify="space-between">
                        <Stack.Item bold>Cash: {cash}⪽</Stack.Item>
                        <Stack.Item>
                          <Button icon="eject" content="Eject Cash" onClick={() => act('eject_cash')} />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  )}
                  {!!scannedID && (
                    <Stack.Item>
                      <Stack fluid align="center" justify="space-between">
                        <Stack.Item bold>Money In Account: {accountBalance}⪽</Stack.Item>
                        <Stack.Item>
                          <Button
                            ellipsis
                            icon="id-card"
                            content={scannedID}
                            onClick={() => {
                              act('logout');
                            }}
                          />
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
