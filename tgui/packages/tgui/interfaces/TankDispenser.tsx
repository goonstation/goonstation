/**
 * Copyright (c) 2020 @actioninja
 * Minor changes by Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface TankDispenserData {
  oxygen;
  plasma;
}

export const TankDispenser = () => {
  const { act, data } = useBackend<TankDispenserData>();
  return (
    <Window width={280} height={105}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Plasma"
              buttons={
                <Button
                  icon={data.plasma ? 'circle' : 'circle-o'}
                  disabled={!data.plasma}
                  onClick={() => act('dispense-plasma')}
                >
                  Dispense
                </Button>
              }
            >
              {data.plasma}
            </LabeledList.Item>
            <LabeledList.Item
              label="Oxygen"
              buttons={
                <Button
                  icon={data.oxygen ? 'circle' : 'circle-o'}
                  disabled={!data.oxygen}
                  onClick={() => act('dispense-oxygen')}
                >
                  Dispense
                </Button>
              }
            >
              {data.oxygen}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
