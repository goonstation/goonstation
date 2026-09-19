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
    destination?: boolean;
  },
) => {
  const { address, destination = false } = props;
  const filter = destination ? props.destinationFilter : props.filter;
  const onFilter = destination ? props.onDestinationFilter : props.onFilter;
  const selected = address?.toLowerCase() === filter?.toLowerCase();
  if (
    !(destination && address?.toLowerCase() === 'ping') &&
    !isNetId(address)
  ) {
    return <>{displayValue(address)}</>;
  }

  return (
    <Button
      icon="filter"
      color={selected ? 'default' : 'transparent'}
      textColor={selected ? undefined : 'white'}
      selected={selected}
      tooltip={
        selected
          ? destination
            ? 'Clear destination mask'
            : 'Clear sender mask'
          : (destination ? 'Capture to ' : 'Capture from ') + address
      }
      onClick={() => onFilter(address)}
    >
      {address}
    </Button>
  );
};
