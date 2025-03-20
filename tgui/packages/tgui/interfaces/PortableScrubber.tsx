/**
 * @file
 * @copyright 2022
 * @author cringe (https://github.com/Laboredih123)
 * @license MIT
 */

import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { PortableBasicInfo, PortableHoldingTank } from './common/PortableAtmos';
import { ReagentGraph } from './common/ReagentInfo';

interface PortableScrubberData {
  connected;
  on;
  holding;
  inletFlow;
  pressure;
  maxPressure;
  maxFlow;
  minFlow;
  reagent_container;
}

export const PortableScrubber = () => {
  const { act, data } = useBackend<PortableScrubberData>();

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
    <Window width={305} height={450}>
      <Window.Content>
        <PortableBasicInfo
          connected={connected}
          pressure={pressure}
          maxPressure={maxPressure}
        >
          <LabeledList>
            <LabeledList.Item label="Scrubber Power">
              <Button
                color={on ? 'average' : 'default'}
                onClick={() => act('toggle-power')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Inlet Flow">
              <Button
                onClick={() => act('set-inlet-flow', { inletFlow: minFlow })}
              >
                Min
              </Button>
              <NumberInput
                animated
                width="7em"
                value={inletFlow}
                minValue={minFlow}
                maxValue={maxFlow}
                step={1}
                onChange={(newInletFlow) =>
                  act('set-inlet-flow', { inletFlow: newInletFlow })
                }
              />
              <Button
                onClick={() => act('set-inlet-flow', { inletFlow: maxFlow })}
              >
                Max
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </PortableBasicInfo>
        <PortableHoldingTank
          holding={holding}
          onEjectTank={() => act('eject-tank')}
        />
        <Section title="Fluid Tank">
          <ReagentGraph container={reagent_container} />
        </Section>
      </Window.Content>
    </Window>
  );
};
