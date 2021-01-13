/**
 * Copyright (c) 2020 @actioninja
 * Minor changes by Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const TankDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={280} height={105}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Plasma"
              buttons={(
                <Button
                  icon={data.plasma ? 'circle' : 'circle-o'}
                  content="Dispense"
                  disabled={!data.plasma}
                  onClick={() => act('dispense-plasma')} />
              )}>
              {data.plasma}
            </LabeledList.Item>
            <LabeledList.Item
              label="Oxygen"
              buttons={(
                <Button
                  icon={data.oxygen ? 'circle' : 'circle-o'}
                  content="Dispense"
                  disabled={!data.oxygen}
                  onClick={() => act('dispense-oxygen')} />
              )}>
              {data.oxygen}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
