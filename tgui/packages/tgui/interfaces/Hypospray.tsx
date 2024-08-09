/**
 * @file
 * @copyright 2022
 * @author CodeJester (https://github.com/codeJester27)
 * @license ISC
 */

import { Button, Section, Slider } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ReagentGraph, ReagentList } from './common/ReagentInfo';
import { glitch } from './common/stringUtils';

interface HyposprayData {
  emagged;
  injectionAmount;
  reagentData;
}

export const Hypospray = () => {
  const { act, data } = useBackend<HyposprayData>();
  const { emagged, injectionAmount, reagentData } = data;

  return (
    <Window
      width={320}
      height={300}
      theme={emagged ? 'syndicate' : 'nanotrasen'}
    >
      <Window.Content>
        <Section
          title={emagged ? glitch('Contents', 3) : 'Contents'}
          buttons={
            <Button
              icon="times"
              color="red"
              disabled={!reagentData.totalVolume}
              onClick={() => act('dump')}
            >
              Dump
            </Button>
          }
        >
          <ReagentGraph container={reagentData} />
          <ReagentList container={reagentData} />
        </Section>
        <Section title="Injection Amount">
          <Slider
            value={injectionAmount}
            format={(value) => value + 'u'}
            minValue={1}
            maxValue={reagentData.maxVolume}
            step={1}
            stepPixelSize={10}
            onChange={(e, value) => act('changeAmount', { amount: value })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
