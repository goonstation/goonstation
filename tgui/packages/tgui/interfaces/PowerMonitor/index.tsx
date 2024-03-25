/**
 * @file
 * @copyright 2021
 * @author Luxizzle (https://github.com/Luxizzle)
 * @license MIT
 */

import { useBackend, useSharedState } from '../../backend';
import { Input, LabeledList, Section, Stack, Table } from '../../components';
import { Window } from '../../layouts';
import { SortDirection } from '../common/sorting/constant';
import { PowerMonitorApcGlobal, PowerMonitorApcTableHeader, PowerMonitorApcTableRows } from './Apc';
import { PowerMonitorSmesGlobal, PowerMonitorSmesTableHeader, PowerMonitorSmesTableRows } from './Smes';
import { ApcTableHeaderColumns, ApcTableHeaderColumnSortState, isDataForApc, isDataForSmes, PowerMonitorData, SmesTableHeaderColumns, SmesTableHeaderColumnSortState } from './type';

export const PowerMonitor = (_props, context) => {
  const { data } = useBackend<PowerMonitorData>(context);
  const [search, setSearch] = useSharedState(context, 'search', '');
  const [apcSortBy, apcSetSortBy] = useSharedState<ApcTableHeaderColumnSortState>(context, 'apcSortBy', null);
  const [smesSortBy, smesSetSortBy] = useSharedState<SmesTableHeaderColumnSortState>(context, 'smesSortBy', null);

  const onSetApcHeaderSort = (field: ApcTableHeaderColumns, current: ApcTableHeaderColumnSortState) => {
    if (current !== null) {
      if (current.field === field) {
        let newState = {
          dir: (current.dir === SortDirection.Asc ? SortDirection.Desc : SortDirection.Asc),
          field: field,
        };

        apcSetSortBy(newState);
      } else {
        let newState = {
          dir: current.dir,
          field: field,
        };

        apcSetSortBy(newState);

      }
    } else {
      let newState = {
        dir: SortDirection.Asc,
        field: field,
      };
      apcSetSortBy(newState);
    }
  };

  const onSetSmesHeaderSort = (field: SmesTableHeaderColumns, current: SmesTableHeaderColumnSortState) => {
    if (current !== null) {
      if (current.field === field) {
        let newState = {
          dir: (current.dir === SortDirection.Asc ? SortDirection.Desc : SortDirection.Asc),
          field: field,
        };

        smesSetSortBy(newState);
      } else {
        let newState = {
          dir: current.dir,
          field: field,
        };

        smesSetSortBy(newState);
      }
    } else {
      let newState = {
        dir: SortDirection.Asc,
        field: field,
      };
      smesSetSortBy(newState);
    }
  };

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
                <Table.Row header>
                  {
                    isDataForApc(data)
                    && <PowerMonitorApcTableHeader
                      state={apcSortBy}
                      setSortBy={(field) => onSetApcHeaderSort(field, apcSortBy)} />
                  }
                </Table.Row>
                {isDataForApc(data) && <PowerMonitorApcTableRows sortState={apcSortBy} search={search} />}

                <Table.Row header>
                  {
                    isDataForSmes(data)
                    && <PowerMonitorSmesTableHeader
                      state={smesSortBy}
                      setSortBy={(field) => onSetSmesHeaderSort(field, smesSortBy)} />
                  }
                </Table.Row>
                {isDataForSmes(data) && <PowerMonitorSmesTableRows sortState={smesSortBy} search={search} />}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
