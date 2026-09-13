/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button } from 'tgui-core/components';

import type { FilterProps } from '../type';
import { displayValue, isNetId } from '../utils';

export const AddressFilter = (
  props: FilterProps & {
    address: string | null | undefined;
  },
) => {
  const { address, filter, onFilter } = props;
  const selected = address === filter;
  if (!isNetId(address)) {
    return <>{displayValue(address)}</>;
  }

  return (
    <Button
      icon="filter"
      color={selected ? 'default' : 'transparent'}
      textColor={selected ? undefined : 'white'}
      selected={selected}
      tooltip={selected ? 'Clear sender mask' : 'Capture from ' + address}
      onClick={() => onFilter(address)}
    >
      {address}
    </Button>
  );
};
