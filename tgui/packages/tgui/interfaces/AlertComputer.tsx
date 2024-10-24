import { Button, LabeledList } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface AlertComputerData {
  alerts: Partial<Record<string, AlertData>>;
}

interface AlertData {
  area_name: string;
  area_ckey: string;
  atmos: string | null;
  fire: string | null;
  power: string | null;
}

export const AlertComputer = () => {
  const { data } = useBackend<AlertComputerData>();
  const { alerts } = data;
  return (
    <Window title="Current Engineering Alerts" width={450} height={420}>
      <Window.Content scrollable>
        <LabeledList>
          {Object.keys(alerts).length === 0 && (
            <LabeledList.Item>No alerts detected.</LabeledList.Item>
          )}
          {Object.keys(alerts).length > 0 &&
            Object.values(alerts).map((value, index) => {
              return (
                <LabeledList.Item key={index} label={value?.area_name}>
                  {value && <AlertButtonRow alert={value} />}
                </LabeledList.Item>
              );
            })}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};

interface AlertButtonRowProps {
  alert: AlertData;
}

const AlertButtonRow = (props: AlertButtonRowProps) => {
  const { alert } = props;
  return (
    <>
      <AlertButton
        area_ckey={alert.area_ckey}
        kind="atmos"
        severity={alert.atmos}
      />
      <AlertButton
        area_ckey={alert.area_ckey}
        kind="fire"
        severity={alert.fire}
      />
      <AlertButton
        area_ckey={alert.area_ckey}
        kind="power"
        severity={alert.power}
      />
    </>
  );
};

interface AlertButtonProps {
  area_ckey: string;
  kind: string;
  severity: string | null;
}

const AlertButton = (props: AlertButtonProps) => {
  const { act } = useBackend();
  const { area_ckey, kind, severity } = props;
  return (
    <Button
      width="78px"
      icon={AlertButtonIcon(kind)}
      backgroundColor={AlertButtonColor(severity)}
      onClick={() => act(`clear_${kind}`, { area_ckey: area_ckey })}
      tooltip={AlertButtonTooltip(kind)}
    >
      {AlertButtonText(severity)}
    </Button>
  );
};

const AlertButtonIcon = (kind: string): string => {
  switch (kind) {
    case 'atmos':
      return 'wind';
    case 'fire':
      return 'fire';
    case 'power':
      return 'bolt';
    default:
      return '';
  }
};

const AlertButtonColor = (severity: string | null): string => {
  switch (severity) {
    case 'priority':
      return 'bad';
    case 'minor':
      return 'average';
    default:
      return 'good';
  }
};

const AlertButtonText = (severity: string | null): string => {
  switch (severity) {
    case 'priority':
      return 'Priority';
    case 'minor':
      return 'Minor';
    default:
      return 'Okay';
  }
};

const AlertButtonTooltip = (kind: string): string => {
  switch (kind) {
    case 'atmos':
      return 'Atmospheric';
    case 'fire':
      return 'Fire';
    case 'power':
      return 'Power';
    default:
      return '';
  }
};
