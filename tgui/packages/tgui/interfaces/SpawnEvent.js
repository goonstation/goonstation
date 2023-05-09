import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section, TextArea } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const SpawnEvent = (props, context) => {
  const { act, data } = useBackend(context);
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
  } = data;
  return (
    <Window
      title="Ghost Spawn Editor"
      width={500}
      height={330}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Thing to spawn">
              <Button
                selected={thing_name && (spawn_type === "mob_ref")}
                onClick={() => act("select_mob")}
                tooltip={(spawn_type === "mob_ref") && thing_name ? thing_to_spawn : ""}
              >
                {(spawn_type === "mob_ref") ? thing_name : "Mob ref"}
              </Button>
              <Button
                selected={thing_name && (spawn_type === "mob_type")}
                onClick={() => act("select_mob_type")}
                tooltip={(spawn_type === "mob_type") && thing_name ? thing_to_spawn : ""}
              >
                {(spawn_type === "mob_type") ? thing_name : "Mob type"}
              </Button>
              <Button
                selected={thing_name && (spawn_type === "job")}
                onClick={() => act("select_job")}
                tooltip={(spawn_type === "job") && thing_name ? thing_to_spawn : ""}
              >
                {(spawn_type === "job") ? thing_name : "Job"}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Accept delay">
              <NumberInput
                value={ghost_confirmation_delay / 10}
                minValue={0}
                maxValue={120}
                onDrag={(e, spawn_delay) => act('set_spawn_delay', { spawn_delay: (spawn_delay * 10) })} />
            </LabeledList.Item>
            <LabeledList.Item label="Amount to spawn">
              <NumberInput
                value={amount_to_spawn}
                minValue={1}
                maxValue={100}
                onDrag={(e, amount) => act('set_amount', { amount })} />
              {amount_to_spawn === 1 && spawn_type === "mob_ref" && thing_name && (
                <ButtonCheckbox
                  checked={spawn_directly}
                  onClick={() => act("set_spawn_directly", { spawn_directly: !spawn_directly })}
                  tooltip="Puts the ghost mind directly into the original mob instead of copying it."
                >
                  Spawn as original
                </ButtonCheckbox>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Spawn location">
              <Button disabled={spawn_directly} selected={spawn_loc && (loc_type === "turf_ref")} onClick={() => act("select_turf")}>{(loc_type === "turf_ref") ? spawn_loc : "Turf ref"}</Button>
              <Button disabled={spawn_directly} selected={spawn_loc && (loc_type === "landmark")} onClick={() => act("select_landmark")}>{(loc_type === "landmark") ? spawn_loc : "Landmark"}</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Antagonist status">
              <Button selected={antag_role} onClick={() => act("select_antag")}>{antag_role || "Antag role"}</Button>
              {antag_role && (
                <>
                  <Button color="red" onClick={() => act("clear_antag")}>x</Button>
                  <ButtonCheckbox
                    checked={equip_antag}
                    tooltip="Give antag default equipment and abilities? Will overwrite anything already equipped in those slots."
                    onClick={() => act("set_equip", { equip_antag: !equip_antag })}
                  >
                    Equip antags
                  </ButtonCheckbox>
                </>
              )}
              {!!incompatible_antag && (
                <Button color="yellow" circular icon="circle-exclamation" tooltip="Some antagonists are only compatible with human mobs, this may not work properly." />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Objective text">
              <TextArea
                value={objective_text}
                fluid
                height={5}
                onChange={(_, value) => act("set_objective_text", { objective_text: value })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section align="center">
          <Button onClick={() => act("spawn")}>Spawn</Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
