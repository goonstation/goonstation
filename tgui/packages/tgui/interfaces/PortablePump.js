import { useBackend } from '../backend';
import { Flex, Section, Button, NumberInput, LabeledList, Divider } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';

export const PortablePump = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    on,
    direction_out,
    holding,
    pressure,
    targetPressure,
    maxPressure,
    minRelease,
    maxRelease,
  } = data;

  const handleTogglePower = () => {
    act("toggle-power");
  };

  const handleEjectTank = () => {
    act("eject-tank");
  };

  const handleToggleDirection = () => {
    act("toggle-pump");
  };

  const handleSetPressure = targetPressure => {
    act("set-pressure", {
      targetPressure,
    });
  };

  return (
    <Window
      width={305}
      height={365}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}>
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Pump Power">
              <Button
                content={on ? 'On' : 'Off'}
                color={on ? 'green' : 'red'}
                onClick={handleTogglePower} />
            </LabeledList.Item>
            <LabeledList.Item label="Target Pressure">
              <Button
                onClick={() => handleSetPressure(minRelease)}
                content="Min" />
              <NumberInput
                animated
                width="7em"
                value={targetPressure}
                minValue={minRelease}
                maxValue={maxRelease}
                onChange={(e, newTargetPressure) => handleSetPressure(newTargetPressure)} />
              <Button
                onClick={() => handleSetPressure(maxRelease)}
                content="Max" />
            </LabeledList.Item>
            <LabeledList.Item label="Pump Direction">
              <Button
                content={direction_out ? 'Out' : 'In'}
                color={direction_out ? 'yellow' : 'blue'}
                onClick={handleToggleDirection} />
            </LabeledList.Item>
          </LabeledList>
        </PortableBasicInfo>
        <PortableHoldingTank
          holding={holding}
          onEjectTank={handleEjectTank} />
      </Window.Content>
    </Window>
  );

};
