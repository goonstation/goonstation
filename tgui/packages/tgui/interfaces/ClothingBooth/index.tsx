import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, ByondUi, Divider, Dropdown, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { ClothingBoothData, ClothingBoothListData } from './type';

import { capitalize } from '.././common/stringUtils';

export const ClothingBooth = (_, context) => {
  const { data } = useBackend<ClothingBoothData>(context);

  // on god, this probably isn't the best way of finding the first element in an array. weh.
  const [selectedCategory, selectCategory] = useLocalState(
    context,
    'selectedCategory',
    data.categoryList.find(() => true)
  );

  return (
    <Window title={data.name} width={300} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {/* Topmost section, containing the cash balance and category dropdown. */}
          <Stack.Item>
            <Section fill>
              <Stack fill align="center" justify="space-between">
                <Stack.Item bold>{`Cash: ${data.money}⪽`}</Stack.Item>
                <Stack.Item>
                  <Dropdown
                    className="clothingbooth__dropdown"
                    options={data.categoryList}
                    selected={selectedCategory}
                    onSelected={(value) => selectCategory(value)}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          {/* Clothing booth item list */}
          <Stack.Item grow={1}>
            <Stack fill vertical>
              <Stack.Item grow={1}>
                <Section fill scrollable>
                  {data.clothingBoothList
                    .filter((boothItem) => boothItem.category === selectedCategory)
                    .map((boothItem) => {
                      return <ClothingBoothItem key={boothItem.name} boothItem={boothItem} />;
                    })}
                </Section>
              </Stack.Item>
            </Stack>
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
                <Section fill title="Purchase Info">
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

type boothItemProps = {
  boothItem: ClothingBoothListData;
};

const ClothingBoothItem = ({ boothItem }: boothItemProps, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  return (
    <>
      <Stack
        align="center"
        className={classes([
          'clothingbooth__boothitem',
          boothItem.name === data.selectedItemName && 'clothingbooth__boothitem-selected',
        ])}
        onClick={() => act('select', { path: boothItem.path })}>
        <Stack.Item>
          <img src={`data:image/png;base64,${boothItem.img}`} />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box bold>{capitalize(boothItem.name)}</Box>
        </Stack.Item>
        <Stack.Item bold>{`${boothItem.cost}⪽`}</Stack.Item>
      </Stack>
      <Divider />
    </>
  );
};

const CharacterPreview = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  return (
    <Stack vertical align="center">
      <Stack.Item textAlign>
        <ByondUi
          params={{
            id: data.preview,
            type: 'map',
          }}
          className="clothingbooth__preview"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="chevron-left"
          tooltip="Clockwise"
          tooltipPosition="right"
          onClick={() => act('rotate-cw')}
        />
        <Button
          icon="chevron-right"
          tooltip="Counter-clockwise"
          tooltipPosition="right"
          onClick={() => act('rotate-ccw')}
        />
      </Stack.Item>
    </Stack>
  );
};

const PurchaseInfo = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  return (
    <Stack bold vertical textAlign="center">
      {data.selectedItemName ? (
        <>
          <Stack.Item>{`Selected: ${data.selectedItemName}`}</Stack.Item>
          <Stack.Item>{`Price: ${data.selectedItemCost}⪽`}</Stack.Item>
          <Stack.Item>
            <Button
              color="green"
              disabled={data.selectedItemCost > data.money}
              icon="dollar-sign"
              onClick={() => act('purchase')}>
              {!(data.selectedItemCost > data.money) ? `Purchase` : `Insufficient Cash`}
            </Button>
          </Stack.Item>
        </>
      ) : (
        <Stack.Item>{`Please select an item.`}</Stack.Item>
      )}
    </Stack>
  );
};
