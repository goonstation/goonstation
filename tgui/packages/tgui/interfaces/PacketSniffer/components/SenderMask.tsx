/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Icon, Input, Section, Stack } from 'tgui-core/components';

interface SenderMaskProps {
  filter: string | null;
  search: string;
  onSetFilter: (filter: string) => void;
  onClearFilter: () => void;
  onSearch: (search: string) => void;
}

export const SenderMask = (props: SenderMaskProps) => {
  const { filter, search, onSetFilter, onClearFilter, onSearch } = props;

  return (
    <Section
      title="CAPTURE CONTROL // SENDER MASK"
      buttons={
        <Stack>
          <Stack.Item>
            <Button.Input
              icon="edit"
              tooltip="8-digit hex sender address"
              value={filter ?? ''}
              maxLength={8}
              buttonText={filter ? 'EDIT MASK' : 'SET MASK'}
              onCommit={onSetFilter}
            />
          </Stack.Item>
          {!!filter && (
            <Stack.Item>
              <Button
                icon="times"
                color="transparent"
                tooltip="Capture all senders"
                onClick={onClearFilter}
              >
                CLEAR
              </Button>
            </Stack.Item>
          )}
        </Stack>
      }
    >
      <Stack align="center">
        <Stack.Item>
          <Icon name="filter" />
        </Stack.Item>
        <Stack.Item color={filter ? 'good' : 'label'} bold>
          {filter ? '[LOCK] ' + filter : '[OPEN] ******** // ALL SENDERS'}
        </Stack.Item>
        <Stack.Item grow minWidth={0}>
          <Stack align="center">
            <Stack.Item color="label">[FIND]</Stack.Item>
            <Stack.Item grow minWidth={0}>
              <Input
                fluid
                value={search}
                onChange={onSearch}
                placeholder="Search..."
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="times"
            color="transparent"
            disabled={!search}
            tooltip="Clear search"
            onClick={() => onSearch('')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
