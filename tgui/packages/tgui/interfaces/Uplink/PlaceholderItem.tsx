/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Section, Stack } from 'tgui-core/components';

interface PlaceholderItemProps {
  onClearClick: () => void;
}

export const PlaceholderItem = (props: PlaceholderItemProps) => {
  const { onClearClick } = props;
  return (
    <Stack.Item>
      <Section textAlign="center">
        <Stack vertical>
          <Stack.Item>
            Could not find anything matching those filters!
          </Stack.Item>
          <Stack.Item>
            <Button onClick={onClearClick}>Clear Filters</Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};
