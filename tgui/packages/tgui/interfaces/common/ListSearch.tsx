/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import { Placeholder } from '../../components';

interface ListSearchProps {
  autoFocus?: boolean;
  className?: string;
  /** Enable fuzzy search with specified matching strategy. Default: 'off' */
  fuzzy?: 'off' | 'smart' | 'aggressive';
  // I could not get this to work without a height prop despite spending hours. Feel free to try again.
  /** Height of the list area. */
  height: string | number;
  /** `onSelect` is called with the option clicked; parent decides how to update `selectedOptions` */
  onSelect: (value: string) => void;
  options: string[];
  searchPlaceholder?: string;
  noResultsPlaceholder?: string;
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

  const [searchText, setSearchText] = useState('');
  const [isEndWordSearch, setIsEndWordSearch] = useState(false);
  const [effectiveSearchTerm, setEffectiveSearchTerm] = useState('');
  const fuzzySearch = useFuzzySearch({
    searchArray: options,
    matchStrategy: fuzzy || 'off',
    getSearchString: (item) => item,
  });

  const handleSearch = (value: string) => {
    setSearchText(value);

    const isEndWord = value.endsWith('$');
    setIsEndWordSearch(isEndWord);

    // Set effective search term without the $ if present
    const effectiveTerm = isEndWord ? value.slice(0, -1) : value;
    setEffectiveSearchTerm(effectiveTerm);

    fuzzySearch.setQuery(effectiveTerm);
  };

  const renderOptions = () => {
    let displayOptions =
      effectiveSearchTerm.trim() === '' ? options : fuzzySearch.results;

    // Apply additional end-of-word boundary filtering if $ is used
    if (isEndWordSearch && effectiveSearchTerm.trim() !== '') {
      displayOptions = displayOptions.filter((option) =>
        option.endsWith(effectiveSearchTerm),
      );
    }

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
        <Section height={height} fill scrollable>
          {renderOptions()}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
