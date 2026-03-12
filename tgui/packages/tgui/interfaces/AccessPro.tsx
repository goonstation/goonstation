/**
 * @file
 * @copyright 2025
 * @author JORJ949 (https://github.com/JORJ949)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { AccessByArea, DeptBox } from '../interfaces/IDComputer';
import { Window } from '../layouts';

interface AccessProData {
  mode: BooleanLike; // 0 when all accesses needed, true when any
  selected_accesses: number[];
  accesses_by_area: AccessByArea[];
}

export const AccessPro = () => {
  const { act, data } = useBackend<AccessProData>();
  const { selected_accesses, accesses_by_area, mode } = data;
  return (
    <Window width={600} height={800}>
      <Window.Content scrollable>
        <Section title="Settings">
          <Button onClick={() => act('change_mode')}>
            {mode ? 'Current Mode: OR' : 'Current Mode: AND'}
          </Button>
        </Section>
        <Section title="Accesses">
          {accesses_by_area.map(
            (area) =>
              area.accesses.length > 0 && (
                <DeptBox
                  key={area.name}
                  name={area.name}
                  colour={area.color}
                  accesses={area.accesses}
                  target_accesses={selected_accesses}
                />
              ),
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
