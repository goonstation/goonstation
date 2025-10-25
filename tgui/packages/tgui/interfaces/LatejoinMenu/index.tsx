/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { useContext } from 'react';
import { Box, Button, Icon, Section, Stack } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../../backend';
import { ColorCheckbox, ColorSection } from '../../components';
import { Window } from '../../layouts';
import * as jobActions from './actions';
import { JobModal } from './modals/JobModal';
import { ModalContext } from './modals/ModalContext';
import { useModalContext } from './modals/ModalContext';
import { DepartmentData, JobData, LatejoinMenuData } from './type';

export const LatejoinMenu = () => {
  const { data } = useBackend<LatejoinMenuData>();
  const [modalContextValue, modalContextState, ModalContext] =
    useModalContext();
  const { jobModal } = modalContextState;

  return (
    <Window width={650} height={850} title="Join Game">
      <ModalContext value={modalContextValue}>
        <Window.Content scrollable>
          <Section>
            <Stack vertical align="center" my={3} g={2}>
              <Stack.Item fontSize={2} bold>
                You are joining a round in progress.
              </Stack.Item>
              <Stack.Item fontSize={1.25}>
                Please choose from one of the remaining open positions.
              </Stack.Item>
            </Stack>
          </Section>
          <div
            style={{
              columnCount: 2,
            }}
          >
            {data.departments.map(
              (department, index) =>
                !!department.jobs.length && (
                  <DepartmentSection key={index} {...department} />
                ),
            )}
          </div>
        </Window.Content>
        {jobModal && <JobModal {...jobModal} />}
      </ModalContext>
    </Window>
  );
};

const DepartmentSection = (props: DepartmentData) => {
  return (
    <ColorSection
      title={props.name}
      color={props.colour}
      style={{
        breakInside: 'avoid',
      }}
    >
      <Stack vertical g={0.5}>
        {props.jobs.map((job, index) => (
          <JobOption key={index} {...job} />
        ))}
      </Stack>
    </ColorSection>
  );
};

const JobOption = (props: JobData) => {
  const { setJobModalOptions } = useContext(ModalContext);

  return (
    <Stack.Item>
      <Stack
        g={0.5}
        style={
          !!props.priority_role || !!props.player_requested
            ? {
                borderRadius: '2px',
                outlineStyle: 'solid',
                outlineWidth: '2px',
                outlineColor: 'var(--color-gold)',
              }
            : {}
        }
      >
        <Stack.Item grow>
          <Button
            tooltip={getJobOptionTooltip({ ...props })}
            onClick={() =>
              setJobModalOptions({
                job_name: props.job_name,
                has_wiki_link: props.has_wiki_link,
                job_ref: props.job_ref,
                silicon_latejoin: props.silicon_latejoin,
              })
            }
            fluid
            color={props.colour}
            disabled={props.disabled}
          >
            <JobContents {...props} />
          </Button>
        </Stack.Item>
        <Stack.Item align="center">
          <Slots {...props} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const PRIORITY_ROLE_TOOLTIP =
  '<b>Priority Role:</b> This job has been marked as a priority role by the Command Staff, meaning that the station is in need of them.';
const REQUESTED_ROLE_TOOLTIP =
  '<b>Requested Role:</b> This job has had additional slots opened by the Command Staff.';

function getJobOptionTooltip(props: JobData) {
  if (!props.priority_role && !props.player_requested) {
    return;
  }

  const tooltip = [
    !!props.priority_role && PRIORITY_ROLE_TOOLTIP,
    !!props.player_requested && REQUESTED_ROLE_TOOLTIP,
  ]
    .filter(Boolean)
    .join('<br><br>');

  return (
    <Box
      dangerouslySetInnerHTML={{
        __html: `${tooltip}`,
      }}
    />
  );
}

const JobContents = (props: JobData) => {
  return (
    <Stack>
      {!!props.priority_role && (
        <Stack.Item align="center">
          <Icon name="star" />
        </Stack.Item>
      )}
      {!!props.player_requested && (
        <Stack.Item align="center">
          <Icon name="user-plus" />
        </Stack.Item>
      )}
      <Stack.Item {...getJobContentsProps(props.job_name)}>
        {props.job_name}
      </Stack.Item>
    </Stack>
  );
};

function getJobContentsProps(job_name: string) {
  if (job_name === 'Clown') {
    return {
      grow: true,
      overflow: 'hidden',
      style: {
        fontFamily: 'Comic Sans MS',
        fontSize: '13px',
      },
    };
  }
  return {
    grow: true,
    style: {
      'text-wrap': 'wrap',
    },
  };
}

const MAX_SLOTS = 5;
const SLOT_PIXEL_WIDTH = 22;
const SLOT_WIDTH = `${SLOT_PIXEL_WIDTH}px`;
const SLOT_SECTION_WIDTH = `${SLOT_PIXEL_WIDTH * MAX_SLOTS}px`;

const Slots = (props: JobData) => {
  const { act } = useBackend<LatejoinMenuData>();
  const slot_array = GenerateSlotArray({ ...props });

  return (
    <Stack g={0} width={SLOT_SECTION_WIDTH}>
      {slot_array.map((slot, index) => (
        <Stack.Item key={index}>
          <ColorCheckbox
            onClick={() =>
              jobActions.joinAsJob(act, props.job_ref, props.silicon_latejoin)
            }
            icon=""
            checked={!slot.open}
            disabled={!slot.open || props.disabled}
            disabledColor={props.colour}
            width={SLOT_WIDTH}
            textAlign="center"
            p={0}
          >
            <Box>{slot.children}</Box>
          </ColorCheckbox>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const open_content = <Icon name="square-o" />;
const closed_content = <Icon name="square" />;
const disabled_content = (
  <Icon.Stack>
    <Icon name="square-o" mt="-2px" />
    <Icon name="slash" />
  </Icon.Stack>
);

interface SlotProps {
  open: boolean;
  children;
}

function GenerateSlotArray(props: JobData) {
  const unclosed_content = props.disabled ? disabled_content : open_content;
  const slot_overflow = props.slot_count - MAX_SLOTS;
  const slots_to_show =
    props.slot_limit < 0
      ? MAX_SLOTS
      : clamp(Math.max(props.slot_count, props.slot_limit), 0, MAX_SLOTS);

  const out = new Array<SlotProps>(slots_to_show);

  for (let i = 0; i < slots_to_show; i++) {
    if (i < props.slot_count) {
      out[i] = {
        open: false,
        children: closed_content,
      };
    } else {
      out[i] = {
        open: true,
        children: unclosed_content,
      };
    }
  }

  // If a slot overflow exists, show the total number of extra slots on the final slot.
  if (slot_overflow > 0) {
    out[MAX_SLOTS - 1].children = `+${1 + slot_overflow}`;
  }

  // If slots are still available, ensure that the final slot is open/disabled.
  // This is calculated from `slot_overflow + 1` as the overflow will instead be displayed on the penultimate slot.
  if (
    slot_overflow + 1 > 0 &&
    (props.slot_count < props.slot_limit || props.slot_limit < 0)
  ) {
    out[MAX_SLOTS - 1].open = true;
    out[MAX_SLOTS - 1].children = unclosed_content;
    out[MAX_SLOTS - 2].children = `+${2 + slot_overflow}`;
  }

  return out;
}
