/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { Button, Input, NumberInput, Section, Stack } from '../../../components';
import type { BanListTabData } from '../type';
import { BanListItem } from './BanListItem';
import { HeaderCell } from './Cell';
import { columnConfigs } from './columnConfig';

interface BanListProps {
  data: BanListTabData;
  onSearch: (filters?: object) => void;
  onPreviousPage: () => void;
  onNextPage: () => void;
  onPerPage: (amount: number) => void;
}

export const BanList = (props: BanListProps) => {
  const { data, onSearch, onPreviousPage, onNextPage, onPerPage } = props;
  const { ban_list } = data;
  const { search_response } = ban_list ?? {};
  const handleSearch = () => onSearch();
  const handlePreviousPage = () => onPreviousPage();
  const handleNextPage = () => onNextPage();
  const setPerPage = (amount: number) => onPerPage(amount);
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
          <Button onClick={handlePreviousPage} >Prev</Button>
          <Button onClick={handleNextPage} >Next</Button>
          {/* TODO: Page selector should float right */}
          <NumberInput
            minValue={5}
            maxValue={99}
            value={data["per_page"]}
            placeholder={30}
            onChange={(_, value) => setPerPage(value)} />
        </Section>
      </Stack.Item>
    </>
  );
};
