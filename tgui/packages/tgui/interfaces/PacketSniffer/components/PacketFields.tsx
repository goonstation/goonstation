/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import { Stack } from 'tgui-core/components';

import type { PacketField } from '../type';
import { displayValue } from '../utils';
import { PacketText } from './PacketText';

export const PacketFields = (props: { fields: Array<PacketField> }) => {
  const { fields } = props;

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
      {fields.map(({ name, value }) => (
        <Stack.Item key={name}>
          <Stack>
            <Stack.Item grow basis={0} minWidth={0} color="label">
              <PacketText>{'$' + name}</PacketText>
            </Stack.Item>
            <Stack.Item grow={2} basis={0} minWidth={0}>
              <PacketText>{displayValue(value)}</PacketText>
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
