/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { useBackend } from '../../backend';
import {
  Box,
  Divider,
  LabeledList,
  Section,
} from '../../components';
import { WireList } from './WireList';
import type { ApcData } from './types';

export const AccessPanelSection = (_props, context) => {
  const { data } = useBackend<ApcData>(context);
  const {
    net_id,
    locked,
    shorted,
    aidisabled,
  } = data;

  return (
    <Section title="Access Panel">
      <Box>
        {'An identifier is engraved above the APC\'s wires:'} <Box inline italic>{net_id}</Box>
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
        <LabeledList.Item label="AI Control" color={aidisabled ? 'red' : 'green'}>
          {aidisabled ? 'Disabled' : 'Enabled'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
