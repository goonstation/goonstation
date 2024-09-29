import { Box, Divider, Flex, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  PortableBasicInfo,
  PortableHoldingTank,
} from '../common/PortableAtmos';
import { ReleaseValve } from '../common/ReleaseValve';
import { PaperSheetView } from '../PaperSheet/Stamps';
import { Detonator } from './Detonator';

interface GasCanisterData {
  connected;
  holding;
  hasValve;
  valveIsOpen;
  pressure;
  maxPressure;
  releasePressure;
  minRelease;
  maxRelease;
  detonator;
  detonatorAttachments;
  hasPaper;
  paperData;
}

export const GasCanister = () => {
  const { act, data } = useBackend<GasCanisterData>();

  const {
    connected,
    holding,
    hasValve,
    valveIsOpen,
    pressure,
    maxPressure,
    releasePressure,
    minRelease,
    maxRelease,
    detonator,
    detonatorAttachments,
    hasPaper,
  } = data;

  const handleSetPressure = (releasePressure) => {
    act('set-pressure', {
      releasePressure,
    });
  };

  const handleToggleValve = () => {
    act('toggle-valve');
  };

  const handleEjectTank = () => {
    act('eject-tank');
  };

  const handleWireInteract = (toolAction, index) => {
    act('wire-interact', {
      index,
      toolAction,
    });
  };

  const handleToggleAnchor = () => {
    act('anchor');
  };

  const handleToggleSafety = () => {
    act('safety');
  };

  const handlePrimeDetonator = () => {
    act('prime');
  };

  const handleTriggerActivate = () => {
    act('trigger');
  };

  const handleSetTimer = (newTime) => {
    act('timer', {
      newTime,
    });
  };

  const hasDetonator = !!detonator;

  return (
    <Window
      width={hasDetonator ? (hasPaper ? 880 : 470) : 305}
      height={hasDetonator ? 685 : 340}
    >
      <Window.Content>
        <Flex>
          <Flex.Item width="480px">
            <PortableBasicInfo
              connected={connected}
              pressure={pressure}
              maxPressure={maxPressure}
            >
              <Divider />
              {hasValve ? (
                <ReleaseValve
                  valveIsOpen={valveIsOpen}
                  releasePressure={releasePressure}
                  minRelease={minRelease}
                  maxRelease={maxRelease}
                  onToggleValve={handleToggleValve}
                  onSetPressure={handleSetPressure}
                />
              ) : (
                <Box color="average">The release valve is missing.</Box>
              )}
            </PortableBasicInfo>
            {detonator ? (
              <Detonator
                detonator={detonator}
                detonatorAttachments={detonatorAttachments}
                onToggleAnchor={handleToggleAnchor}
                onToggleSafety={handleToggleSafety}
                onWireInteract={handleWireInteract}
                onPrimeDetonator={handlePrimeDetonator}
                onTriggerActivate={handleTriggerActivate}
                onSetTimer={handleSetTimer}
              />
            ) : (
              <PortableHoldingTank
                holding={holding}
                onEjectTank={handleEjectTank}
              />
            )}
          </Flex.Item>
          {!!hasPaper && <Flex.Item width="410px">{<PaperView />}</Flex.Item>}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const PaperView = () => {
  const { data } = useBackend<GasCanisterData>();
  const { text, stamps } = data.paperData;

  return (
    <Section
      id="paperSection"
      scrollable
      backgroundColor="white"
      style={{ overflowWrap: 'break-word' }}
    >
      <PaperSheetView value={text ? text : ''} stamps={stamps} readOnly />
    </Section>
  );
};
