/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import {
  Button,
  Divider,
  Icon,
  Image,
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface PacketInfo {
  time: number;
  heat: string;
  cooking: boolean;
  content_icons: string[];
  content_names: string[];
  recipe_icons: string[];
  recipe_names: string[];
  output_icon: string;
  output_name: string;
  cook_time: string;
}

export const Oven = () => {
  const { act, data } = useBackend<PacketInfo>();
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
          <Stack fontSize={1.5} justify="center">
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
        <Section
          title="Contents"
          scrollable={!!(content_icons && content_icons.length)}
          buttons={
            <Button onClick={() => act('eject_all')}>
              <Icon name="eject" />
            </Button>
          }
        >
          {content_icons && content_icons.length ? (
            <Stack vertical minHeight="130px" maxHeight="130px">
              {content_icons.map((item, index) => (
                <Stack key={index} style={{ borderBottom: '0.5px #555 solid' }}>
                  <Stack.Item
                    grow
                    style={{
                      display: 'flex',
                    }}
                  >
                    <Image
                      height="32px"
                      width="32px"
                      src={`data:image/png;base64,${item}`}
                      style={{ transform: 'translate(0, -4px)' }}
                    />
                    {content_names[index]}
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() => act('eject', { ejected_item: index + 1 })}
                      ml={3}
                      style={{ transform: 'translate(0, 4px)' }}
                    >
                      <Icon name="eject" />
                    </Button>
                  </Stack.Item>
                </Stack>
              ))}
            </Stack>
          ) : (
            <Stack minHeight="130px" maxHeight="130px">
              <Stack.Item>(Empty)</Stack.Item>
            </Stack>
          )}
        </Section>
        <Section>
          <Stack align>
            <Stack.Item grow>
              <Section title="Potential Recipe">
                {output_icon ? (
                  <Stack vertical>
                    <Stack.Item>
                      {recipe_icons.map((item, index) => (
                        <Stack.Item
                          key={index}
                          style={{
                            borderBottom: '0.5px #555 solid',
                            display: 'flex',
                          }}
                        >
                          <Image
                            height="32px"
                            width="32px"
                            src={`data:image/png;base64,${item}`}
                            style={{ transform: 'translate(0, -4px)' }}
                          />
                          {recipe_names[index]}
                        </Stack.Item>
                      ))}
                    </Stack.Item>
                    <Stack.Item>
                      <LabeledList>
                        <LabeledList.Item label="Cook time">
                          {cook_time}
                        </LabeledList.Item>
                      </LabeledList>
                    </Stack.Item>
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
  return <Stack.Item>{nodes}</Stack.Item>;
};
