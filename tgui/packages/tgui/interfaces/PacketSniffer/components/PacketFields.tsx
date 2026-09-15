/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Stack } from 'tgui-core/components';

import type { FilterProps, PacketField } from '../type';
import { displayValue } from '../utils';
import { AddressFilter } from './AddressFilter';
import { PacketText } from './PacketText';

export const PacketFields = (
  props: FilterProps & { fields: Array<PacketField> },
) => {
  const { fields, ...filterProps } = props;

  return (
    <Stack vertical>
      {!!fields.length && (
        <Stack.Item bold color="label">
          <Stack>
            <Stack.Item grow basis={0} minWidth={0}>
              PARAMETER
            </Stack.Item>
            <Stack.Item grow={2} basis={0} minWidth={0}>
              DECODED VALUE
            </Stack.Item>
          </Stack>
        </Stack.Item>
      )}
      {fields.map(({ key, value }, index) => (
        <Stack.Item key={index}>
          <Stack>
            <Stack.Item grow basis={0} minWidth={0} color="label">
              <PacketText>{'$' + key}</PacketText>
            </Stack.Item>
            <Stack.Item grow={2} basis={0} minWidth={0}>
              <PacketText>
                {['sender', 'address_1', 'address_2', 'netid'].includes(key) ? (
                  <AddressFilter address={value} {...filterProps} />
                ) : (
                  displayValue(value)
                )}
              </PacketText>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
      {!fields.length && (
        <Stack.Item color="label">[VOID] NO DECODED PARAMETERS</Stack.Item>
      )}
    </Stack>
  );
};
