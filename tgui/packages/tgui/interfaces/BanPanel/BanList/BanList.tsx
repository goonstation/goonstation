/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useLocalState } from '../../../backend';
import { Button, Dropdown, Flex, Input, NumberInput, Section, Stack } from '../../../components';
import { HeaderCell } from '../../../components/goonstation/ListGrid';
import { useBanPanelBackend } from '../useBanPanelBackend';
import type { BanListTabData } from '../type';
import { BanPanelSearchFilter } from '../type';
import { BanListItem } from './BanListItem';
import { buildColumnConfigs } from './columnConfig';
import type { BanResource } from '../apiType';

interface BanListProps {
  data: BanListTabData;
}

const DEFAULT_PAGE_SIZE = 30;
const filterOptions = Object.keys(BanPanelSearchFilter);
const getRowId = (data: BanResource) => `${data.id}`;

export const BanList = (props: BanListProps, context) => {
  const { data } = props;
  const { ban_list, per_page } = data;
  const { action } = useBanPanelBackend(context);
  const { search_response } = ban_list ?? {};
  const { data: banResources } = search_response ?? {};
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [searchFilter, setSearchFilter] = useLocalState(context, 'searchFilter', BanPanelSearchFilter.ckey);
  const handleSearch = () => action.searchBans(searchText, BanPanelSearchFilter[searchFilter]);
  const handleSearchTextChange = (_e, value: string) => setSearchText(value);
  const handlePreviousPage = action.navigatePreviousPage;
  const handleNextPage = action.navigateNextPage;
  const handlePerPageChange = (_e, value: number) => action.setPerPage(value);
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
              nochevron
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
              <BanListItem key={banData.id} columnConfigs={columnConfigs} data={banData} rowId={getRowId(banData)} />
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
            placeholder={DEFAULT_PAGE_SIZE}
            onChange={handlePerPageChange}
          />
        </Section>
      </Stack.Item>
    </>
  );
};
