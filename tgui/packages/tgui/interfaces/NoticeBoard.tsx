/**
 * @file
 * @copyright 2026
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface Items {
  items: Item[];
}

interface Item {
  item_type: string;
  item_name: string;
  item_ref: string;
}

export const NoticeBoard = () => {
  const { data, act } = useBackend<Items>();
  const { items } = data;
  return (
    <Window title="Notice Board" width={520} height={410}>
      <Window.Content scrollable>
        <Stack wrap="wrap">
          {items.map((item) => (
            <Stack.Item key={item.item_ref}>
              <Section>
                <Stack>
                  <Stack.Item>
                    <Button
                      icon={item.item_type === 'paper' ? 'file-lines' : 'image'}
                      onClick={() =>
                        act('view_item', { selected_item: item.item_ref })
                      }
                    >
                      {item.item_name}
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="eject"
                      onClick={() =>
                        act('remove_item', { selected_item: item.item_ref })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
