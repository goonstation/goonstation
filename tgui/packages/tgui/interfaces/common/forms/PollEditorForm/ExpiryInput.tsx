/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { ReactNode } from 'react';
import { Dropdown, Input, NumberInput, Stack } from 'tgui-core/components';

import type { ExpiryOptions, ExpiryType } from './types';

const expiryTypeLookup: Record<ExpiryType, string> = {
  never: 'Never',
  minutes: 'Minutes',
  hours: 'Hours',
  days: 'Days',
  timestamp: 'Timestamp',
};

export const expiryTypeLookupByName: Partial<Record<string, ExpiryType>> =
  Object.entries(expiryTypeLookup).reduce((acc, [id, name]) => {
    acc[name] = id;
    return acc;
  }, {});

export const expiryTypeOptions = Object.keys(expiryTypeLookupByName);

const safeParseInt = (value: string, defaultValue: number = 0) => {
  const parsed = parseInt(value, 10);
  if (isNaN(parsed)) {
    return defaultValue;
  }
  return value;
};

interface ExpiryInputProps {
  onChange: (newValue: ExpiryOptions) => void;
  value: ExpiryOptions;
}

export const ExpiryInput = (props: ExpiryInputProps) => {
  const { onChange, value } = props;
  const { expiryType, expiryValue } = value;
  const handleChangeTypePart = (typeName: string) => {
    const typeLookup = expiryTypeLookupByName[typeName];
    onChange({
      expiryType: typeLookup,
      expiryValue: '',
    });
  };
  const handleChangeValuePart = (newValue: string) =>
    onChange({
      expiryType,
      expiryValue: newValue,
    });
  const handleChangeNumberValuePart = (newValue: number) => {
    onChange({
      expiryType,
      expiryValue: `${newValue}`,
    });
  };
  let valueControl: ReactNode = null;
  if (expiryType === 'timestamp') {
    valueControl = (
      <Input
        width="100%"
        value={expiryValue}
        onChange={handleChangeValuePart}
        placeholder="yyyy-mm-dd"
      />
    );
  } else if (expiryType && ['minutes', 'days', 'hours'].includes(expiryType)) {
    valueControl = (
      <NumberInput
        width="100%"
        value={safeParseInt(expiryValue)}
        onChange={handleChangeNumberValuePart}
        minValue={0}
        maxValue={1_000}
        step={1}
      />
    );
  }
  return (
    <Stack>
      <Stack.Item>
        <Dropdown
          options={expiryTypeOptions}
          selected={expiryType && expiryTypeLookup[expiryType]}
          onSelected={handleChangeTypePart}
          key={expiryType}
        />
      </Stack.Item>
      {valueControl && <Stack.Item grow>{valueControl}</Stack.Item>}
    </Stack>
  );
};
