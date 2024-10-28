/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import {
  Box,
  Button,
  Divider,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { CellDisplay } from './CellDisplay';
import type { ApcData } from './types';
import { getHasPermission, getIsLocalAccess } from './util';

enum MainStatus {
  None = 0,
  Low = 1,
  Good = 2,
}

interface MainStatusConfig {
  name: string;
  color: string;
}

const mainStatusConfigLookup: Record<MainStatus, MainStatusConfig> = {
  [MainStatus.None]: { name: 'None', color: 'red' },
  [MainStatus.Low]: { name: 'Low', color: 'yellow' },
  [MainStatus.Good]: { name: 'Good', color: 'green' },
};

interface ExternalPowerListItemProps {
  mainStatus: MainStatus;
}

const ExternalPowerListItem = (props: ExternalPowerListItemProps) => {
  const { mainStatus } = props;
  const mainStatusConfig = mainStatusConfigLookup[mainStatus];
  return (
    <LabeledList.Item
      label="External Power"
      color={mainStatusConfig.color}
      textAlign="right"
    >
      {mainStatusConfig.name}
    </LabeledList.Item>
  );
};

export const MainSection = (_props, context) => {
  const { act, data } = useBackend<ApcData>();
  const { area_name, host_id, locked, main_status, operating } = data;

  const hasPermission = getHasPermission(data);
  const isLocalAccess = getIsLocalAccess(data);

  // #region event handlers
  const handleOperatingChange = (operating: BooleanLike) =>
    act('onOperatingChange', { operating });
  // #endregion

  return (
    <Section title={area_name}>
      {isLocalAccess && (
        <>
          <Box align="center" bold>
            Swipe ID card to {locked ? 'unlock' : 'lock'} interface
          </Box>
          <Divider />
        </>
      )}
      <LabeledList>
        <LabeledList.Item
          label="Main Breaker"
          buttons={
            <>
              <Button
                disabled={!hasPermission && operating}
                onClick={() => handleOperatingChange(false)}
                selected={!operating}
              >
                Off
              </Button>
              <Button
                disabled={!hasPermission && !operating}
                onClick={() => handleOperatingChange(true)}
                selected={operating}
              >
                On
              </Button>
            </>
          }
        />
        <CellDisplay />
        <ExternalPowerListItem mainStatus={main_status} />
        {isLocalAccess && (
          <LabeledList.Item
            label="Host Connection"
            color={host_id ? 'green' : 'red'}
            textAlign="right"
          >
            {host_id ? 'OK' : 'NONE'}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};
