/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface PacketInfo {
  packet_stamps;
  packet_data;
  filter;
}

export const PacketSniffer = () => {
  const { act, data } = useBackend<PacketInfo>();
  const { packet_stamps, packet_data, filter } = data;
  return (
    <Window title="Packet Sniffer" width={500} height={400} theme="hackerman">
      <Window.Content>
        <Section
          title="Packet Log"
          fill
          scrollable
          buttons={
            <Button onClick={() => act('set_filter')}>
              Sender filter: {filter ? filter : 'None'}
            </Button>
          }
        >
          <LabeledList>
            {packet_stamps && packet_stamps.length
              ? packet_stamps.map((item, index) => (
                  <LabeledList.Item key={index} label={item}>
                    {packet_data[index]}
                  </LabeledList.Item>
                ))
              : 'No packets received'}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
