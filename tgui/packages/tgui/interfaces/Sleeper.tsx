/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import {
  Box,
  Button,
  Flex,
  Icon,
  Knob,
  LabeledList,
  ProgressBar,
  Section,
  TimeDisplay,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { HealthStat } from '../components/goonstation/HealthStat';
import { formatTime } from '../format';
import { Window } from '../layouts';

const damageNum = (num) => (num <= 0 ? '0' : num.toFixed(1));

const OccupantStatus = {
  Conscious: 0,
  Unconscious: 1,
  Dead: 2,
};

const occupantStatuses = {
  [OccupantStatus.Conscious]: {
    name: 'Conscious',
    color: 'good',
    icon: 'check',
  },
  [OccupantStatus.Unconscious]: {
    name: 'Unconscious',
    color: 'average',
    icon: 'bed',
  },
  [OccupantStatus.Dead]: {
    name: 'Dead',
    color: 'bad',
    icon: 'skull',
  },
};

interface SleeperData {
  sleeperGone;
  hasOccupant;
  occupantStat;
  health;
  oxyDamage;
  toxDamage;
  burnDamage;
  bruteDamage;
  recharging;
  rejuvinators;
  isTiming;
  time;
  timeStarted;
  timeNow;
  maxTime;
}

export const Sleeper = () => {
  const { data, act } = useBackend<SleeperData>();
  const {
    sleeperGone,
    hasOccupant,
    occupantStat,
    health,
    oxyDamage,
    toxDamage,
    burnDamage,
    bruteDamage,
    recharging,
    rejuvinators,
    isTiming,
    time,
    timeStarted,
    timeNow,
    maxTime,
  } = data;

  const curTime = Math.max(
    timeStarted ? (time || 0) + timeStarted - timeNow : time || 0,
    0,
  );
  const canInject = hasOccupant && !isTiming && !recharging && occupantStat < 2;
  const occupantStatus = occupantStatuses[occupantStat];

  return (
    <Window theme="ntos" width={440} height={440}>
      <Window.Content>
        <Section
          title="Occupant Statistics"
          buttons={
            <Button
              icon="eject"
              align="center"
              color="good"
              disabled={!hasOccupant || !!isTiming}
              onClick={() => act('eject')}
            >
              Eject
            </Button>
          }
        >
          {!hasOccupant &&
            (sleeperGone
              ? 'Check connection to sleeper pod.'
              : 'The sleeper is unoccupied.')}
          {!!hasOccupant && (
            <LabeledList>
              <LabeledList.Item label="Status">
                <Icon color={occupantStatus.color} name={occupantStatus.icon} />
                {` ${occupantStatus.name}`}
              </LabeledList.Item>
              <LabeledList.Item label="Overall Health">
                <ProgressBar
                  value={health}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.5, 0.9],
                    bad: [-Infinity, 0.5],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Damage Breakdown">
                <HealthStat inline align="center" type="oxy" width={5}>
                  {damageNum(oxyDamage)}
                </HealthStat>
                /
                <HealthStat inline align="center" type="toxin" width={5}>
                  {damageNum(toxDamage)}
                </HealthStat>
                /
                <HealthStat inline align="center" type="burn" width={5}>
                  {damageNum(burnDamage)}
                </HealthStat>
                /
                <HealthStat inline align="center" type="brute" width={5}>
                  {damageNum(bruteDamage)}
                </HealthStat>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
        {!!hasOccupant && (
          <Section
            title="Detected Rejuvinators"
            buttons={
              <Button
                icon="syringe"
                align="center"
                color="good"
                disabled={!canInject}
                onClick={() => act('inject')}
              >
                Inject
              </Button>
            }
          >
            <Section height={10} scrollable>
              {!rejuvinators.length ? (
                "No rejuvinators detected in occupant's bloodstream."
              ) : (
                <LabeledList>
                  {rejuvinators.map((r) => (
                    <LabeledList.Item key={r.name} label={r.name}>
                      <Icon
                        name={!r.od || r.volume < r.od ? 'circle' : 'skull'}
                        color={r.color}
                      />
                      {' ' + r.volume.toFixed(3)}
                      {!!r.od && r.volume >= r.od && (
                        <Box inline color="bad" pl={1}>
                          (Overdose!)
                        </Box>
                      )}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              )}
            </Section>
            <Box italic textAlign="center" color="label" mt={2}>
              Use separate reagent scanner for complete analysis.
            </Box>
          </Section>
        )}
        <Section
          title="Occupant Alarm Clock"
          buttons={
            <Button
              width={8}
              icon="clock"
              align="center"
              color={isTiming ? 'bad' : 'good'}
              disabled={!hasOccupant || occupantStat > 1 || time <= 0}
              onClick={() => act('timer')}
            >
              {isTiming ? 'Stop Timer' : 'Start Timer'}
            </Button>
          }
        >
          <Flex>
            <Flex.Item>
              <Knob
                mr="0.5em"
                animated
                size={1.25}
                step={5}
                stepPixelSize={2}
                minValue={0}
                maxValue={maxTime / 10}
                value={curTime / 10}
                onDrag={(e, targetValue) =>
                  act('time_add', { tp: targetValue - curTime / 10 })
                }
              />
            </Flex.Item>
            <Flex.Item>
              <Box
                p={1}
                textAlign="center"
                backgroundColor="black"
                color="good"
                maxWidth="90px"
                width="90px"
                fontSize="20px"
              >
                <TimeDisplay
                  value={curTime}
                  auto={isTiming ? 'down' : undefined}
                  format={formatTime}
                />
              </Box>
            </Flex.Item>
            <Flex.Item shrink={1}>
              <Box italic textAlign="center" color="label" pl={1}>
                System will inject rejuvenators automatically when occupant is
                in hibernation.
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
