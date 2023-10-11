/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Fragment } from "inferno";
import { useBackend } from "../../backend";
import { ItemList, LabeledList, Section, Stack } from "../../components";
import { ScoreCategoryProps, ScoreItemProps, ScoreTabData } from "./type";

export const ScoreTab = (props, context) => {
  const { data } = useBackend<ScoreTabData>(context);
  const { score_groups, total_score, grade, victory_body, victory_headline } = data;
  return (
    <Fragment>
      { !!victory_headline && <SummaryDisplay preamble="Round Result:" headline={victory_headline} body={victory_body}> </SummaryDisplay>}
      { !victory_headline && <SummaryDisplay preamble="Total Score:" headline={total_score} body={grade}> </SummaryDisplay>}

      <Section>
        {score_groups?.map(
          (category, index) =>
            !!category.entries.length && <ScoreCategory key={index} title={category.title} entries={category.entries} />
        )}
      </Section>
    </Fragment>
  );
};

const SummaryDisplay = (props) => {
  const {
    preamble,
    headline,
    body,
  } = props;

  return (
    <Section>
      <Stack
        vertical
        align="center"
        my={3}>
        <Stack.Item
          italic
          mt={0}
          mb={-2.5}>
          {preamble}
        </Stack.Item>
        <Stack.Item
          fontSize={2.75}
          bold>
          {headline}
        </Stack.Item>
        <Stack.Item
          mb={-2.5}>
          {body}
        </Stack.Item>
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
    <LabeledList.Item
      label={name}
      verticalAlign="middle">
      <ScoreItemContents
        type={type}
        items={value}
        nothing_text={"N/A"}
      />
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

const scoreItemComponents = {
  "itemList": ItemList,
};
