/**
 * @file
 * @copyright 2022
 * @author glowbold (https://github.com/pgmzeta)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useState } from 'react';
import { Box, Divider, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { OccupantSection } from './OccupantSection';
import { SuppliesSection } from './SuppliesSection';
import type { CyborgDockingStationData } from './type';

export const CyborgDockingStation = () => {
  const { data } = useBackend<CyborgDockingStationData>();
  const {
    allow_self_service,
    conversion_chamber,
    disabled,
    occupant,
    viewer_is_occupant,
    viewer_is_robot,
  } = data;
  const [tabIndex, setTabIndex] = useState(1);
  return (
    <Window
      width={500}
      height={640}
      title="Cyborg Docking Station"
      theme={
        conversion_chamber && occupant?.kind === 'human'
          ? 'syndicate'
          : 'nanotrasen'
      }
    >
      <Window.Content scrollable>
        {!!disabled && (
          <DisabledDisplayReason
            allowSelfService={!!allow_self_service}
            viewerIsOccupant={!!viewer_is_occupant}
            viewerIsRobot={!!viewer_is_robot}
          />
        )}
        <Stack>
          <Stack.Item>
            <Tabs vertical width="100px">
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                Occupant
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                Supplies
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            {tabIndex === 1 && <OccupantSection />}
            {tabIndex === 2 && <SuppliesSection />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface DisabledDisplayReasonProps {
  allowSelfService: boolean;
  viewerIsOccupant: boolean;
  viewerIsRobot: boolean;
}

const DisabledDisplayReason = (props: DisabledDisplayReasonProps) => {
  const { allowSelfService, viewerIsOccupant, viewerIsRobot } = props;
  return (
    <>
      <Box backgroundColor="#773333" p="5px" mb="5px" bold textAlign="center">
        {(viewerIsRobot &&
          !viewerIsOccupant &&
          'You must be inside the docking station to use the functions.') ||
          ''}
        {(viewerIsOccupant &&
          !viewerIsRobot &&
          'Non-cyborgs cannot use the docking station functions.') ||
          ''}
        {(viewerIsOccupant &&
          !allowSelfService &&
          'Self-service has been disabled at this station.') ||
          ''}
      </Box>
      <Divider />
    </>
  );
};
