/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { Input, Stack } from 'tgui-core/components';

import { Placeholder } from '../../components';

interface ListSearchProps {
  autoFocus?: boolean;
  className?: string;
  currentSearch: string;
  noResultsPlaceholder?: string;
  onSearch: (value: string) => void;
  onSelect: (value: string) => void;
  options: string[];
  searchPlaceholder?: string;
  selectedOption?: string;
}

export const ListSearch = (props: ListSearchProps) => {
  const {
    autoFocus,
    className,
    currentSearch,
    noResultsPlaceholder,
    onSearch,
    onSelect,
    options,
    searchPlaceholder = 'Search...',
    selectedOption = null,
  } = props;
  const handleSearch = (value: string) => {
    onSearch(value);
  };
  const cn = classes(['list-search-interface', className]);
  return (
    <Stack className={cn} vertical>
      <Stack.Item>
        <Input
          autoFocus={autoFocus}
          fluid
          onInput={handleSearch}
          placeholder={searchPlaceholder}
          value={currentSearch}
        />
      </Stack.Item>
      <Stack.Item>
        {options.length === 0 && (
          <Placeholder mx={1} py={0.5}>
            {noResultsPlaceholder}
          </Placeholder>
        )}
        {options.map((option) => (
          <div
            className={classes([
              'list-search-interface__search-option',
              'Button',
              'Button--fluid',
              'Button--color--transparent',
              'Button--ellipsis',
              selectedOption && option === selectedOption && 'Button--selected',
            ])}
            key={option}
            onClick={() => onSelect(option)}
            title={option}
          >
            {option}
          </div>
        ))}
      </Stack.Item>
    </Stack>
  );
};
