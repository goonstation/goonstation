/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useState } from 'react';
import {
  Button,
  Dropdown,
  Flex,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { HeaderCell } from '../../../components/goonstation/ListGrid';
import type { BanResource } from '../apiType';
import type { BanListTabData } from '../type';
import { BanPanelSearchFilter } from '../type';
import { useBanPanelBackend } from '../useBanPanelBackend';
import { BanListItem } from './BanListItem';
import { buildColumnConfigs } from './columnConfig';

interface BanListProps {
  data: BanListTabData;
}

const DEFAULT_PAGE_SIZE = 30;
const filterOptions = Object.keys(BanPanelSearchFilter);
const getRowId = (data: BanResource) => `${data.id}`;

export const BanList = (props: BanListProps) => {
  const { data } = props;
  const { ban_list, per_page } = data;
  const { action } = useBanPanelBackend();
  const { search_response } = ban_list ?? {};
  const { data: banResources } = search_response ?? {};
  const [searchText, setSearchText] = useState('');
  const [searchFilter, setSearchFilter] = useState(BanPanelSearchFilter.ckey);
  const handleSearch = () =>
    action.searchBans(searchText, BanPanelSearchFilter[searchFilter]);
  const handleSearchTextChange = (value: string) => setSearchText(value);
  const handlePreviousPage = action.navigatePreviousPage;
  const handleNextPage = action.navigateNextPage;
  const handlePerPageChange = (value: number) => action.setPerPage(value);
  const handleEditBan = (id: number) => action.editBan(id);
  const handleDeleteBan = (id: number) => action.deleteBan(id);
  const columnConfigs = buildColumnConfigs({
    editBan: handleEditBan,
    deleteBan: handleDeleteBan,
  });
  return (
    <>
      <Stack.Item>
        <Flex pt={1}>
          <Flex.Item direction="column" mx={1} wrap="wrap">
            <Input value={searchText} onInput={handleSearchTextChange} mr={1} />
            <Button icon="magnifying-glass" onClick={handleSearch}>
              Search
            </Button>
          </Flex.Item>
          <Flex.Item grow>
            <Dropdown
              width={11}
              icon="filter"
              noChevron
              selected={searchFilter}
              options={filterOptions}
              onSelected={(value: BanPanelSearchFilter) => {
                setSearchFilter(value);
              }}
            />
          </Flex.Item>
        </Flex>
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
          <Stack vertical zebra mb={1}>
            {(banResources ?? []).map((banData) => (
              <BanListItem
                key={banData.id}
                columnConfigs={columnConfigs}
                data={banData}
                rowId={getRowId(banData)}
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Button onClick={handlePreviousPage}>Prev</Button>
          <Button onClick={handleNextPage}>Next</Button>
          {/* TODO: Page selector should float right */}
          <NumberInput
            minValue={5}
            maxValue={100}
            value={per_page ?? DEFAULT_PAGE_SIZE}
            onChange={handlePerPageChange}
            step={5}
          />
        </Section>
      </Stack.Item>
    </>
  );
};
