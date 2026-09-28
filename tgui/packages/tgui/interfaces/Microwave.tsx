/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { Button, Image, Modal, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface MicrowaveData {
  broken: BooleanLike;
  operating: BooleanLike;
  dirty: BooleanLike;
  maxItems: number;
  items: Item[];
}

interface Item {
  name: string;
  iconData: string;
  index: number;
}

export const Microwave = () => {
  const { act, data } = useBackend<MicrowaveData>();
  const { broken, operating, maxItems, items } = data;

  return (
    <Window title="Microwave Controls" width={290} height={310}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title={`Contents: (${items.length}/${maxItems})`}
            >
              {items.length > 0
                ? items.map((item) => (
                    <MicrowaveItem
                      key={item.index}
                      item={item}
                      operating={operating}
                    />
                  ))
                : 'No contents in microwave'}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack m=".25rem">
              <Stack.Item grow={10}>
                <Button
                  fluid
                  textAlign="center"
                  onClick={() => act('start_microwave')}
                  disabled={operating || broken || items.length === 0}
                >
                  Start!
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  backgroundColor="blue"
                  icon="eject"
                  tooltip="Eject All"
                  textAlign="center"
                  disabled={items.length === 0}
                  onClick={() => act('eject_contents', {})}
                >
                  Eject All
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
      {!!operating && (
        <Modal textAlign="center">
          <Section>Cooking! Please wait...</Section>
        </Modal>
      )}
    </Window>
  );
};

export const MicrowaveItem = (props: {
  item: Item;
  operating: BooleanLike;
}) => {
  const { act } = useBackend();

  const { item, operating } = props;

  return (
    <Stack align="center">
      <Image
        verticalAlign="middle"
        height="30px"
        width="30px"
        src={`data:image/png;base64,${item.iconData}`}
      />
      <div
        style={{
          flex: '1',
          minWidth: 0,
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
        }}
      >
        {item.name}
      </div>
      <Button
        icon="eject"
        color="blue"
        tooltip={`Eject ${item.name}`}
        disabled={operating}
        onClick={() => act('eject_single', { index: item.index })}
      />
    </Stack>
  );
};
