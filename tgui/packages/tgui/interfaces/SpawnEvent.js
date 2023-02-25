import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section, TextArea } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const SpawnEvent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    thing_to_spawn,
    spawn_directly,
    spawn_loc,
    ghost_confirmation_delay,
    amount_to_spawn,
    antag_role,
    objective_text,
    spawn_type,
    loc_type,
  } = data;
  return (
    <Window
      title="Ghost Spawn Editor"
      width={500}
      height={600}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Thing to spawn">
              <Button selected={thing_to_spawn && (spawn_type === "mob_ref")} onClick={() => act("select_mob")}>{(spawn_type === "mob_ref") ? thing_to_spawn : "Mob ref"}</Button>
              <Button selected={thing_to_spawn && (spawn_type === "mob_type")} onClick={() => act("select_mob_type")}>{(spawn_type === "mob_type") ? thing_to_spawn : "Mob type"}</Button>
              <Button selected={thing_to_spawn && (spawn_type === "job_type")} onClick={() => act("select_job_type")}>{(spawn_type === "job_type") ? thing_to_spawn : "Job type"}</Button>
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
              {amount_to_spawn === 1 && spawn_type === "mob_ref" && thing_to_spawn && (
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
              <Button selected={spawn_loc && (loc_type === "turf_ref")} onClick={() => act("select_turf")}>{(loc_type === "turf_ref") ? spawn_loc : "Turf ref"}</Button>
              <Button selected={spawn_loc && (loc_type === "landmark")} onClick={() => act("select_landmark")}>{(loc_type === "landmark") ? spawn_loc : "Landmark"}</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Antagonist status">
              <Button selected={antag_role} onClick={() => act("select_antag")}>{antag_role || "Antag role"}</Button>
              {antag_role && (
                <Button color="red" onClick={() => act("clear_antag")}>x</Button>
              )}
              <Button circular icon="circle-exclamation" tooltip="Most antagonists are only compatible with human mobs." />
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
