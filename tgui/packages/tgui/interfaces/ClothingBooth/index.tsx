import { useBackend, useLocalState } from '../../backend';
import { Box, Button, ByondUi, Divider, Dropdown, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { ClothingBoothData, ClothingBoothListData } from './type';

import { capitalize } from '.././common/stringUtils';

export const ClothingBooth = (props, context) => {
  const { data } = useBackend<ClothingBoothData>(context);

  // on god, this probably isn't the best way of finding the first element in an array. weh.
  const [selectedCategory, selectCategory] = useLocalState(context, "selectedCategory", data.categoryList.find(() => true));

  return (
    <Window title={data.name} width={300} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {/* Topmost section, containing the cash balance and category dropdown. */}
          <Stack.Item>
            <Section fill>
              <Stack align="center" fill>
                <Stack.Item bold>
                  {`Cash: ${data.money}⪽`}
                </Stack.Item>
                <Stack.Item grow={1} />
                <Stack.Item>
                  <Dropdown
                    className="clothingbooth__dropdown"
                    options={data.categoryList}
                    selected={selectedCategory}
                    onSelected={(value) => selectCategory(value)} />
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
                    .filter((booth_item) => (booth_item.category === selectedCategory))
                    .map((booth_item) => {
                      return <ClothingBoothItem key={booth_item.name} booth_item={booth_item} />;
                    })}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {/* Character rendering and purchase button. */}
          <Stack.Item>
            <Section fill>
              <Stack>
                <Stack.Item align="center">
                  <CharacterPreview />
                </Stack.Item>
                <Stack.Item grow={1}>
                  <Stack vertical>
                    <Stack.Item>
                      {`Selected: `}
                    </Stack.Item>
                    <Stack.Item>
                      {`Price: `}
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        color="green" />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type boothItemProps = {
  booth_item: ClothingBoothListData;
};

const ClothingBoothItem = ({ booth_item }: boothItemProps, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);

  return (
    <>
      <Stack
        align="center"
        className="clothingbooth__boothitem"
        onClick={() => act('select', { path: booth_item.path })}>
        <Stack.Item>
          <img
            src={`data:image/png;base64,${booth_item.img}`}
          />
        </Stack.Item>
        <Stack.Item grow={1}>
          <Box bold>{capitalize(booth_item.name)}</Box>
        </Stack.Item>
        <Stack.Item bold>
          {`${booth_item.cost}⪽`}
        </Stack.Item>
      </Stack>
      <Divider />
    </>
  );
};

const CharacterPreview = (_, context) => {
  const { act, data } = useBackend<ClothingBoothData>(context);

  return (
    <Stack vertical align="center">
      <Stack.Item>
        <ByondUi
          params={{
            id: data.preview,
            type: "map",
          }}
          style={{
            width: "64px",
            height: "128px",
          }} />
      </Stack.Item>
      <Stack.Item>
        <Button icon="chevron-left" onClick={() => act('rotate-counter-clockwise')} />
        <Button icon="circle" onClick={() => act('rotate-reset')} />
        <Button icon="chevron-right" onClick={() => act('rotate-clockwise')} />
      </Stack.Item>
    </Stack>
  );
};
