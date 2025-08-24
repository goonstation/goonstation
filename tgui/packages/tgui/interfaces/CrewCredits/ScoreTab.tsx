/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Box, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ItemList } from '../../components';
import { ScoreCategoryProps, ScoreItemProps, ScoreTabData } from './type';

export const ScoreTab = () => {
  const { data } = useBackend<ScoreTabData>();
  const { score_groups, total_score, grade, victory_body, victory_headline } =
    data;
  const total_score_render = <ColorPercentage items={total_score} />;
  return (
    <>
      {victory_headline ? (
        <SummaryDisplay
          preamble="Round Result:"
          headline={victory_headline}
          body={victory_body}
        />
      ) : (
        <SummaryDisplay
          preamble="Total Score:"
          headline={total_score_render}
          body={grade}
        />
      )}

      <Section>
        {score_groups?.map(
          (category, index) =>
            !!category.entries.length && (
              <ScoreCategory key={index} {...category} />
            ),
        )}
      </Section>
    </>
  );
};

interface SummaryDisplayProps {
  preamble: string;
  headline: string | JSX.Element;
  body: string;
}

const SummaryDisplay = (props: SummaryDisplayProps) => {
  const { preamble, headline, body } = props;

  return (
    <Section>
      <Stack vertical align="center" my={3}>
        <Stack.Item italic mt={0} mb={-2.5}>
          {preamble}
        </Stack.Item>
        <Stack.Item fontSize={2.75} bold>
          {headline}
        </Stack.Item>
        <Stack.Item mb={-2.5}>{body}</Stack.Item>
      </Stack>
    </Section>
  );
};

const ScoreCategory = (props: ScoreCategoryProps) => {
  const { title, entries } = props;
  return (
    <Section title={title}>
      <LabeledList>
        {entries?.map((score, index) => (
          <ScoreItem
            key={index}
            name={score.name}
            type={score.type}
            value={score.value}
          />
        ))}
      </LabeledList>
    </Section>
  );
};

const ScoreItem = (props: ScoreItemProps) => {
  const { name, type, value } = props;
  const ScoreItemContents = getScoreItemComponent(type);

  return (
    <LabeledList.Item label={name} verticalAlign="middle">
      <ScoreItemContents type={type} items={value} nothing_text={'N/A'} />
    </LabeledList.Item>
  );
};

const getScoreItemComponent = (type) => {
  if (type === undefined) {
    return ({ items }) => items;
  }
  if (type in scoreItemComponents) {
    return scoreItemComponents[type];
  }
};

const ColorPercentage = (props) => {
  const { items } = props;
  let textColor = 'white';
  if (items < 0) {
    textColor = 'purple';
  } // ???
  else if (items < 30) {
    textColor = 'brown';
  } // SUPER F
  else if (items < 60) {
    textColor = 'red';
  } // F
  else if (items < 70) {
    textColor = 'orange';
  } // D
  else if (items < 80) {
    textColor = 'yellow';
  } // C
  else if (items < 90) {
    textColor = 'yellowgreen';
  } // B
  else if (items < 100) {
    textColor = 'chartreuse';
  } // A
  else if (items === 100) {
    textColor = 'lime';
  } // PERFECT
  else if (items > 100) {
    textColor = 'teal';
  } // a level even further beyond
  return <Box color={textColor}>{items}%</Box>;
};

const scoreItemComponents = {
  itemList: ItemList,
  colorPercent: ColorPercentage,
};
