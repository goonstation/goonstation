/**
 * @file
 * @copyright 2024
 * @author glowbold (https://github.com/pgmzeta)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { Box, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface PersonalSummaryData {
  jobxp_data: JobXPSummaryData;
  spacebux_data: EarnedSpacebuxData;
}

interface JobXPSummaryData {
  current_job: String;
  current_level: number;
  earned_exp: number;
  level_exp: number;
  total_exp: number;
  next_level_exp: number;
  exp_earned: BooleanLike;
}

interface EarnedSpacebuxData {
  is_antagonist: BooleanLike;
  is_part_time: BooleanLike;
  is_escaped: BooleanLike;
  is_pilot: BooleanLike;

  base_wage: number;
  score_adjusted_wage: number;
  objective_completed_bonus: number;
  all_objectives_bonus: number;
  pilot_bonus: number;

  earned_spacebux: number;
  total_spacebux: number;
  held_item: String;
}

export const PersonalSummary = () => {
  const { data } = useBackend<PersonalSummaryData>();
  const { jobxp_data, spacebux_data } = data;
  return (
    <Window title="Personal Summary" width={300} height={450}>
      <Window.Content>
        <JobXPSummary {...jobxp_data} />
        <EarnedSpacebux {...spacebux_data} />
      </Window.Content>
    </Window>
  );
};

const JobXPSummary = (jobxp_data: JobXPSummaryData) => {
  const {
    current_job,
    current_level,
    earned_exp,
    level_exp,
    total_exp,
    next_level_exp,
    exp_earned,
  } = jobxp_data;
  return (
    <Section title="Job XP">
      {exp_earned ? (
        <>
          <Box fontWeight="bold">
            {current_job} &mdash; Level {current_level}
          </Box>
          <Box>
            Gained +{earned_exp}xp ({total_exp}xp total)
          </Box>
          <ProgressBar
            value={clamp(level_exp / next_level_exp, 0, 1)}
            minValue={0}
            maxValue={1}
            height="25px"
          />
          <Box textAlign="right">
            {level_exp}/{next_level_exp}xp
          </Box>
          <Box textAlign="right">{next_level_exp - level_exp} to next</Box>
        </>
      ) : (
        <Box>No experience earned.</Box>
      )}
    </Section>
  );
};

export const EarnedSpacebux = (spacebux_data: EarnedSpacebuxData) => {
  const {
    is_antagonist,
    is_part_time,
    is_escaped,
    is_pilot,
    base_wage,
    score_adjusted_wage,
    objective_completed_bonus,
    all_objectives_bonus,
    pilot_bonus,
    earned_spacebux,
    total_spacebux,
    held_item,
  } = spacebux_data;
  return (
    <Section title="Spacebux">
      <LabeledList>
        {is_antagonist ? (
          <>
            <LabeledList.Item
              textAlign="right"
              className="candystripe"
              label="Base Wage"
            >
              {earned_spacebux}
            </LabeledList.Item>
            <LabeledList.Item textAlign="right" className="candystripe">
              Antagonist - No tax!
            </LabeledList.Item>
          </>
        ) : (
          <>
            <LabeledList.Item
              textAlign="right"
              className="candystripe"
              label={is_part_time ? 'Base Wage (part-time)' : 'Base Wage'}
            >
              {base_wage}
            </LabeledList.Item>
            <LabeledList.Item
              textAlign="right"
              className="candystripe"
              label="Station Grade Tax"
            >
              -{base_wage - score_adjusted_wage}
            </LabeledList.Item>
            {!is_escaped && (
              <LabeledList.Item
                textAlign="right"
                className="candystripe"
                label="Did Not Escape"
              >
                {' '}
                -{score_adjusted_wage - earned_spacebux}
              </LabeledList.Item>
            )}
            {objective_completed_bonus > 0 && (
              <LabeledList.Item
                textAlign="right"
                className="candystripe"
                label="Crew objective bonus"
              >
                +{objective_completed_bonus}
              </LabeledList.Item>
            )}
            {all_objectives_bonus > 0 && (
              <LabeledList.Item
                textAlign="right"
                className="candystripe"
                label="All crew objective bonus"
              >
                +{all_objectives_bonus}
              </LabeledList.Item>
            )}
          </>
        )}
        {is_pilot && (
          <LabeledList.Item
            className="candystripe"
            textAlign="right"
            label="Pilot's Bonus"
          >
            +{pilot_bonus}
          </LabeledList.Item>
        )}
        <LabeledList.Divider />
        <LabeledList.Item textAlign="right" label={<b>Payout:</b>}>
          <b>{earned_spacebux}</b>
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item label="Account Balance" textAlign="right">
          {total_spacebux}
        </LabeledList.Item>
        <LabeledList.Item textAlign="right" label="Held Item">
          {held_item ? held_item : 'none'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt={2} fontSize="0.8em">
        Spend Spacebux from your bank when you Declare Ready for the next round!
      </Box>
    </Section>
  );
};
