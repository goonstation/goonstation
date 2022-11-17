/**
 * @file
 * @copyright 2022 Bartimeus973
 * @author Bartimeus973 (https://github.com/Bartimeus973)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Section, LabeledList } from '../components';
import { Window } from '../layouts';

export const VortexWraith = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    spawnrate,
    spawnrange,
    mob_value_cap,
    _health,
    maxhealth,
    summon_power,
    upgrade_cost,
    active,
    cooldown,
  } = data;

  return (
    <Window
      title="Wraith Vortex"
      width={550}
      height={450}
      theme="retro-dark">
      <Window.Content>
        <Section title="Upgrades">
          Spawn delay: One spawn every {spawnrate} seconds.
          <LabeledList.Item label="- 3 second spawn delay">
            <Button
              disabled={cooldown}
              content={`${upgrade_cost} points`}
              onClick={() => act('up_spawnrate')} />
          </LabeledList.Item>
          Spawn range: Spawn creatures and apply effects in a range of {spawnrange} tiles from the portal.
          <LabeledList.Item label="+ 1 spawn range">
            <Button
              disabled={cooldown}
              content={`${upgrade_cost} points`}
              onClick={() => act('up_spawnrange')} />
          </LabeledList.Item>
          Summon level : {summon_power}
          <LabeledList.Item label="Stronger summons">
            <Button
              disabled={cooldown}
              content={`${upgrade_cost * 2} points`}
              onClick={() => act('up_summonpower')} />
          </LabeledList.Item>
          Maximum follower amount (Higher level creatures take two spots): {mob_value_cap}
          <LabeledList.Item label="More max summons">
            <Button
              disabled={cooldown}
              content={`${upgrade_cost} points`}
              onClick={() => act('up_summoncap')} />
          </LabeledList.Item>
          Maximum portal health : {maxhealth}
          <LabeledList.Item label="More maximum portal health">
            <Button
              disabled={cooldown}
              content={`${upgrade_cost} points`}
              onClick={() => act('up_portalhealth')} />
          </LabeledList.Item>
          Current portal health : {_health}
          <LabeledList.Item label="Heal the portal">
            <Button
              disabled={cooldown}
              content={`${upgrade_cost} points`}
              onClick={() => act('portalheal')} />
          </LabeledList.Item>
        </Section>
        <Section title="Portal options">
          <Button
            content="Destroy your portal"
            onClick={() => act('destroy_portal')} />
          <Button
            content="Kill all your portal summons"
            onClick={() => act('kill_summons')} />
          <Button.Checkbox
            checked={active}
            tooltip="Prevents the portal from summoning creatures. Other effects are still active."
            onClick={() => act('toggle_active')}>
            Summon creatures
          </Button.Checkbox>
        </Section>
      </Window.Content>
    </Window>
  );
};
