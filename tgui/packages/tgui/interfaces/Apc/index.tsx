/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { SFC } from 'inferno';
import { BooleanLike } from 'common/react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  LabeledList,
  Section,
} from '../../components';
import { Window } from '../../layouts';
import { AccessPanelSection } from './AccessPanelSection';
import { MainSection } from './MainSection';
import { PowerChannelSection } from './PowerChannelSection';
import type { ApcData } from './types';
import { calculateWindowHeight, getHasPermission, getIsAccessPanelVisible, getIsLocalAccess } from './util';

interface CoverLockProps {
  coverlocked: BooleanLike;
  hasPermission: boolean;
  onCoverLockedChange: (value: boolean) => void;
}

const CoverLock: SFC<CoverLockProps> = (props) => {
  const { coverlocked, hasPermission, onCoverLockedChange } = props;
  return (
    <>
      <Button
        disabled={!hasPermission && !!coverlocked}
        onClick={() => onCoverLockedChange(false)}
        selected={!coverlocked}
      >
        Off
      </Button>
      <Button
        disabled={!hasPermission && !coverlocked}
        onClick={() => onCoverLockedChange(true)}
        selected={!!coverlocked}
      >On
      </Button>
    </>
  );
};

const windowWidth = 360;

export const Apc = (_props, context) => {
  const { data } = useBackend<ApcData>(context);
  const { area_requires_power } = data;
  return area_requires_power ? <PoweredAreaApc /> : <UnpoweredAreaApc />;
};

const PoweredAreaApc = (_props, context) => {
  const { act, data } = useBackend<ApcData>(context);
  const {
    area_requires_power,
    can_access_remotely,
    coverlocked,
  } = data;
  const isLocalAccess = getIsLocalAccess(data);
  const hasPermission = getHasPermission(data);
  const canOverload = !!can_access_remotely;
  const isAccessPanelVisible = getIsAccessPanelVisible(data);
  const windowHeight = calculateWindowHeight(
    area_requires_power,
    true,
    true,
    canOverload,
    isAccessPanelVisible,
    isLocalAccess,
  );

  // #region event handlers
  const handleCoverLockedChange = (coverlocked: BooleanLike) => act('onCoverLockedChange', { coverlocked });
  const handleOverload = () => act('onOverload');
  // #endregion

  return (
    <Window
      title="Area Power Controller"
      width={windowWidth}
      height={windowHeight}
      theme="ntos"
    >
      <Window.Content>
        <MainSection />
        <PowerChannelSection />
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Cover Lock"
              buttons={(
                <CoverLock
                  coverlocked={coverlocked}
                  hasPermission={hasPermission}
                  onCoverLockedChange={handleCoverLockedChange}
                />
              )}
            />
          </LabeledList>
        </Section>
        {canOverload && (
          <Section>
            <Button align="center" color="red" fluid icon="bolt" onClick={handleOverload}>Overload Lighting Circuit</Button>
          </Section>
        )}
        {isAccessPanelVisible && <AccessPanelSection />}
      </Window.Content>
    </Window>
  );
};

const UnpoweredAreaApc = (_props, context) => {
  const { data } = useBackend<ApcData>(context);
  const { area_name, area_requires_power } = data;
  const isAccessPanelVisible = getIsAccessPanelVisible(data);
  const windowHeight = calculateWindowHeight(area_requires_power, false, false, false, isAccessPanelVisible, false);
  return (
    <Window
      title="Area Power Controller"
      width={windowWidth}
      height={windowHeight}
      theme="ntos"
    >
      <Window.Content>
        <Section title={`Area Power Controller (${area_name})`}>
          <Box>This APC has no configurable settings.</Box>
        </Section>
        {isAccessPanelVisible && <AccessPanelSection />}
      </Window.Content>
    </Window>
  );
};
