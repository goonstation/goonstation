/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { InfernoNode } from 'inferno';
import { Stack, Icon } from '../../components';
import { SortDirection } from './constant';

interface HeaderProps {
  children: InfernoNode,
  onSortClick?: () => any,
  sortDirection?: SortDirection,
}

export const Header = (props: HeaderProps) => {
  const {
    children,
    onSortClick,
    sortDirection,
    ...rest
  } = props;
  const iconName = sortDirection
    ? (sortDirection === SortDirection.Asc ? 'sort-alpha-down' : 'sort-alpha-up')
    : 'sort';
  return (
    <Stack
      style={{
        cursor: 'pointer',
      }}
      onClick={onSortClick}
      {...rest}
    >
      <Stack.Item>{children}</Stack.Item>
      {onSortClick && (
        <Stack.Item>
          <Icon
            name={iconName}
            unselectable
          />
        </Stack.Item>
      )}
    </Stack>
  );
};
