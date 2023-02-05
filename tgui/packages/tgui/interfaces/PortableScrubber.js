import { useBackend } from '../backend';
import { Button, NumberInput, LabeledList, Divider, Section } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReagentGraph } from './common/ReagentInfo';

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
    reagent_container,
  } = data;

  return (
    <Window
      width={305}
      height={450}>
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
        <Section title="Fluid Tank">
          <ReagentGraph container={reagent_container} />
        </Section>
      </Window.Content>
    </Window>
  );

};
