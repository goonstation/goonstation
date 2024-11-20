import { Icon, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface AlertComputerData {
  alerts: AlertData[];
}

interface AlertData {
  zone: string;
  area_ckey: string;
  atmos: number;
  fire: number;
  power: number;
  motion: number;
}

export const AlertComputer = () => {
  const { data } = useBackend<AlertComputerData>();
  const { alerts } = data;
  return (
    <Window title="Current Alerts" width={600} height={420}>
      <Window.Content scrollable>
        <Table>
          <Table.Row header className="candystripe">
            <Table.Cell header>Area</Table.Cell>
            <Table.Cell header width="100px">
              <Icon name="wind" mr="5px" />
              Air
            </Table.Cell>
            <Table.Cell header collapsing width="100px">
              <Icon name="fire" mr="5px" />
              Fire
            </Table.Cell>
            <Table.Cell header collapsing width="100px">
              <Icon name="bolt" mr="5px" />
              Power
            </Table.Cell>
          </Table.Row>
          {alerts.map((alert) => {
            return <AlertRow key={alert.area_ckey} alert={alert} />;
          })}
        </Table>
      </Window.Content>
    </Window>
  );
};

interface AlertRowProps {
  alert: AlertData;
}

const AlertRow = (props: AlertRowProps) => {
  const { alert } = props;
  return (
    <Table.Row className="candystripe">
      <Table.Cell verticalAlign="middle">{alert.zone}</Table.Cell>
      <Table.Cell textColor={getAlertButtonColor(alert.atmos)}>
        {getAlertButtonText(alert.atmos)}
      </Table.Cell>
      <Table.Cell textColor={getAlertButtonColor(alert.fire)}>
        {getAlertButtonText(alert.fire)}
      </Table.Cell>
      <Table.Cell textColor={getAlertButtonColor(alert.power)}>
        {getAlertButtonText(alert.power)}
      </Table.Cell>
    </Table.Row>
  );
};

const getAlertButtonColor = (severity: number | null) => {
  switch (severity) {
    case 1:
      return 'average';
    case 2:
      return 'bad';
    default:
      return 'good';
  }
};

const getAlertButtonText = (severity: number | null) => {
  switch (severity) {
    case 1:
      return 'Minor';
    case 2:
      return 'Priority';
    default:
      return 'Okay';
  }
};
