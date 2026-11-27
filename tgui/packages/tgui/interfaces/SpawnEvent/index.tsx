import {
  Button,
  Collapsible,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { SpawnEventData, SpawnEventRoleData } from './type';

export const SpawnEvent = () => {
  const { act, data } = useBackend<SpawnEventData>();
  const {
    roles,
    ghost_confirmation_delay,
    ask_permission,
    allow_dnr,
    eligible_player_count,
  } = data;
  return (
    <Window title="Ghost Spawn Editor" width={500} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Event title">
                  <Input
                    fluid
                    onBlur={(value) => act('set_title', { new_title: value })}
                    value={data.event_title}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Accept delay">
                  {!!ask_permission && (
                    <NumberInput
                      value={ghost_confirmation_delay / 10}
                      minValue={0}
                      maxValue={120}
                      step={1}
                      onChange={(spawn_delay) =>
                        act('set_spawn_delay', {
                          spawn_delay: spawn_delay * 10,
                        })
                      }
                      disabled={!ask_permission}
                    />
                  )}
                  <Button.Checkbox
                    checked={ask_permission}
                    onClick={() =>
                      act('set_ask_permission', {
                        ask_permission: !ask_permission,
                      })
                    }
                    tooltip="Do we ask permission or just spawn them directly?"
                  >
                    Ask permission.
                  </Button.Checkbox>
                </LabeledList.Item>
                <LabeledList.Item label="DNR">
                  <Button.Checkbox
                    checked={allow_dnr}
                    tooltip="Allow players who have set DNR to respawn in this event"
                    onClick={() =>
                      act('set_allow_dnr', { allow_dnr: !allow_dnr })
                    }
                  >
                    Allow DNR players
                  </Button.Checkbox>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              scrollable
              fill
              title="Roles"
              buttons={
                <Button icon="plus" onClick={() => act('add_role')}></Button>
              }
            >
              {roles?.length > 0
                ? roles.map((role) => <SpawnEventRole role={role} />)
                : null}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button
              fontSize="24px"
              fluid
              color="green"
              icon="person-circle-plus"
              align="center"
              onClick={() => act('spawn')}
              disabled={roles.length < 1}
            >
              Spawn
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface SpawnEventRoleProps {
  role: SpawnEventRoleData;
}
const SpawnEventRole = (props: SpawnEventRoleProps) => {
  const { act, data } = useBackend<SpawnEventData>();
  const { role } = props;
  return (
    <Collapsible
      title={[role.antag_role ? role.antag_role + ' ' : ''] + role.thing_name}
      buttons={
        <Button
          icon="trash"
          color="red"
          onClick={() =>
            act('remove_role', {
              role_ref: role.ref,
            })
          }
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Thing to spawn">
          <Button
            selected={!!role.thing_name && role.spawn_type === 'mob_ref'}
            onClick={() =>
              act('select_mob', {
                role_ref: role.ref,
              })
            }
            tooltip={
              role.spawn_type === 'mob_ref' && role.thing_name
                ? role.thing_to_spawn
                : ''
            }
          >
            {role.spawn_type === 'mob_ref' ? role.thing_name : 'Mob ref'}
          </Button>
          <Button
            selected={!!role.thing_name && role.spawn_type === 'mob_type'}
            onClick={() =>
              act('select_mob_type', {
                role_ref: role.ref,
              })
            }
            tooltip={
              role.spawn_type === 'mob_type' && role.thing_name
                ? role.thing_to_spawn
                : ''
            }
          >
            {role.spawn_type === 'mob_type' ? role.thing_name : 'Mob type'}
          </Button>
          <Button
            selected={!!role.thing_name && role.spawn_type === 'job'}
            onClick={() =>
              act('select_job', {
                role_ref: role.ref,
              })
            }
            tooltip={
              role.spawn_type === 'job' && role.thing_name
                ? role.thing_to_spawn
                : ''
            }
          >
            {role.spawn_type === 'job' ? role.thing_name : 'Job'}
          </Button>
          <Button
            selected={role.spawn_type === 'random_human'}
            onClick={() =>
              act('set_random_human', {
                role_ref: role.ref,
              })
            }
            tooltip={'Just a basic random human.'}
          >
            Random Human
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Amount to spawn">
          <NumberInput
            width={5}
            value={role.amount_to_spawn}
            minValue={1}
            maxValue={100}
            step={1}
            unit={`/${data.eligible_player_count} `}
            onChange={(amount) =>
              act('set_amount', { amount, role_ref: role.ref })
            }
          />
          <Button icon="refresh" onClick={() => act('refresh_player_count')} />
          {role.amount_to_spawn === 1 &&
            role.spawn_type === 'mob_ref' &&
            role.thing_name && (
              <Button.Checkbox
                checked={role.spawn_directly}
                onClick={() =>
                  act('set_spawn_directly', {
                    spawn_directly: !role.spawn_directly,
                    role_ref: role.ref,
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
            disabled={role.spawn_directly}
            selected={!!role.spawn_loc && role.loc_type === 'turf_ref'}
            onClick={() =>
              act('select_turf', {
                role_ref: role.ref,
              })
            }
          >
            {role.loc_type === 'turf_ref' ? role.spawn_loc : 'Turf ref'}
          </Button>
          <Button
            disabled={role.spawn_directly}
            selected={!!role.spawn_loc && role.loc_type === 'landmark'}
            onClick={() =>
              act('select_landmark', {
                role_ref: role.ref,
              })
            }
          >
            {role.loc_type === 'landmark' ? role.spawn_loc : 'Landmark'}
          </Button>
          {!!role.job_wanted_location && (
            <Button
              onClick={() =>
                act('select_default_job_landmark', {
                  role_ref: role.ref,
                })
              }
              color="red"
              icon="exclamation"
              tooltip="Selected job wants to spawn at a specific landmark, click me to select that landmark."
            />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Antagonist status">
          <Button
            selected={!!role.antag_role}
            onClick={() =>
              act('select_antag', {
                role_ref: role.ref,
              })
            }
          >
            {role.antag_role || 'Antag role'}
          </Button>
          {role.antag_role && (
            <>
              <Button
                color="red"
                onClick={() =>
                  act('clear_antag', {
                    role_ref: role.ref,
                  })
                }
              >
                x
              </Button>
              <Button.Checkbox
                checked={role.equip_antag}
                tooltip="Give antag default equipment and abilities? Will overwrite anything already equipped in those slots."
                onClick={() =>
                  act('set_equip', {
                    equip_antag: !role.equip_antag,
                    role_ref: role.ref,
                  })
                }
              >
                Equip antags
              </Button.Checkbox>
            </>
          )}
          {!!role.incompatible_antag && (
            <Button
              color="yellow"
              circular
              icon="circle-exclamation"
              tooltip="Some antagonists are only compatible with human mobs, this may not work properly."
            />
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Choose Name">
          <Button.Checkbox
            checked={role.choose_name}
            disabled={role.disable_choose_name}
            tooltip="Allow players who respawn to choose their own name"
            onClick={() =>
              act('choose_name', {
                choose_name: !role.choose_name,
                role_ref: role.ref,
              })
            }
          >
            Respawnees choose name
          </Button.Checkbox>
        </LabeledList.Item>
        {role.spawn_type === 'job' && (
          <LabeledList.Item label="Manifest">
            <Button.Checkbox
              checked={role.add_to_manifest}
              tooltip="Add players spawned by this event to the station manifest"
              onClick={() =>
                act('set_manifest', {
                  add_to_manifest: !role.add_to_manifest,
                  role_ref: role.ref,
                })
              }
            >
              Add to manifest
            </Button.Checkbox>
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Objective text">
          <TextArea
            value={role.objective_text}
            fluid
            height={5}
            onBlur={(value) =>
              act('set_objective_text', {
                objective_text: value,
                role_ref: role.ref,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};
