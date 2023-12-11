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
import { ClothingBoothData } from './type';

export const ClothingBooth = (_, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const [hideUnaffordable, toggleHideUnaffordable] = useLocalState(context, 'hideUnaffordable', false);

  return (
    <Window title={data.name} width={450} height={550}>
      <Window.Content>
        <Stack fill vertical>
          {/* Topmost section, containing the cash balance. */}
          <Stack.Item>
            <Section fill>
              <Stack fluid align="center" justify="space-between">
                <Stack.Item bold>Cash: {data.money}⪽</Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={!!hideUnaffordable}
                    onClick={() => toggleHideUnaffordable(!hideUnaffordable)}>
                    Hide Unaffordable
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          {/* Clothing booth item list */}
          <Stack.Item grow={1}>
            <StockList />
          </Stack.Item>
          {/* Character rendering and purchase button. */}
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
