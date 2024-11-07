import { Button, Flex, Icon, Table } from 'tgui-core/components';

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
          <Table.Row header fontSize="1.1em" className="candystripe">
            <Table.Cell header width="200px">
              Area
            </Table.Cell>
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
          {Object.values(alerts).map((value, index) => {
            return <AlertRow key={index} alert={value} />;
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
      <AlertCell
        area_ckey={alert.area_ckey}
        kind="atmos"
        severity={alert.atmos}
      />
      <AlertCell
        area_ckey={alert.area_ckey}
        kind="fire"
        severity={alert.fire}
      />
      <AlertCell
        area_ckey={alert.area_ckey}
        kind="power"
        severity={alert.power}
      />
    </Table.Row>
  );
};

interface AlertCellProps {
  area_ckey: string;
  kind: string;
  severity: number | null;
}

const AlertCell = (props: AlertCellProps) => {
  const { act } = useBackend();
  const { area_ckey, kind, severity } = props;
  return (
    <Table.Cell textColor={AlertButtonColor(severity)}>
      <Flex>
        <Flex.Item>
          <Button
            icon="bell-slash"
            disabled={severity === 0}
            onClick={() => act(`clear_${kind}`, { area_ckey: area_ckey })}
            tooltip="Reset alarm"
            mr="5px"
          />
        </Flex.Item>
        <Flex.Item>{AlertButtonText(severity)}</Flex.Item>
      </Flex>
    </Table.Cell>
  );
};

const AlertButtonColor = (severity: number | null): string => {
  switch (severity) {
    case 1:
      return 'average';
    case 2:
      return 'bad';
    default:
      return 'good';
  }
};

const AlertButtonText = (severity: number | null): string => {
  switch (severity) {
    case 1:
      return 'Minor';
    case 2:
      return 'Priority';
    default:
      return 'Okay';
  }
};
