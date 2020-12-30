import { useBackend } from "../backend";
import { Box, ColorBox, Button, Section, Knob, ProgressBar, LabeledList, Flex, Icon, TimeDisplay, HealthStat } from "../components";
import { Window } from "../layouts";
import { formatTime } from "../format";
import { clamp } from 'common/math';

const Suffixes = ["", "k", "M", "B", "T"];

export const shortenNumber = (value, minimumTier = 0) => {
  const tier = Math.log10(Math.abs(value)) / 3 | 0;
  return (tier === minimumTier) ? value
    : `${Math.round(value / Math.pow(10, tier * 3))}${Suffixes[tier]}`;
};

const healthColorByLevel = [
  "#17d568",
  "#2ecc71",
  "#e67e22",
  "#ed5100",
  "#e74c3c",
  "#ed2814",
];

const healthToColor = (oxy, tox, burn, brute) => {
  const healthSum = oxy + tox + burn + brute;
  const level = clamp(Math.ceil(healthSum / 25), 0, 5);
  return healthColorByLevel[level];
};

export const Sleeper = (props, context) => {
  const { data, act } = useBackend(context);
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
  } = data;

  const curTime = Math.max(timeStarted
    ? (time || 0) + timeStarted - timeNow
    : (time || 0), 0);
  const canInject = hasOccupant && !isTiming && !recharging && occupantStat < 2;

  return (
    <Window
      theme="ntos"
      width={440}
      height={440}>
      <Window.Content>
        <Section title="Occupant Statistics"
          buttons={
            <Button
              icon="eject"
              align="center"
              color="good"
              disabled={!hasOccupant || !!isTiming}
              onClick={() => act("eject")}>
              {"Eject"}
            </Button>
          }>
          {!hasOccupant && (sleeperGone ? "Check connection to sleeper pod." : "The sleeper is unoccupied.")}
          {!!hasOccupant && (
            <LabeledList>
              <LabeledList.Item label="Status">
                <Icon color={occupantStat > 1 ? "bad" : "good"}
                  name={occupantStat === 0 ? "check" : occupantStat === 1 ? "bed" : "skull"} />
                {
                  occupantStat === 0 ? " Conscious"
                    : occupantStat === 1 ? " Unconscious"
                      : occupantStat === 2 ? " Dead"
                        : (" Error " + occupantStat)
                }
              </LabeledList.Item>
              <LabeledList.Item label="Overall Health">
                <ProgressBar
                  value={health}
                  maxValue={100}
                  minValue={0}
                  ranges={{
                    good: [90, Infinity],
                    average: [50, 90],
                    bad: [-Infinity, 50],
                  }} />
              </LabeledList.Item>
              <LabeledList.Item label="Damage Breakdown">
                <HealthStat inline align="center" type="oxy" width={5}>
                  {shortenNumber(oxyDamage)}
                </HealthStat>
                {"/"}
                <HealthStat inline align="center" type="toxin" width={5}>
                  {shortenNumber(toxDamage)}
                </HealthStat>
                {"/"}
                <HealthStat inline align="center" type="burn" width={5}>
                  {shortenNumber(burnDamage)}
                </HealthStat>
                {"/"}
                <HealthStat inline align="center" type="brute" width={5}>
                  {shortenNumber(bruteDamage)}
                </HealthStat>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
        {!!hasOccupant && (
          <Section title="Detected Rejuvinators"
            buttons={
              <Button
                icon="syringe"
                align="center"
                color="good"
                disabled={!canInject}
                onClick={() => act("inject")}>
                {"Inject"}
              </Button>
            }>
            <Section height={10} level={2} scrollable>
              {!rejuvinators.length ? "No rejuvinators detected in occupant's bloodstream." : (
                <LabeledList>
                  {rejuvinators.map(r => (
                    <LabeledList.Item key={r.name} label={r.name}>
                      <Icon name={!r.od || r.volume < r.od ? "circle" : "skull"} color={r.color} />
                      {" " + r.volume.toFixed(3)}
                      {!!r.od && r.volume >= r.od && (
                        <Box inline color="bad" pl={1}>
                          {"(Overdose!)"}
                        </Box>
                      )}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              )}
            </Section>
            <Box italic textAlign="center" color="label" mt={2}>
              {"Use separate reagent scanner for complete analysis."}
            </Box>
          </Section>
        )}
        <Section title="Occupant Alarm Clock"
          buttons={
            <Button
              width={8}
              icon="clock"
              align="center"
              color={isTiming ? "bad" : "good"}
              disabled={!hasOccupant || occupantStat > 1 || time <= 0}
              onClick={() => act("timer")}>
              {isTiming ? "Stop Timer" : "Start Timer"}
            </Button>
          }>
          <Flex>
            <Flex.Item>
              <Knob
                mr="0.5em"
                animated
                size={1.25}
                step={5}
                stepPixelSize={2}
                minValue={0}
                maxValue={180}
                value={curTime / 10}
                onDrag={(e, targetValue) => act("time_add", { tp: targetValue - curTime / 10 })} />
            </Flex.Item>
            <Flex.Item>
              <Box
                p={1}
                textAlign="center"
                backgroundColor="black"
                color="good"
                maxWidth="90px"
                width="90px"
                fontSize="20px">
                <TimeDisplay value={curTime}
                  timing={!!isTiming}
                  format={value => formatTime(value)} />
              </Box>
            </Flex.Item>
            <Flex.Item shrink={1}>
              <Box italic textAlign="center" color="label" pl={1}>
                {"System will inject rejuvenators automatically when occupant is in hibernation."}
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
