/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import {
  Box,
  Button,
  Divider,
  Icon,
  Image,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ProductList } from './common/ProductList';

interface OvenData {
  time: number;
  heat: string;
  cooking: BooleanLike;
  content_icons: string[];
  content_names: string[];
  recipe_icons: string[];
  recipe_names: string[];
  output_icon: string;
  output_name: string;
  cook_time: string;
}

export const Oven = () => {
  const { act, data } = useBackend<OvenData>();
  const {
    time,
    heat,
    cooking,
    content_icons,
    content_names,
    recipe_icons,
    recipe_names,
    output_icon,
    output_name,
    cook_time,
  } = data;

  return (
    <Window title="Cookomatic Multi-Oven" width={420} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Settings"
              buttons={
                <Button
                  onClick={() => act('open_recipe_book')}
                  tooltip={'Warning: Slow'}
                >
                  Open Recipe Book
                </Button>
              }
            >
              <Stack justify="center">
                <Stack.Item>
                  <OvenDialbuttons min={1} max={5} time={time} />
                  <OvenDialbuttons min={6} max={10} time={time} />
                </Stack.Item>
                <Stack.Item>
                  <Stack.Item>
                    <Button
                      selected={heat === 'High'}
                      onClick={() => act('set_heat', { heat: 'High' })}
                      minWidth="75px"
                      textAlign="center"
                    >
                      High
                    </Button>
                  </Stack.Item>
                  <Stack.Item mt={0.5}>
                    <Button
                      selected={heat === 'Low'}
                      onClick={() => act('set_heat', { heat: 'Low' })}
                      minWidth="75px"
                      textAlign="center"
                    >
                      Low
                    </Button>
                  </Stack.Item>
                </Stack.Item>
              </Stack>
              <Stack justify="center">
                <Stack.Item>
                  <Button onClick={() => act('start')} fontSize={2} mt={0.5}>
                    Cook
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow minHeight="160px">
            <Section
              title="Contents"
              fill
              fitted={!!content_icons?.length}
              scrollable={!!(content_icons && content_icons.length)}
              buttons={
                <Button onClick={() => act('eject_all')}>
                  <Icon name="eject" />
                </Button>
              }
            >
              {content_icons?.length ? (
                <ProductList showOutput={false}>
                  {content_icons.map((item, index) => (
                    <ProductList.Item
                      image={item}
                      key={index}
                      extraCellsSlot={
                        <ProductList.Cell collapsing px={1}>
                          <Button
                            icon="eject"
                            onClick={() =>
                              act('eject', { ejected_item: index + 1 })
                            }
                            tooltip="Eject"
                          />
                        </ProductList.Cell>
                      }
                    >
                      {content_names[index]}
                    </ProductList.Item>
                  ))}
                </ProductList>
              ) : (
                '(Empty)'
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <Section title="Potential Recipe" fitted={!!output_icon}>
                    {output_icon ? (
                      <Stack vertical>
                        <Stack.Item>
                          <ProductList showOutput={false}>
                            {recipe_icons.map((item, index) => (
                              <ProductList.Item key={index} image={item}>
                                {recipe_names[index]}
                              </ProductList.Item>
                            ))}
                          </ProductList>
                        </Stack.Item>
                        <Stack.Item m={1}>Cook Time: {cook_time}</Stack.Item>
                      </Stack>
                    ) : (
                      'N/A'
                    )}
                  </Section>
                </Stack.Item>
                <Stack.Item>
                  <Divider vertical />
                </Stack.Item>
                <Stack.Item grow>
                  <Section title="Result">
                    {output_icon ? (
                      <Stack vertical align="center" textAlign="center">
                        <Stack.Item>
                          <Image
                            height="64px"
                            width="64px"
                            src={`data:image/png;base64,${output_icon}`}
                          />
                        </Stack.Item>
                        <Stack.Item>{output_name}</Stack.Item>
                      </Stack>
                    ) : (
                      'N/A'
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
        {!!cooking && (
          <Modal fontSize={2} textAlign="center">
            <Section>Cooking! Please wait...</Section>
          </Modal>
        )}
      </Window.Content>
    </Window>
  );
};

const OvenDialbuttons = (props) => {
  const { act } = useBackend();
  const { min, max, time } = props;
  const nodes: JSX.Element[] = [];
  for (let i = min; i <= max; i++) {
    const node = (
      <Button
        key={i}
        selected={time === i}
        onClick={() => act('set_time', { time: i })}
        width="40px"
        textAlign="center"
      >
        {i}
      </Button>
    );
    nodes.push(node);
  }
  return <Box>{nodes}</Box>;
};
