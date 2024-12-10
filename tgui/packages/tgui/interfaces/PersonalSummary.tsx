/**
 * @file
 * @copyright 2024
 * @author glowbold (https://github.com/pgmzeta)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { Box, ProgressBar, Section, Table } from 'tgui-core/components';
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
    <Window title="Personal Summary" width={300} height={425}>
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
      {!exp_earned && <Box>No experience earned.</Box>}
      {!!exp_earned && (
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
            position="relative"
          />
          <Box textAlign="right">
            {level_exp}/{next_level_exp}xp
          </Box>
          <Box textAlign="right">{next_level_exp - level_exp} to next</Box>
        </>
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
      <Table lineHeight="1.2em">
        {!is_antagonist && (
          <>
            <Table.Row className="candystripe">
              <Table.Cell>
                Base Wage {!!is_part_time && '(part-time)'}
              </Table.Cell>
              <Table.Cell fontWeight="bold" textAlign="right">
                {base_wage}
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe">
              <Table.Cell>Station Grade Tax</Table.Cell>
              <Table.Cell fontWeight="bold" textAlign="right">
                -{base_wage - score_adjusted_wage}
              </Table.Cell>
            </Table.Row>
            {!is_escaped && (
              <Table.Row className="candystripe">
                <Table.Cell>Did Not Escape</Table.Cell>
                <Table.Cell fontWeight="bold" textAlign="right">
                  -{score_adjusted_wage - earned_spacebux}
                </Table.Cell>
              </Table.Row>
            )}
            {objective_completed_bonus > 0 && (
              <Table.Row className="candystripe">
                <Table.Cell>Crew objective bonus</Table.Cell>
                <Table.Cell fontWeight="bold" textAlign="right">
                  +{objective_completed_bonus}
                </Table.Cell>
              </Table.Row>
            )}
            {all_objectives_bonus > 0 && (
              <Table.Row className="candystripe">
                <Table.Cell>All crew objective bonus</Table.Cell>
                <Table.Cell fontWeight="bold" textAlign="right">
                  +{all_objectives_bonus}
                </Table.Cell>
              </Table.Row>
            )}
          </>
        )}

        {!!is_antagonist && (
          <>
            <Table.Row className="candystripe">
              <Table.Cell>Base Wage</Table.Cell>
              <Table.Cell fontWeight="bold" textAlign="right">
                {earned_spacebux}
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe">
              <Table.Cell colSpan={2}>Antagonist - No tax!</Table.Cell>
            </Table.Row>
          </>
        )}

        {is_pilot && (
          <Table.Row className="candystripe">
            <Table.Cell>Pilot&apos;s bonus</Table.Cell>
            <Table.Cell fontWeight="bold" textAlign="right">
              +{pilot_bonus}
            </Table.Cell>
          </Table.Row>
        )}
      </Table>
      <hr />
      <Table>
        <Table.Row>
          <Table.Cell fontSize="1.1em" fontWeight="bold">
            PAYOUT
          </Table.Cell>
          <Table.Cell fontSize="1.1em" fontWeight="bold" textAlign="right">
            {earned_spacebux}
          </Table.Cell>
        </Table.Row>
      </Table>
      <br />
      <Table>
        <Table.Row>
          <Table.Cell textAlign="right">ACCOUNT BALANCE:</Table.Cell>
          <Table.Cell textAlign="right" fontWeight="bold">
            {total_spacebux}
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell textAlign="right">HELD ITEM:</Table.Cell>
          <Table.Cell
            textAlign="right"
            fontWeight={held_item ? 'normal' : 'bold'}
          >
            {held_item ? held_item : 'none'}
          </Table.Cell>
        </Table.Row>
      </Table>
      <br />
      <Box fontSize="0.8em">
        Spend Spacebux from your bank when you Declare Ready for the next round!
      </Box>
    </Section>
  );
};
