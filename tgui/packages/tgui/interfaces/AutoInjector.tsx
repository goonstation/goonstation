/**
 * @file
 * @copyright 2022
 * @author Garash (https://github.com/Garash2k)
 * @license ISC
 */

import { Box, Button, Dropdown, Section, Slider } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ReagentGraph, ReagentList } from './common/ReagentInfo';

interface AutoInjectorData {
  condition;
  conditionDamage;
  conditionTreshold;
  conditions;
  injectionAmount;
  minimumTime;
  reagentData;
}

export const AutoInjector = () => {
  const { act, data } = useBackend<AutoInjectorData>();
  const {
    injectionAmount,
    reagentData,
    minimumTime,
    condition,
    conditionTreshold,
    conditionDamage,
    conditions,
  } = data;

  return (
    <Window width={360} height={520}>
      <Window.Content>
        <Section
          title={'Contents'}
          buttons={
            <Button
              tooltip="Eject"
              icon="eject"
              disabled={!reagentData}
              onClick={() => act('remove_cont')}
            >
              Eject
            </Button>
          }
        >
          {reagentData ? (
            <>
              <ReagentGraph container={reagentData} />
              <ReagentList container={reagentData} />
            </>
          ) : (
            'Please attach a beaker'
          )}
        </Section>

        <Section title={'Condition'}>
          <Dropdown
            options={conditions}
            selected={condition ? condition.name : 'None'}
            onSelected={(value) => act('sel_cond', { condition: value })}
            width="130px"
          />
          {conditionTreshold ? (
            <>
              {conditionDamage ? (
                <Dropdown
                  options={['brute', 'burn', 'toxin', 'oxygen']}
                  selected={conditionDamage.damagetype}
                  onSelected={(value) =>
                    act('sel_damage_type', { damagetype: value })
                  }
                  width="75px"
                  mt="0.5rem"
                />
              ) : null}
              <Slider
                value={conditionTreshold.currentValue}
                format={(value) => value + conditionTreshold.suffix}
                minValue={conditionTreshold.minValue}
                maxValue={conditionTreshold.maxValue}
                step={1}
                onChange={(e, value) =>
                  act('changeConditionValue', { conditionValue: value })
                }
                mt="0.5rem"
              />
            </>
          ) : null}
          {condition ? <Box mt="0.5rem">{condition.desc}</Box> : null}
        </Section>

        {reagentData ? (
          <Section title="Injection Amount">
            <Slider
              value={injectionAmount}
              format={(value) => value + 'u'}
              minValue={1}
              maxValue={reagentData.maxVolume}
              step={1}
              onChange={(e, value) => act('changeAmount', { amount: value })}
            />
          </Section>
        ) : null}

        <Section title="Min. time between activations">
          <Slider
            value={minimumTime}
            format={(value) => value + ' seconds'}
            minValue={3}
            maxValue={300}
            step={1}
            onChange={(e, value) => act('changeMintime', { mintime: value })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
