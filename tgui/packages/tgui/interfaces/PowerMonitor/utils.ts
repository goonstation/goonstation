import { sortTypedArrayByIndex } from "../common/comparators";
import { SortDirection } from "../common/sorting/type";
import { ApcTableHeaderColumns, PowerMonitorColumnUnion, SingleSortState, SmesTableHeaderColumns } from "./type";

export const SortPowerMonitorData
  = <MonitorType extends Array<unknown>, FieldType extends PowerMonitorColumnUnion>(data: MonitorType[],
    names: Record<string, string>,
    sortState: SingleSortState<FieldType>): MonitorType[] => {

    if (sortState !== null) {
      let sortedData: MonitorType[];
      if (sortState.field === ApcTableHeaderColumns.Area
          || sortState.field === SmesTableHeaderColumns.Area) {
        sortedData = sortTypedArrayByIndex([...data], sortState.field, names);
      }
      else {
        sortedData = sortTypedArrayByIndex([...data], sortState.field);
      }

      if (sortState.dir === SortDirection.Asc) {
        sortedData.reverse();
      }

      return sortedData;
    }

    return data;
  };

export const OnSetSortState = <FieldType>(
  field: FieldType,
  current: SingleSortState<FieldType>,
  setFunc: (nextState: SingleSortState<FieldType>) => void) => {
  if (current !== null) {
    if (current.field === field) {
      setFunc({
        dir: (current.dir === SortDirection.Asc ? SortDirection.Desc : SortDirection.Asc),
        field: field,
      });
    } else {
      setFunc({ dir: SortDirection.Asc, field: field });
    }
  } else {
    setFunc({ dir: SortDirection.Asc, field: field });
  }
};
