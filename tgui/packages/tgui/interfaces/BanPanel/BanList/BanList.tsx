/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button, Input, Section, Stack } from '../../../components';
import type { BanListTabData } from '../type';
import { BanListItem } from './BanListItem';
import { HeaderCell } from './Cell';
import { columnConfigs } from './columnConfig';

interface BanListProps {
  data: BanListTabData;
  onSearch: (filters?: object) => void;
}

export const BanList = (props: BanListProps) => {
  const { data, onSearch } = props;
  const { ban_list } = data;
  const { search_response } = ban_list ?? {};
  const handleSearch = () => onSearch();
  return (
    <>
      <Stack.Item>
        <Section>
          <Input />
          <Button icon="magnifying-glass" onClick={handleSearch} tooltip="Not yet implemented">
            Search
          </Button>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Stack>
            {columnConfigs.map((columnConfig) => (
              <HeaderCell key={columnConfig.id} config={columnConfig} />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical mb={1}>
            {(search_response?.data ?? []).map((banData) => (
              <BanListItem key={banData.id} columnConfigs={columnConfigs} data={banData} />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Button>Prev</Button>
          <Button>Next</Button>
        </Section>
      </Stack.Item>
    </>
  );
};
