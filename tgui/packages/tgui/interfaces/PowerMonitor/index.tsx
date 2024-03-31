/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend, useSharedState } from '../../backend';
import { Input, LabeledList, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { ApcPowerMonitor, PowerMonitorApcGlobal } from './Apc';
import { PowerMonitorSmesGlobal, SmesPowerMonitor } from './Smes';
import { ApcTableHeaderColumns, isDataForApc, isDataForSmes, PowerMonitorData, SingleSortState, SmesTableHeaderColumns } from './type';
import { OnSetSortState } from './utils';

export const PowerMonitor = (_props, context) => {
  const { data } = useBackend<PowerMonitorData>(context);
  const [search, setSearch] = useSharedState(context, 'search', '');
  const [apcSortState, apcSetSortBy] = useSharedState<SingleSortState<ApcTableHeaderColumns>>(context, 'apcSortBy', null);
  const [smesSortState, smesSetSortBy] = useSharedState<SingleSortState<SmesTableHeaderColumns>>(context, 'smesSortBy', null);

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
                {isDataForApc(data)
                && <ApcPowerMonitor
                  search={search}
                  sortState={apcSortState}
                  setSortBy={(field) => OnSetSortState(field, apcSortState, apcSetSortBy)} /> }
                {isDataForSmes(data)
                && <SmesPowerMonitor
                  search={search}
                  sortState={smesSortState}
                  setSortBy={(field) => OnSetSortState(field, smesSortState, smesSetSortBy)} />}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
