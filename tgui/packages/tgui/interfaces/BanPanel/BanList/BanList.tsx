/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useLocalState } from '../../../backend';
import { Button, Dropdown, Input, NumberInput, Section, Stack } from '../../../components';
import { HeaderCell } from '../../../components/goonstation/ListGrid';
import { useBanPanelBackend } from '../useBanPanelBackend';
import type { BanListTabData } from '../type';
import { BanPanelSearchFilterOptions } from '../type';
import { BanListItem } from './BanListItem';
import { buildColumnConfigs } from './columnConfig';
import type { BanResource } from '../apiType';

interface BanListProps {
  data: BanListTabData;
}

const DEFAULT_PAGE_SIZE = 30;
const filterOptions = Object.keys(BanPanelSearchFilterOptions);
const getRowId = (data: BanResource) => `${data.id}`;

export const BanList = (props: BanListProps, context) => {
  const { data } = props;
  const { ban_list, per_page } = data;
  const { action } = useBanPanelBackend(context);
  const { search_response } = ban_list ?? {};
  const { data: banResources } = search_response ?? {};
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [searchFilter, setSearchFilter] = useLocalState(context, 'searchFilter', BanPanelSearchFilterOptions.ckey);
  const handleSearch = () => action.searchBans(searchText);
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
        <Section>
          <Input value={searchText} onInput={handleSearchTextChange} />
          <Button icon="magnifying-glass" onClick={handleSearch}>
            Search
          </Button>
          <Dropdown
            width={10}
            icon="filter"
            selected={searchFilter}
            options={filterOptions}
            onSelected={(value: BanPanelSearchFilterOptions) => {
              setSearchFilter(value);
            }}
          />
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
