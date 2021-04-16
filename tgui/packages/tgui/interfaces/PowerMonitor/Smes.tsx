import { useBackend, useSharedState } from '../../backend';
import { LabeledList, Table } from '../../components';
import { formatPower } from '../../format';
import { PowerMonitorSmesData, PowerMonitorSmesItemData } from './type';


export const PowerMonitorSmesGlobal = (_props, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);

  return (
    <LabeledList>
      <LabeledList.Item label="Engine Output">{formatPower(data.available)}</LabeledList.Item>
      <LabeledList.Item label="SMES/PTL Draw">{formatPower(data.load)}</LabeledList.Item>
    </LabeledList>
  );
};

export const PowerMonitorSmesTableHeader = (props, context) => {
  return (
    <>
      <Table.Cell header>Area</Table.Cell>
      <Table.Cell header>Stored Power</Table.Cell>
      <Table.Cell header>Charging</Table.Cell>
      <Table.Cell header>Input</Table.Cell>
      <Table.Cell header>Output</Table.Cell>
      <Table.Cell header>Active</Table.Cell>
      <Table.Cell header>Load</Table.Cell>
    </>
  );
};

export const PowerMonitorSmesTableRows = (props, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);

  return (
    <>
      {data.units.map((unit) => (
        <PowerMonitorSmesTableRow key={unit.ref} unit={unit} />
      ))}
    </>
  );
};

type PowerMonitorSmesTableRowProps = {
  unit: PowerMonitorSmesItemData;
};

const PowerMonitorSmesTableRow = ({ unit }: PowerMonitorSmesTableRowProps, context) => {
  const { data } = useBackend<PowerMonitorSmesData>(context);
  const [search] = useSharedState(context, 'search', '');
  const { name = 'N/A' } = data.unitsStatic[unit.ref] ?? {};

  if (search && !name.toLowerCase().includes(search.toLowerCase())) {
    return null;
  }

  return (
    <Table.Row >
      <Table.Cell>{name}</Table.Cell>
      <Table.Cell>{unit.stored}%</Table.Cell>
      <Table.Cell color={unit.charging ? 'good' : 'bad'}>{unit.charging ? 'Yes' : 'No'}</Table.Cell>
      <Table.Cell>{formatPower(unit.input)}</Table.Cell>
      <Table.Cell>{formatPower(unit.output)}</Table.Cell>
      <Table.Cell color={unit.online ? 'good' : 'bad'}>{unit.online ? 'Yes' : 'No'}</Table.Cell>
      <Table.Cell>{unit.load ? formatPower(unit.load) : 'N/A'}</Table.Cell>
    </Table.Row>
  );
};
