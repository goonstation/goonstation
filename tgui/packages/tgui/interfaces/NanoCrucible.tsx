/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { Button, Flex, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface PacketInfo {
  first_part;
  first_part_img;
  second_part;
  second_part_img;
  result_part;
}

export const NanoCrucible = () => {
  const { act, data } = useBackend<PacketInfo>();
  const {
    first_part,
    first_part_img,
    second_part,
    second_part_img,
    result_part,
  } = data;
  return (
    <Window title="Nano-Crucible" width={300} height={125}>
      <Window.Content>
        <Section fill>
          <Flex align="center" textAlign="center" justify="space-between">
            <Flex.Item grow>
              <Button
                onClick={() => act('load_first_part')}
                tooltip={first_part}
                color={!first_part ? 'orange' : 'green'}
              >
                {first_part ? (
                  <img
                    height={32}
                    width={32}
                    src={`data:image/png;base64,${first_part_img}`}
                  />
                ) : (
                  'Empty'
                )}
              </Button>
            </Flex.Item>
            <Flex.Item fontSize={1.5}>
              <Icon name="plus" />
            </Flex.Item>
            <Flex.Item grow>
              <Button
                onClick={() => act('load_second_part')}
                tooltip={second_part}
                color={!second_part ? 'orange' : 'green'}
              >
                {second_part ? (
                  <img
                    height={32}
                    width={32}
                    src={`data:image/png;base64,${second_part_img}`}
                  />
                ) : (
                  'Empty'
                )}
              </Button>
            </Flex.Item>
            <Flex.Item fontSize={2}>
              <Icon name="arrow-right-long" />
            </Flex.Item>
            <Flex.Item grow>
              <Button
                onClick={() => act('eject_result')}
                color={result_part === '???' ? 'red' : 'green'}
              >
                {result_part}
              </Button>
            </Flex.Item>
          </Flex>
          <Flex align="center" textAlign="center">
            <Flex.Item grow fontSize={1.3} mt={1}>
              <Button onClick={() => act('switch_parts')}>
                <Icon name="arrows-left-right" />
              </Button>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
