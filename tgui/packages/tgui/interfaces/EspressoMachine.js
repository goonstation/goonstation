/**
 * @file
 * @copyright 2022 Saicchi
 * @author Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Flex, Section, Box, NoticeBox, Tooltip } from '../components';
import { Window } from '../layouts';

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

export const EspressoMachine = (props, context) => {
  const { data } = useBackend(context);

  const drinkslist = data.drinks;
  const cupslist = data.containers.map(cup => {
    return {
      capacity: cup["capacity"],
      index: cup["index"],
      total: cup["reagents"].reduce((total, reagent) => { return total + reagent[1]; }, 0),
      reagents: cup["reagents"].map(reagent => {
        return {
          name: reagent[0],
          amount: reagent[1],
          colour: `rgb(${reagent[2]},${reagent[3]},${reagent[4]})`,
        };
      }),
    };
  });

  return (
    <Window
      title="Espresso Machine"
      width={500}
      height={400}
      theme="ntos">
      <Window.Content>
        <Section title="Drinks">
          <DrinksList drinks={drinkslist} />
        </Section>
        <Section title="Cups">
          <Flex direction="column">
            {cupslist.map(cup => (<DrinkContainer key={cup.index} cup={cup} />))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
