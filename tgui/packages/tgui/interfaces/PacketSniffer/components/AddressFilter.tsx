/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Button } from 'tgui-core/components';

import type { FilterProps } from '../type';
import { displayValue, isNetId } from '../utils';

export const AddressFilter = ({
  address,
  destination = false,
  filter,
  destinationFilter,
  onFilter,
  onDestinationFilter,
}: FilterProps & {
  address: string | null | undefined;
  destination?: boolean;
}) => {
  const normalizedAddress = address?.trim() ?? address;
  const activeFilter = destination ? destinationFilter : filter;
  const onFilterChange = destination ? onDestinationFilter : onFilter;
  const selected =
    normalizedAddress?.toLocaleLowerCase() ===
    activeFilter?.trim().toLocaleLowerCase();
  if (
    !(destination && normalizedAddress?.toLocaleLowerCase() === 'ping') &&
    !isNetId(normalizedAddress)
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
          : (destination ? 'Capture to ' : 'Capture from ') + normalizedAddress
      }
      onClick={() => onFilterChange(normalizedAddress)}
    >
      {normalizedAddress}
    </Button>
  );
};
