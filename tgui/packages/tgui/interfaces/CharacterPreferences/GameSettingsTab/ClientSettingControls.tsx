/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import type { ReactNode } from 'react';
import { Box, Button } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { CharacterPreferencesData, ClientSettings } from '../type';

export const useClientSetting = () => {
  const { act, data } = useBackend<CharacterPreferencesData>();
  const settings = data.clientSettings;
  const setSetting = <K extends keyof ClientSettings>(
    setting: K,
    value: ClientSettings[K],
  ) => act('update-clientSetting', { setting, value });
  return { settings, setSetting };
};

interface ClientToggleProps {
  setting: keyof ClientSettings;
  tooltip?: string;
  children: ReactNode;
}

export const ClientToggle = (props: ClientToggleProps) => {
  const { settings, setSetting } = useClientSetting();
  const { setting, tooltip, children } = props;
  return (
    <Box mb="5px">
      <Button.Checkbox
        checked={!!settings[setting]}
        onClick={() => setSetting(setting, !settings[setting])}
        tooltip={tooltip}
        tooltipPosition="top"
      >
        {children}
      </Button.Checkbox>
    </Box>
  );
};

interface ClientChoiceProps<K extends keyof ClientSettings> {
  setting: K;
  options: [ClientSettings[K], string][];
}

export const ClientChoice = <K extends keyof ClientSettings>(
  props: ClientChoiceProps<K>,
) => {
  const { settings, setSetting } = useClientSetting();
  const { setting, options } = props;
  return (
    <>
      {options.map(([value, label]) => (
        <Box mb="5px" key={String(value)}>
          <Button.Checkbox
            checked={settings[setting] === value}
            onClick={() => setSetting(setting, value)}
          >
            {label}
          </Button.Checkbox>
        </Box>
      ))}
    </>
  );
};
