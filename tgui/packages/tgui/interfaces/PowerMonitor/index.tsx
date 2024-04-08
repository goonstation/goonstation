/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend, useSharedState } from '../../backend';
import { Input, LabeledList, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { SortableTable } from '../common/sorting';

import { apcHeaderConfig, getRowDataForApcs, PowerMonitorApcGlobal } from './Apc';
import { getRowDataForSmes, PowerMonitorSmesGlobal, smesHeaderConfig } from './Smes';
import { PowerMonitorApcData, PowerMonitorData, PowerMonitorSmesData, PowerMonitorType } from './type';

const isDataForApc = (data: PowerMonitorData):
  data is PowerMonitorApcData =>
  data.type === PowerMonitorType.Apc;
const isDataForSmes = (data: PowerMonitorData):
  data is PowerMonitorSmesData =>
  data.type === PowerMonitorType.Smes;

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
              {isDataForApc(data)
                && <SortableTable
                  name="apcPowerMonitor"
                  useLocalState={false}
                  headerConfig={apcHeaderConfig}
                  rowData={getRowDataForApcs(data.apcs, data.apcNames)}
                  searchState={{ text: search, index: 0 }} />}

              {isDataForSmes(data)
                && <SortableTable
                  name="smesPowerMonitor"
                  useLocalState={false}
                  headerConfig={smesHeaderConfig}
                  rowData={getRowDataForSmes(data.units, data.unitNames)}
                  searchState={{ text: search, index: 0 }} />}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
