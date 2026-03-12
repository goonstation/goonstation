/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { PropsWithChildren } from 'react';
import { Icon, Stack } from 'tgui-core/components';

import { SortDirection } from './constant';

interface HeaderProps {
  onSortClick?: () => any;
  sortDirection?: SortDirection;
}

export const Header = (props: PropsWithChildren<HeaderProps>) => {
  const { children, onSortClick, sortDirection, ...rest } = props;
  const iconName = sortDirection
    ? sortDirection === SortDirection.Asc
      ? 'sort-alpha-down'
      : 'sort-alpha-up'
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
          <Icon name={iconName} />
        </Stack.Item>
      )}
    </Stack>
  );
};
