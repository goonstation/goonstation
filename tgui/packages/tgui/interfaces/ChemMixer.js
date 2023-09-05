import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';
import { RoundGauge, Button, LabeledList, Divider } from '../components';

export const ChemMixer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    connected,
    on,
    pressure,
    maxPressure,
    speed,
  } = data;
  return (
    <Window
      width={305}
      height={245}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure} >
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Speed">
              <RoundGauge
                size={1.75}
                value={speed}
                minValue={1}
                maxValue={3}
                alertAfter={2.5}
                ranges={{
                  "good": [1, 2],
                  "average": [2, 2.5],
                  "bad": [2.5, 3],
                }}
                format={(value) => Math.round(value * 100)/100 + "x"}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                content={on ? 'On' : 'Off'}
                color={on ? 'average' : 'default'}
                onClick={() => act("toggle-power")} />
            </LabeledList.Item>
          </LabeledList>
        </PortableBasicInfo>
      </Window.Content>
    </Window>
  );
};
