/**
 * @file
 * @copyright 2023
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import {
  Box,
  Collapsible,
  Divider,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ItemList } from '../../components';
import {
  AntagonistStatisticsProps,
  AntagonistTabData,
  VerboseAntagonistProps,
} from './type';

export const AntagonistsTab = () => {
  const { data } = useBackend<AntagonistTabData>();

  return (
    <>
      <GameModeDisplay game_mode={data.game_mode} />
      {data.verbose_antagonist_data?.map((antagonist, index) => (
        <Antagonist key={index} {...antagonist} />
      ))}
      {!!data.succinct_antagonist_data.length && (
        <Section title="Other Antagonists">
          <SuccinctAntagonistData
            succinct_antagonist_data={data.succinct_antagonist_data}
          />
        </Section>
      )}
    </>
  );
};

const GameModeDisplay = (props) => {
  const { game_mode } = props;

  return (
    <Section>
      <Stack vertical align="center" my={3}>
        <Stack.Item mb={-2.5} italic>
          The Game Mode Was:
        </Stack.Item>
        <Stack.Item fontSize={2.75} bold>
          {game_mode}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Antagonist = (props: VerboseAntagonistProps) => {
  const {
    antagonist_roles,
    real_name,
    player,
    job_role,
    status,
    objectives,
    antagonist_statistics,
    subordinate_antagonists,
  } = props;

  return (
    <Box my={2}>
      <Collapsible
        title={`${real_name} (played by ${player}) - ${antagonist_roles}`}
        fontSize={1.2}
        bold
      >
        <Section mt={-1.1}>
          <Box fontSize={1.1} bold>
            General
          </Box>
          <Divider />
          <LabeledList>
            <LabeledList.Item label="Job">{job_role}</LabeledList.Item>
            <LabeledList.Item label="Status">{status}</LabeledList.Item>
          </LabeledList>
          {!!objectives.length && (
            <AntagonistObjectives objectives={objectives} />
          )}
          {!!antagonist_statistics.length && (
            <AntagonistStatistics
              antagonist_statistics={antagonist_statistics}
            />
          )}
          {!!subordinate_antagonists.length && (
            <SubordinateAntagonists
              subordinate_antagonists={subordinate_antagonists}
            />
          )}
        </Section>
      </Collapsible>
    </Box>
  );
};

const AntagonistObjectives = (props) => {
  const { objectives } = props;

  return (
    <>
      <Box fontSize={1.1} bold mt={3}>
        Objectives
      </Box>
      <Divider />
      <Stack vertical ml={0.5}>
        {objectives?.map((objective, index) => (
          <Stack.Item key={index} color={objective.completed ? 'green' : 'red'}>
            <Stack>
              <Stack.Item minWidth={0.9} textAlign="center">
                <Icon name={objective.completed ? 'check' : 'xmark'} />
              </Stack.Item>
              <Stack.Item>{objective.explanation_text}</Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </>
  );
};

const AntagonistStatistics = (props) => {
  const { antagonist_statistics } = props;

  return (
    <>
      <Box fontSize={1.1} bold mt={3}>
        Statistics
      </Box>
      <Divider />
      <LabeledList>
        {antagonist_statistics?.map((statistic, index) => (
          <StatisticsItem
            key={index}
            name={statistic.name}
            type={statistic.type}
            value={statistic.value}
          />
        ))}
      </LabeledList>
    </>
  );
};

const StatisticsItem = (props: AntagonistStatisticsProps) => {
  const { name, type, value } = props;
  const StatisticItemContents = getStatisticItemComponent(type);

  return (
    <LabeledList.Item label={name} verticalAlign="middle">
      <StatisticItemContents
        type={type}
        items={value}
        nothing_text="Nothing."
      />
    </LabeledList.Item>
  );
};

const getStatisticItemComponent = (type) => {
  if (type === undefined) {
    return ({ items }) => items;
  }
  if (type in statisticItemComponents) {
    return statisticItemComponents[type];
  }
};

const statisticItemComponents = {
  itemList: ItemList,
};

const SubordinateAntagonists = (props) => {
  const { subordinate_antagonists } = props;

  return (
    <>
      <Box fontSize={1.1} bold mt={3}>
        Subordinate Antagonists
      </Box>
      <Divider />
      <SuccinctAntagonistData
        succinct_antagonist_data={subordinate_antagonists}
      />
    </>
  );
};

const SuccinctAntagonistData = (props) => {
  const { succinct_antagonist_data } = props;

  return (
    <Stack fill vertical>
      {succinct_antagonist_data?.map((antagonist, index) => (
        <Stack.Item key={index}>
          <Stack fill justify="space-between">
            <Stack.Item grow>{antagonist.antagonist_role}</Stack.Item>
            <Stack.Item shrink textAlign="right">
              {!!antagonist.dead && (
                <>
                  <Icon name="skull" />{' '}
                </>
              )}
              {antagonist.real_name} (played by {antagonist.player})
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};
