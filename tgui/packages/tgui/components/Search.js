/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { classes } from 'common/react';
import { Input } from './Input';
import { Section } from './Section';

export const Search = props => {
  const {
    autoFocus,
    className,
    currentSearch,
    onSearch,
    onSelect,
    options = [],
    placeholder = 'Search',
    selectedOption = null,
  } = props;
  const handleSearch = (e, value) => {
    onSearch(value);
  };
  return (
    <div className={className}>
      <Input
        autoFocus={autoFocus}
        fluid
        mb={1}
        placeholder={placeholder}
        onInput={handleSearch}
        value={currentSearch}
      />
      <Section>
        {options.map(option => (
          <div
            key={option}
            title={option}
            className={classes([
              'Button',
              'Button--fluid',
              'Button--color--transparent',
              'Button--ellipsis',
              selectedOption && option === selectedOption && 'Button--selected',
            ])}
            onClick={() => onSelect(option)}>
            {option}
          </div>
        ))}
      </Section>
    </div>
  );
};
