/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
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
  currentSearch: string;
  /** Height of the list area. Default: 30rem */
  height?: string | number;
  noResultsPlaceholder?: string;
  onSearch: (value: string) => void;
  // onSelect is called with the option clicked; parent decides how to update selectedOptions
  onSelect: (value: string) => void;
  options: string[];
  searchPlaceholder?: string;
  selectedOptions: string[];
  /** Allow toggling multiple selections and show checkboxes. Default: False */
  multipleSelect?: boolean;
  virtualize?: boolean | undefined;
  /** Default threshold is 250 */
  virtualizeThreshold?: number;
}

export const ListSearch = (props: ListSearchProps) => {
  const {
    autoFocus,
    className,
    currentSearch,
    height = '30rem',
    noResultsPlaceholder,
    onSearch,
    onSelect,
    options,
    searchPlaceholder = 'Search...',
    selectedOptions = [],
    multipleSelect = false,
    virtualize,
    virtualizeThreshold = 250,
  } = props;
  const handleSearch = (value: string) => {
    onSearch(value);
  };
  const cn = classes(['list-search-interface', className]);

  const renderOptions = () => {
    if (options.length === 0) {
      return (
        <Placeholder mx={1} py={0.5}>
          {noResultsPlaceholder}
        </Placeholder>
      );
    }

    const children = options.map((option) => {
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
        : virtualize === true || options.length > virtualizeThreshold;

    if (shouldVirtualize) {
      return <VirtualList>{children}</VirtualList>;
    }
    return children;
  };

  return (
    <Stack className={cn} vertical fill>
      <Stack.Item>
        <Input
          autoFocus={autoFocus}
          fluid
          onChange={handleSearch}
          placeholder={searchPlaceholder}
          value={currentSearch}
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
