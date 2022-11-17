/**
 * @file
 * @copyright 2022 Bartimeus973
 * @author Bartimeus973 (https://github.com/Bartimeus973)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Flex, Section, Box, NoticeBox, Tooltip, LabeledList } from '../components';
import { Window } from '../layouts';
/*
export const DrinksList = (props, context) => {
  const { act } = useBackend(context);

  const {
    drinks,
  } = props;

  return (
    <Flex wrap>
      {drinks.map(drink_name =>
        (
          <Flex.Item key={drink_name}>
            <Button key={drink_name} m="2px"
              fontSize="1.4rem" backgroundColor="brown"
              textAlign="center"
              onClick={() => act("pour", { drink_name: drink_name })}>
              {drink_name}
            </Button>
          </Flex.Item>
        )
      )}
    </Flex >
  );
};
*/
/*
export const ContainerButtons = (props, context) => {
  const { act } = useBackend(context);
  const { index } = props;

  return (
    <Flex>
      <Flex.Item nowrap>
        <Button
          icon="eject" color="blue" title="Eject"
          mr="10px"
          onClick={() => act("eject", { cup_index: index })} />
        <Button
          icon="times" color="red" title="Flush All"
          onClick={() => act("flush", { cup_index: index })} />
      </Flex.Item>
    </Flex>
  );
};

export const ReagentBlocks = (props) => {
  const { capacity, total, reagents } = props;

  return (
    <Flex mt="5px">
      {reagents.map(reagent => (
        <Flex.Item grow={reagent.amount / capacity} key={reagent.name}>
          <Tooltip content={`${reagent.name} (${reagent.amount}u)`} position="bottom">
            <Box width="100%" height="30px" px={0} my={0} backgroundColor={reagent.colour} />
          </Tooltip>
        </Flex.Item>
      ))}
      <Flex.Item grow={(capacity - total) / capacity} key="nothing">
        <Tooltip content={`Nothing (${capacity - total}u)`} position="bottom">
          <NoticeBox width="100%" height="30px" px={0} my={0}
            backgroundColor="rgba(0, 0, 0, 0)" // cool background effect reagent extractor has
          />
        </Tooltip>
      </Flex.Item>
    </Flex>
  );
};

export const DrinkContainer = (props, context) => {
  const { act } = useBackend(context);
  const { cup } = props;

  return (
    <Flex direction="column" mt="10px">
      <Flex>
        <ContainerButtons index={cup.index} />
        <Box
          as="span" fontSize="1.3rem"
          ml="15px"
        >{`${cup.total} / ${cup.capacity}`}
        </Box>
      </Flex>
      <ReagentBlocks capacity={cup.capacity} total={cup.total} reagents={cup.reagents} />
    </Flex>
  );
};
*/
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
              content={`${upgrade_cost} points`}
              onClick={() => act('up_spawnrate')} />
          </LabeledList.Item>
          Spawn range: Spawn creatures and apply effects in a range of {spawnrange} tiles from the portal.
          <LabeledList.Item label="+ 1 spawn range">
            <Button
              content={`${upgrade_cost} points`}
              onClick={() => act('up_spawnrange')} />
          </LabeledList.Item>
          Summon level : {summon_power}
          <LabeledList.Item label="Stronger summons">
            <Button
              content={`${upgrade_cost * 2} points`}
              onClick={() => act('up_summonpower')} />
          </LabeledList.Item>
          Maximum follower amount (Higher level creatures take two spots): {mob_value_cap}
          <LabeledList.Item label="More max summons">
            <Button
              content={`${upgrade_cost} points`}
              onClick={() => act('up_summoncap')} />
          </LabeledList.Item>
          Maximum portal health : {maxhealth}
          <LabeledList.Item label="More maximum portal health">
            <Button
              content={`${upgrade_cost} points`}
              onClick={() => act('up_portalhealth')} />
          </LabeledList.Item>
          Current portal health : {_health}
          <LabeledList.Item label="Heal the portal">
            <Button
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
