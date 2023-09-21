import { classes } from 'common/react';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Divider, Dropdown, Section, Stack, Image } from '../../components';
import { Window } from '../../layouts';
import { ClothingBoothData } from './type';

import { capitalize } from '../common/stringUtils';

export const ClothingBooth = (_, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const categories = data.clothingBoothCategories || [];

  const [selectedCategory, selectCategory] = useLocalState(context, 'selectedCategory', categories[0]);
  const { items } = selectedCategory;

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
                    options={categories.map((category) => category.category)}
                    selected={selectedCategory.category}
                    onSelected={(value) => (
                      selectCategory(categories[categories.findIndex((category) => category.category === value)])
                    )}
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
                  {items.map((item) => (
                    <ClothingBoothItem key={item.name} item={item} />
                  ))}
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

const ClothingBoothItem = (props, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);
  const { item } = props;

  return (
    <>
      <Stack
        align="center"
        className={classes([
          'clothingbooth__boothitem',
          item.name === data.selectedItemName && 'clothingbooth__boothitem-selected',
        ])}
        onClick={() => act('select', { path: item.path })}>
        <Stack.Item>
          <img src={`data:image/png;base64,${item.img}`} />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box bold>{capitalize(item.name)}</Box>
        </Stack.Item>
        <Stack.Item bold>{`${item.cost}⪽`}</Stack.Item>
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
        <Image height={data.previewHeight * 2 + "px"} pixelated src={`data:image/png;base64,${data.previewIcon}`} />
      </Stack.Item>
      <Stack.Item>
        <Button icon="chevron-left" tooltip="Clockwise" tooltipPosition="right" onClick={() => act('rotate-cw')} />
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
