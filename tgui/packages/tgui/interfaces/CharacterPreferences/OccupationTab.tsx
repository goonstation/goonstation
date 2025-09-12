/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { PropsWithChildren, useContext } from 'react';
import { Box, Button, Section, Stack, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import * as occupationActions from './actions';
import {
  OccupationControl,
  OccupationControlContents,
} from './components/OccupationControl';
import { ModalContext } from './modals/ModalContext';
import {
  type AntagonistStaticData,
  type CharacterPreferencesData,
  PriorityLevel,
} from './type';

const NO_OP = () => {};

export const OccupationTab = () => {
  const {
    setOccupationPriorityModalOptions,
    showResetOccupationPreferencesModal,
  } = useContext(ModalContext);
  const { act, data } = useBackend<CharacterPreferencesData>();
  const { jobFavourite, jobStaticData } = data;
  const favoriteJob = jobFavourite ? jobStaticData[jobFavourite] : undefined;
  return (
    <>
      <Section
        title="Job Preferences"
        buttons={
          <Button
            onClick={() => showResetOccupationPreferencesModal(true)}
            color="red"
          >
            Reset All Job Preferences
          </Button>
        }
      >
        <Section
          title={
            <Tooltip content="This is for the one job that you like the most - the game will always try to get you into this job first if it can. You might not always get your favorite job, especially if it's a single-slot role like a Head, but don't be discouraged if you don't get it - it's just luck of the draw. You might get it next time.">
              Favorite Job
            </Tooltip>
          }
        >
          {favoriteJob ? (
            <OccupationControl
              color={favoriteJob.colour}
              onChangePriorityLevel={(newPriorityLevel) =>
                occupationActions.setJobPriorityLevel(
                  act,
                  jobFavourite,
                  PriorityLevel.Favorite,
                  newPriorityLevel,
                )
              }
              onMenuOpen={() =>
                setOccupationPriorityModalOptions({
                  hasWikiLink: !!favoriteJob.wiki_link,
                  occupation: jobFavourite,
                  priorityLevel: PriorityLevel.Favorite,
                  required: !!favoriteJob.required,
                })
              }
              priorityLevel={PriorityLevel.Favorite}
              required={!!favoriteJob.required}
              tooltip={
                <DisabledTooltip title={jobFavourite}>
                  {favoriteJob.disabled_tooltip}
                </DisabledTooltip>
              }
            >
              <OccupationControlContents occupationName={jobFavourite} />
            </OccupationControl>
          ) : (
            <OccupationControl
              disabled
              onChangePriorityLevel={NO_OP}
              onMenuOpen={NO_OP}
              priorityLevel={PriorityLevel.Favorite}
              tooltip="Select a job from those below."
            >
              None
            </OccupationControl>
          )}
        </Section>
        <Stack>
          <PrioritySectionItem
            title="Medium Priority"
            priority_level={2}
            tooltip="Medium Priority Jobs are any jobs that you would like to play that aren't your favorite. People with jobs in this category get priority over those who have the same job in their Low Priority bracket. It's best to put jobs here that you actively enjoy playing and wouldn't mind ending up with if you don't get your favorite."
            occupations={data.jobsMedPriority}
          />
          <Stack.Divider />
          <PrioritySectionItem
            title="Low Priority"
            priority_level={3}
            tooltip="Low Priority Jobs are jobs that you don't mind doing. When the game is finding candidates for a job, it will try to fill it with Medium Priority players first, then Low Priority players if there are still free slots."
            occupations={data.jobsLowPriority}
          />
          <Stack.Divider />
          <PrioritySectionItem
            title="Unwanted Jobs"
            priority_level={4}
            tooltip="Unwanted Jobs are jobs that you absolutely don't want to have. The game will never give you a job you list here. The 'Staff Assistant' role can't be put here, however, as it's the fallback job if there are no other openings."
            occupations={data.jobsUnwanted}
          />
        </Stack>
      </Section>
      <Section
        title={
          <Tooltip content="Antagonist roles are randomly chosen when the game starts, before jobs have been allocated. Leaving an antagonist role unchecked means that you will never be chosen for it automatically.">
            Antagonist Preferences
          </Tooltip>
        }
      >
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))',
          }}
        >
          {Object.entries(data.antagonistPreferences).map(
            ([antag_id, enabled]) => (
              <AntagonistOption
                key={antag_id}
                checked={enabled}
                {...data.antagonistStaticData[antag_id]}
              />
            ),
          )}
        </div>
      </Section>
    </>
  );
};

interface PrioritySectionProps {
  title: string;
  priority_level: number;
  tooltip: string;
  occupations: string[];
}

const PrioritySectionItem = (props: PrioritySectionProps) => {
  const { title, priority_level, tooltip, occupations } = props;
  const { act, data } = useBackend<CharacterPreferencesData>();
  const { setOccupationPriorityModalOptions } = useContext(ModalContext);
  return (
    <Stack.Item grow overflow="hidden">
      <Section title={<Tooltip content={tooltip}>{title}</Tooltip>}>
        <Stack vertical g={0.5}>
          {occupations?.map((occupation) => {
            const jobStaticData = data.jobStaticData[occupation];
            if (!jobStaticData) {
              return null;
            }
            const { colour, disabled, disabled_tooltip, required, wiki_link } =
              jobStaticData;
            return (
              <Stack.Item key={occupation}>
                <OccupationControl
                  color={colour}
                  disabled={!!disabled}
                  onChangePriorityLevel={(newPriorityLevel) =>
                    occupationActions.setJobPriorityLevel(
                      act,
                      occupation,
                      priority_level,
                      newPriorityLevel,
                    )
                  }
                  onMenuOpen={() =>
                    setOccupationPriorityModalOptions({
                      hasWikiLink: !!wiki_link,
                      occupation,
                      priorityLevel: priority_level,
                      required: !!required,
                    })
                  }
                  priorityLevel={priority_level}
                  required={!!required}
                  tooltip={
                    <DisabledTooltip title={occupation}>
                      {disabled_tooltip}
                    </DisabledTooltip>
                  }
                >
                  <OccupationControlContents occupationName={occupation} />
                </OccupationControl>
              </Stack.Item>
            );
          })}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const AntagonistOption = (
  props: AntagonistStaticData & { checked: boolean },
) => {
  const { act } = useBackend<CharacterPreferencesData>();

  return (
    <Button.Checkbox
      onClick={() =>
        act('toggle-antagonist-preference', {
          variable: props.variable,
        })
      }
      tooltip={
        <DisabledTooltip title={props.name}>
          {props.disabled_tooltip}
        </DisabledTooltip>
      }
      disabled={props.disabled}
      checked={props.checked}
      ellipsis
    >
      {props.name}
    </Button.Checkbox>
  );
};

interface DisabledTooltipProps {
  title: string;
}

const DisabledTooltip = (props: PropsWithChildren<DisabledTooltipProps>) => {
  const { children, title } = props;
  return (
    <>
      <Box bold textAlign="center">
        {title}
      </Box>
      {!!children && (
        <Box
          mt="0.5em"
          dangerouslySetInnerHTML={{
            __html: `<b>Disabled:</b> ${children}`,
          }}
        />
      )}
    </>
  );
};
