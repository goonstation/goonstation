import { useBackend } from '../backend';
import { Flex, Section, Button, NumberInput, LabeledList, Divider } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    connected,
    on,
    holding,
    pressure,
    inletFlow,
    maxPressure,
    minFlow,
    maxFlow,
  } = data;

  return (
    <Window
      width={305}
      height={340}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}>
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Scrubber Power">
              <Button
                content={on ? 'On' : 'Off'}
                color={on ? 'average' : 'default'}
                onClick={() => act("toggle-power")} />
            </LabeledList.Item>
            <LabeledList.Item label="Inlet Flow">
              <Button
                onClick={() => act("set-inlet-flow", { inletFlow: minFlow })}
                content="Min" />
              <NumberInput
                animated
                width="7em"
                value={inletFlow}
                minValue={minFlow}
                maxValue={maxFlow}
                onChange={(e, newInletFlow) => act("set-inlet-flow", { inletFlow: newInletFlow })} />
              <Button
                onClick={() => act("set-inlet-flow", { inletFlow: maxFlow })}
                content="Max" />
            </LabeledList.Item>
          </LabeledList>
        </PortableBasicInfo>
        <PortableHoldingTank
          holding={holding}
          onEjectTank={() => act("eject-tank")} />
      </Window.Content>
    </Window>
  );

};
