/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button, Input, Section, Stack } from 'tgui-core/components';

interface CaptureFiltersProps {
  filter: string | null;
  destinationFilter: string | null;
  search: string;
  onSetFilter: (filter: string) => void;
  onClearFilter: () => void;
  onSetDestinationFilter: (filter: string) => void;
  onClearDestinationFilter: () => void;
  onSearch: (search: string) => void;
}

export const CaptureFilters = (props: CaptureFiltersProps) => {
  const {
    filter,
    destinationFilter,
    search,
    onSetFilter,
    onClearFilter,
    onSetDestinationFilter,
    onClearDestinationFilter,
    onSearch,
  } = props;

  return (
    <Section title="CAPTURE CONTROL // ADDRESS MASKS">
      <Stack align="center">
        <Stack.Item>
          <AddressMask
            label="SRC"
            filter={filter}
            tooltip="Sender address (8 hex digits)"
            onSetFilter={onSetFilter}
            onClearFilter={onClearFilter}
          />
        </Stack.Item>
        <Stack.Item>
          <AddressMask
            label="DST"
            filter={destinationFilter}
            tooltip="Destination address (8 hex digits or ping)"
            onSetFilter={onSetDestinationFilter}
            onClearFilter={onClearDestinationFilter}
          />
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

const AddressMask = (props: {
  label: string;
  filter: string | null;
  tooltip: string;
  onSetFilter: (filter: string) => void;
  onClearFilter: () => void;
}) => {
  const { label, filter, tooltip, onSetFilter, onClearFilter } = props;

  return (
    <Stack align="center">
      <Stack.Item color="label">[{label}]</Stack.Item>
      <Stack.Item>
        <Button.Input
          icon={filter ? 'lock' : 'edit'}
          color={filter ? 'default' : 'transparent'}
          textColor={filter ? undefined : 'white'}
          tooltip={tooltip}
          value={filter ?? ''}
          maxLength={8}
          buttonText={filter || '********'}
          onCommit={onSetFilter}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="times"
          color="transparent"
          disabled={!filter}
          tooltip={'Clear ' + label + ' mask'}
          onClick={onClearFilter}
        />
      </Stack.Item>
    </Stack>
  );
};
