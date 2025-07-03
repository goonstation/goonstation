/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { CyborgDockingStationData } from './type';

// type to handle pass-through of non-TS Button props
type MockButtonProps = Record<string, any> & {
  disabled?: boolean;
};

interface DockingAllowedButtonProps extends MockButtonProps {}

export const DockingAllowedButton = (props: DockingAllowedButtonProps) => {
  const { disabled, ...rest } = props;
  const { data } = useBackend<CyborgDockingStationData>();
  return <Button disabled={disabled || data.disabled} {...rest} />;
};
