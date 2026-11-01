/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { Box, Divider, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { ApcData } from './types';
import { WireList } from './WireList';

export const AccessPanelSection = (_props: unknown) => {
  const { data } = useBackend<ApcData>();
  const { net_id, locked, shorted, aidisabled } = data;

  return (
    <Section title="Access Panel">
      <Box>
        {"An identifier is engraved above the APC's wires: "}
        <Box inline italic>
          {net_id}
        </Box>
      </Box>
      <Divider />
      <WireList />
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Controls" color={locked ? 'green' : 'red'}>
          {locked ? 'Locked' : 'Unlocked'}
        </LabeledList.Item>
        <LabeledList.Item label="Circuitry" color={shorted ? 'red' : 'green'}>
          {shorted ? 'Shorted' : 'Working'}
        </LabeledList.Item>
        <LabeledList.Item
          label="AI Control"
          color={aidisabled ? 'red' : 'green'}
        >
          {aidisabled ? 'Disabled' : 'Enabled'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
