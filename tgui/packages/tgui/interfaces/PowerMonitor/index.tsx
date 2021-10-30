/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend, useSharedState } from '../../backend';
import { Input, LabeledList, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { PowerMonitorApcGlobal, PowerMonitorApcTableHeader, PowerMonitorApcTableRows } from './Apc';
import { PowerMonitorSmesGlobal, PowerMonitorSmesTableHeader, PowerMonitorSmesTableRows } from './Smes';
import { isDataForApc, isDataForSmes, PowerMonitorData } from './type';

export const PowerMonitor = (_props, context) => {
  const { data } = useBackend<PowerMonitorData>(context);
  const [search, setSearch] = useSharedState(context, 'search', '');

  return (
    <Window width={700} height={700} theme="retro-dark">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              {isDataForApc(data) && <PowerMonitorApcGlobal />}
              {isDataForSmes(data) && <PowerMonitorSmesGlobal />}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Search">
                  <Input value={search} onInput={(e, value) => setSearch(value)} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item grow={1}>
            <Section fill scrollable>
              <Table>
                <Table.Row header>{isDataForApc(data) && <PowerMonitorApcTableHeader />}</Table.Row>
                {isDataForApc(data) && <PowerMonitorApcTableRows search={search} />}

                <Table.Row header>{isDataForSmes(data) && <PowerMonitorSmesTableHeader />}</Table.Row>
                {isDataForSmes(data) && <PowerMonitorSmesTableRows search={search} />}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
