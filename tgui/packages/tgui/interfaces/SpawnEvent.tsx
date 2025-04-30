import {
  Button,
  LabeledList,
  NumberInput,
  Section,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SpawnEventData {
  thing_to_spawn;
  thing_name;
  spawn_directly;
  spawn_loc;
  ghost_confirmation_delay;
  amount_to_spawn;
  antag_role;
  objective_text;
  spawn_type;
  loc_type;
  incompatible_antag;
  equip_antag;
  ask_permission;
  allow_dnr;
  eligible_player_count;
  add_to_manifest;
}

export const SpawnEvent = () => {
  const { act, data } = useBackend<SpawnEventData>();
  const {
    thing_to_spawn,
    thing_name,
    spawn_directly,
    spawn_loc,
    ghost_confirmation_delay,
    amount_to_spawn,
    antag_role,
    objective_text,
    spawn_type,
    loc_type,
    incompatible_antag,
    equip_antag,
    ask_permission,
    allow_dnr,
    eligible_player_count,
    add_to_manifest,
  } = data;
  return (
    <Window title="Ghost Spawn Editor" width={500} height={360}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Thing to spawn">
              <Button
                selected={thing_name && spawn_type === 'mob_ref'}
                onClick={() => act('select_mob')}
                tooltip={
                  spawn_type === 'mob_ref' && thing_name ? thing_to_spawn : ''
                }
              >
                {spawn_type === 'mob_ref' ? thing_name : 'Mob ref'}
              </Button>
              <Button
                selected={thing_name && spawn_type === 'mob_type'}
                onClick={() => act('select_mob_type')}
                tooltip={
                  spawn_type === 'mob_type' && thing_name ? thing_to_spawn : ''
                }
              >
                {spawn_type === 'mob_type' ? thing_name : 'Mob type'}
              </Button>
              <Button
                selected={thing_name && spawn_type === 'job'}
                onClick={() => act('select_job')}
                tooltip={
                  spawn_type === 'job' && thing_name ? thing_to_spawn : ''
                }
              >
                {spawn_type === 'job' ? thing_name : 'Job'}
              </Button>
              <Button
                selected={spawn_type === 'random_human'}
                onClick={() => act('set_random_human')}
                tooltip={'Just a basic random human.'}
              >
                Random Human
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Accept delay">
              {!!ask_permission && (
                <NumberInput
                  value={ghost_confirmation_delay / 10}
                  minValue={0}
                  maxValue={120}
                  step={1}
                  onDrag={(spawn_delay) =>
                    act('set_spawn_delay', { spawn_delay: spawn_delay * 10 })
                  }
                  disabled={!ask_permission}
                />
              )}
              <Button.Checkbox
                checked={ask_permission}
                onClick={() =>
                  act('set_ask_permission', { ask_permission: !ask_permission })
                }
                tooltip="Do we ask permission or just spawn them directly?"
              >
                Ask permission.
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label="Amount to spawn">
              <NumberInput
                value={amount_to_spawn}
                minValue={1}
                maxValue={100}
                step={1}
                onDrag={(amount) => act('set_amount', { amount })}
              />
              {`/${eligible_player_count} `}
              <Button
                icon="refresh"
                onClick={() => act('refresh_player_count')}
              />
              {amount_to_spawn === 1 &&
                spawn_type === 'mob_ref' &&
                thing_name && (
                  <Button.Checkbox
                    checked={spawn_directly}
                    onClick={() =>
                      act('set_spawn_directly', {
                        spawn_directly: !spawn_directly,
                      })
                    }
                    tooltip="Puts the ghost mind directly into the original mob instead of copying it."
                  >
                    Spawn as original
                  </Button.Checkbox>
                )}
            </LabeledList.Item>
            <LabeledList.Item label="Spawn location">
              <Button
                disabled={spawn_directly}
                selected={spawn_loc && loc_type === 'turf_ref'}
                onClick={() => act('select_turf')}
              >
                {loc_type === 'turf_ref' ? spawn_loc : 'Turf ref'}
              </Button>
              <Button
                disabled={spawn_directly}
                selected={spawn_loc && loc_type === 'landmark'}
                onClick={() => act('select_landmark')}
              >
                {loc_type === 'landmark' ? spawn_loc : 'Landmark'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Antagonist status">
              <Button selected={antag_role} onClick={() => act('select_antag')}>
                {antag_role || 'Antag role'}
              </Button>
              {antag_role && (
                <>
                  <Button color="red" onClick={() => act('clear_antag')}>
                    x
                  </Button>
                  <Button.Checkbox
                    checked={equip_antag}
                    tooltip="Give antag default equipment and abilities? Will overwrite anything already equipped in those slots."
                    onClick={() =>
                      act('set_equip', { equip_antag: !equip_antag })
                    }
                  >
                    Equip antags
                  </Button.Checkbox>
                </>
              )}
              {!!incompatible_antag && (
                <Button
                  color="yellow"
                  circular
                  icon="circle-exclamation"
                  tooltip="Some antagonists are only compatible with human mobs, this may not work properly."
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="DNR">
              <Button.Checkbox
                checked={allow_dnr}
                tooltip="Allow players who have set DNR to respawn in this event"
                onClick={() => act('set_allow_dnr', { allow_dnr: !allow_dnr })}
              >
                Allow DNR players
              </Button.Checkbox>
            </LabeledList.Item>
            {spawn_type === 'job' && (
              <LabeledList.Item label="Manifest">
                <Button.Checkbox
                  checked={add_to_manifest}
                  tooltip="Add players spawned by this event to the station manifest"
                  onClick={() =>
                    act('set_manifest', { add_to_manifest: !add_to_manifest })
                  }
                >
                  Add to manifest
                </Button.Checkbox>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Objective text">
              <TextArea
                value={objective_text}
                fluid
                height={5}
                onChange={(_, value) =>
                  act('set_objective_text', { objective_text: value })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section align="center">
          <Button
            onClick={() => act('spawn')}
            disabled={!thing_to_spawn || thing_to_spawn === '[0x0]'}
          >
            Spawn
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
