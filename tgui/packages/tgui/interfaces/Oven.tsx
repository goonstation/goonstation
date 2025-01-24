/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import {
  Button,
  Icon,
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
  content_icons: Array<Object>;
  content_names: Array<string>;
  recipe_icons: Array<Object>;
  recipe_names: Array<string>;
  output_icon: Object;
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
    <Window title="Cookomatic Multi-Oven" width={380} height={630}>
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
          <Stack vertical align="center" fontSize={1.25}>
            <Stack.Item fontSize={1.5}>
              <Button
                color={time === 1 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 1 })}
              >
                1
              </Button>
              <Button
                color={time === 2 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 2 })}
              >
                2
              </Button>
              <Button
                color={time === 3 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 3 })}
              >
                3
              </Button>
              <Button
                color={time === 4 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 4 })}
              >
                4
              </Button>
              <Button
                color={time === 5 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 5 })}
              >
                5
              </Button>
            </Stack.Item>
            <Stack.Item mt={0.5} fontSize={1.5}>
              <Button
                color={time === 6 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 6 })}
              >
                6
              </Button>
              <Button
                color={time === 7 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 7 })}
              >
                7
              </Button>
              <Button
                color={time === 8 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 8 })}
              >
                8
              </Button>
              <Button
                color={time === 9 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 9 })}
              >
                9
              </Button>
              <Button
                color={time === 10 ? 'orange' : 'grey'}
                onClick={() => act('set_time', { time: 10 })}
              >
                10
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color={heat === 'High' ? 'orange' : 'grey'}
                onClick={() => act('set_heat', { heat: 'High' })}
              >
                High
              </Button>
              <Button
                color={heat === 'Low' ? 'orange' : 'grey'}
                onClick={() => act('set_heat', { heat: 'Low' })}
              >
                Low
              </Button>
            </Stack.Item>
            <Stack.Item mt={0.5}>
              <Button selected onClick={() => act('start')}>
                Start!
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="Contents"
          scrollable
          buttons={
            <Button onClick={() => act('eject_all')}>
              <Icon name="eject" />
            </Button>
          }
        >
          {content_icons && content_icons.length ? (
            <Stack vertical>
              {content_icons.map((item, index) => (
                <Stack.Item key={index}>
                  <img
                    height={48}
                    width={48}
                    src={`data:image/png;base64,${item}`}
                  />
                  {`     ${content_names[index]}`}
                  <Button
                    onClick={() => act('eject', { ejected_item: index + 1 })}
                    ml={3}
                  >
                    <Icon name="eject" />
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          ) : (
            '(Empty)'
          )}
        </Section>
        {output_icon && (
          <Section title="Potential Recipe">
            <Stack>
              {recipe_icons.map((item, index) => (
                <Stack.Item key={index}>
                  <img
                    height={48}
                    width={48}
                    src={`data:image/png;base64,${item}`}
                  />
                  {recipe_names[index]}
                </Stack.Item>
              ))}
            </Stack>
            <Section title="Result">
              <Stack vertical>
                <Stack.Item>
                  <img
                    height={48}
                    width={48}
                    src={`data:image/png;base64,${output_icon}`}
                  />
                  {output_name}
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Cook time">
                      {cook_time}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Section>
        )}
        {!!cooking && (
          <Modal fontSize={2} textAlign="center">
            <Section>Cooking! Please wait...</Section>
          </Modal>
        )}
      </Window.Content>
    </Window>
  );
};
