/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';

import { Placeholder } from '../../components';

interface ListSearchProps {
  autoFocus?: boolean;
  className?: string;
  /** Enable fuzzy search with specified matching strategy. Default: 'off' */
  fuzzy?: 'off' | 'smart' | 'aggressive';
  /** Height of the list area. Default: `30rem` */
  height?: string | number;
  noResultsPlaceholder?: string;
  /** `onSelect` is called with the option clicked; parent decides how to update `selectedOptions` */
  onSelect: (value: string) => void;
  options: string[];
  searchPlaceholder?: string;
  selectedOptions?: string[];
  /** Allow toggling multiple selections and show checkboxes. Default: `false` */
  multipleSelect?: boolean;
  /** Use virtual list rendering if past `virtualizeThreshold` or `true` - pass `false` to fully disable */
  virtualize?: boolean | undefined;
  /** Default threshold is `250` */
  virtualizeThreshold?: number;
}

export const ListSearch = (props: ListSearchProps) => {
  const {
    autoFocus,
    className,
    fuzzy,
    height = '30rem',
    noResultsPlaceholder,
    onSelect,
    options,
    searchPlaceholder = 'Search...',
    selectedOptions = [],
    multipleSelect = false,
    virtualize,
    virtualizeThreshold = 250,
  } = props;

  // Internal search state
  const [searchText, setSearchText] = useState('');

  // Always use fuzzy search, defaulting to "off" if not specified
  const fuzzySearch = useFuzzySearch({
    searchArray: options,
    matchStrategy: fuzzy || 'off',
    getSearchString: (item) => item,
  });

  const handleSearch = (value: string) => {
    fuzzySearch.setQuery(value);
    setSearchText(value);
  };

  const renderOptions = () => {
    const displayOptions =
      searchText.trim() !== '' ? fuzzySearch.results : options;

    if (displayOptions.length === 0) {
      return (
        <Placeholder mx={1} py={0.5}>
          {noResultsPlaceholder}
        </Placeholder>
      );
    }

    const children = displayOptions.map((option) => {
      const isSelected = selectedOptions.includes(option);
      return (
        <div
          key={option}
          className={classes([
            'list-search-interface__search-option',
            'Button',
            'Button--color--transparent',
            isSelected && 'Button--selected',
          ])}
          onClick={() => onSelect(option)}
          title={option}
          style={{ display: 'flex', alignItems: 'center' }}
        >
          {multipleSelect && (
            <Button.Checkbox
              checked={isSelected}
              mr={0.5}
              onClick={(e) => {
                e.stopPropagation();
                onSelect(option);
              }}
            />
          )}
          <Box overflow="hidden" style={{ textOverflow: 'ellipsis' }}>
            {option}
          </Box>
        </div>
      );
    });

    const shouldVirtualize =
      virtualize === false
        ? false
        : virtualize === true || displayOptions.length > virtualizeThreshold;

    if (shouldVirtualize) {
      // key prop based on length to force remount when filtered
      return (
        <VirtualList key={`vlist-${displayOptions.length}`}>
          {children}
        </VirtualList>
      );
    }
    return children;
  };

  const cn = classes(['list-search-interface', className]);

  return (
    <Stack className={cn} vertical fill>
      <Stack.Item>
        <Input
          autoFocus={autoFocus}
          fluid
          onChange={handleSearch}
          placeholder={searchPlaceholder}
          value={searchText}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Box height={height}>
          <Section fill scrollable>
            {renderOptions()}
          </Section>
        </Box>
      </Stack.Item>
    </Stack>
  );
};
