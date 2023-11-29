/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useLocalState } from '../../../backend';
import { Button, Dropdown, Input, NumberInput, Section, Stack } from '../../../components';
import { BanListTabData, BanPanelSearchFilterOptions } from '../type';
import { BanListItem } from './BanListItem';
import { HeaderCell } from './Cell';
import { columnConfigs } from './columnConfig';

interface BanListProps {
  data: BanListTabData;
  onSearch: (searchText: string) => void;
  onPreviousPage: () => void;
  onNextPage: () => void;
  onPerPageChange: (amount: number) => void;
  onEditBan: (id: number) => void;
  onDeleteBan: (id: number) => void;
}

const DEFAULT_PAGE_SIZE = 30;

export const BanList = (props: BanListProps, context) => {
  const { data, onSearch, onPreviousPage, onNextPage, onPerPageChange, onEditBan, onDeleteBan } = props;
  const { ban_list, per_page } = data;
  const { search_response } = ban_list ?? {};
  const { data: banResources } = search_response ?? {};
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [searchFilter, setSearchFilter] = useLocalState(context, 'searchFilter', BanPanelSearchFilterOptions.ckey);
  const handleSearch = () => onSearch(searchText);
  const handleSearchTextChange = (_e, value: any) => setSearchText(value);
  const handlePreviousPage = () => onPreviousPage();
  const handleNextPage = () => onNextPage();
  const handlePerPageChange = (_e, value: any) => onPerPageChange(value);
  const handleEditBan = (_e, id: number) => onEditBan(id);
  const handleDeleteBan = (_e, id: number) => onDeleteBan(id);
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
            options={Object.keys(BanPanelSearchFilterOptions)}
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
              <BanListItem
                key={banData.id}
                columnConfigs={columnConfigs}
                data={banData}
                handleEditBan={handleEditBan}
                handleDeleteBan={handleDeleteBan}
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
            maxValue={99}
            value={per_page ?? DEFAULT_PAGE_SIZE}
            placeholder={DEFAULT_PAGE_SIZE}
            onChange={handlePerPageChange}
          />
        </Section>
      </Stack.Item>
    </>
  );
};
