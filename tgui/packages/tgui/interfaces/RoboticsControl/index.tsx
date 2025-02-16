/**
 * @file
 * @copyright 2025
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AIStatuses } from './AiStatuses';
import { CyborgStatuses } from './CyborgStatuses';
import { GhostdroneStatuses } from './GhostdroneStatuses';
import type { RoboticsControlData } from './type';

export const RoboticsControl = () => {
  const { data } = useBackend<RoboticsControlData>();
  const { user_is_ai, user_is_cyborg, ais, cyborgs, ghostdrones } = data;

  return (
    <Window title="Robotics Control" width={870} height={590}>
      <Window.Content>
        <Section fill scrollable>
          <Section title="Located AI Units">
            {ais?.length ? (
              <AIStatuses
                ais={ais}
                user_is_robot={!!(user_is_ai || user_is_cyborg)}
              />
            ) : (
              'No AI units located'
            )}
          </Section>
          <Section title="Located Cyborgs">
            {cyborgs?.length ? (
              <CyborgStatuses
                cyborgs={cyborgs}
                user_is_ai={user_is_ai}
                user_is_cyborg={user_is_cyborg}
              />
            ) : (
              'No cyborgs located'
            )}
          </Section>
          <Section title="Ghostdrones">
            {ghostdrones?.length ? (
              <GhostdroneStatuses ghostdrones={ghostdrones} />
            ) : (
              'No ghostdrones located'
            )}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
