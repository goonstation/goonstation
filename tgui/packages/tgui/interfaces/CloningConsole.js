/**
* @file
* @copyright 2020
* @author Original ThePotato97 (https://github.com/ThePotato97)
* @author Changes Mordent (https://github.com/mordent-goonstation)
* @license ISC
*/

import { useBackend, useLocalState, useSharedState } from '../backend';
import { Box, Button, ColorBox, Flex, Icon, LabeledList, Modal, NoticeBox, ProgressBar, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { HealthStat } from './common/HealthStat';
import { clamp } from 'common/math';

const Suffixes = ['', 'k', 'M', 'B', 'T'];

export const shortenNumber = (value, minimumTier = 0) => {
  const tier = Math.log10(Math.abs(value)) / 3 | 0;
  return (tier === minimumTier)
    ? value
    : `${Math.round(value / Math.pow(10, tier * 3))}${Suffixes[tier]}`;
};

const healthColorByLevel = [
  '#17d568',
  '#2ecc71',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#ed2814',
];

const healthToColor = (oxy, tox, burn, brute) => {
  const healthSum = oxy + tox + burn + brute;
  const level = clamp(Math.ceil(healthSum / 25), 0, 5);
  return healthColorByLevel[level];
};

const Tab = {
  Functions: 'functions',
  Records: 'records',
  Pods: 'pods',
};

const Types = {
  Danger: 'danger',
  Info: 'info',
  Success: 'success',
};

const TypedNoticeBox = props => {
  const {
    type,
    ...rest
  } = props;
  const typeProps = {
    ...(type === Types.Danger ? { danger: true } : {}),
    ...(type === Types.Info ? { info: true } : {}),
    ...(type === Types.Success ? { success: true } : {}),
  };
  return <NoticeBox {...typeProps} {...rest} />;
};

export const CloningConsole = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    balance,
    cloneHack,
    clonesForCash,
    cloningWithRecords,
  } = data;

  // N.B. uses `deletionTarget` that is shared with Records component
  const [deletionTarget, setDeletionTarget] = useLocalState(context, 'deletionTarget', '');
  const [tab, setTab] = useSharedState(context, 'tab', Tab.Records);

  if (!cloningWithRecords && tab === Tab.Records) {
    setTab(Tab.Pods);
  }

  return (
    <Window
      theme={cloneHack.some(Boolean) ? 'syndicate' : 'ntos'}
      width={540}
      height={595}>
      <Window.Content>
        {deletionTarget && (
          <Modal
            mx={7}
            fontSize="31px"
          >
            <Flex align="center">
              <Flex.Item mr={2} mt={1}>
                <Icon name="trash" />
              </Flex.Item>
              <Flex.Item>Delete Record?</Flex.Item>
            </Flex>
            <Box
              mt={2}
              textAlign="center"
              fontSize="24px">
              <Button
                lineHeight="40px"
                icon="check"
                color="good"
                onClick={() => {
                  act('delete', { ckey: deletionTarget });
                  setDeletionTarget('');
                }}
              >
                Yes
              </Button>
              <Button
                width={8}
                align="center"
                mt={2}
                ml={5}
                lineHeight="40px"
                icon="times"
                color="bad"
                onClick={() => setDeletionTarget('')}
              >
                No
              </Button>
            </Box>
          </Modal>
        )}
        <Stack vertical fill>
          <Stack.Item>
            <Section fitted>
              <Tabs>
                {!!cloningWithRecords && (
                  <Tabs.Tab
                    icon="list"
                    selected={tab === Tab.Records}
                    onClick={() => setTab(Tab.Records)}
                  >
                    Records
                  </Tabs.Tab>
                )}
                <Tabs.Tab
                  icon="box"
                  selected={tab === Tab.Pods}
                  onClick={() => setTab(Tab.Pods)}
                >
                  Pods
                </Tabs.Tab>
                <Tabs.Tab
                  icon="wrench"
                  selected={tab === Tab.Functions}
                  onClick={() => setTab(Tab.Functions)}
                >
                  Functions
                </Tabs.Tab>
              </Tabs>
            </Section>
          </Stack.Item>
          {!!clonesForCash && (
            <Stack.Item>
              <Section>
                Current machine credit: {balance}
              </Section>
            </Stack.Item>
          )}
          <Stack.Item>
            <StatusSection />
          </Stack.Item>
          <Stack.Item grow={1}>
            {(tab === Tab.Records && !!cloningWithRecords) && <Records />}
            {tab === Tab.Pods && <Pods />}
            {tab === Tab.Functions && <Functions />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Functions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    allowMindErasure,
    disk,
    diskReadOnly,
    geneticAnalysis,
    mindWipe,
    cloningWithRecords,
  } = data;

  return (
    <>
      <Section title="Advanced Genetic Analysis">
        <Box>
          <Box bold>Notice:</Box>
          <Box>
            Enabling this feature will prompt the attached clone pod to
            transfer active genetic mutations from the genetic record to the
            subject during cloning.
          </Box>
          <Box>The cloning process will be slightly slower as a result.</Box>
        </Box>
        <Box pt={2}>
          <Button
            textAlign="center"
            width={6.7}
            icon={geneticAnalysis ? 'toggle-on' : 'toggle-off'}
            color={geneticAnalysis ? 'good' : 'bad'}
            onClick={() => act('toggleGeneticAnalysis')}
          >
            {geneticAnalysis ? 'Enabled' : 'Disabled'}
          </Button>
        </Box>
      </Section>
      {!!allowMindErasure && (
        <Section title="Criminal Rehabilitation Controls">
          <Box>
            <Box bold>Notice:</Box>
            <Box>
              Enabling this feature will enable an experimental criminal
              rehabilitation routine.
            </Box>
            <Box bold>
              Human use is specifically forbidden by the Space Geneva
              convention.
            </Box>
          </Box>
          <Box pt={2}>
            <Button
              textAlign="center"
              width={6.7}
              icon={mindWipe ? 'toggle-on' : 'toggle-off'}
              color={mindWipe ? 'good' : 'bad'}
              onClick={() => act('mindWipeToggle')}
            >
              {mindWipe ? 'Enabled' : 'Disabled'}
            </Button>
          </Box>
        </Section>
      )}
      {(!!disk) && (
        <Section
          title="Disk Controls"
          buttons={
            <>
              {cloningWithRecords ? (
                <Button
                  icon="upload"
                  color={"blue"}
                  onClick={() => act("load")}>
                  Load from disk
                </Button>
              ) : (
                <Button
                  icon="upload"
                  color={"blue"}
                  onClick={() => act("loadAndClone")}>
                  Clone from disk
                </Button>
              )}
              <Button
                icon="eject"
                color={"bad"}
                onClick={() => act("eject")}>
                Eject Disk
              </Button>
            </>
          }
        >
          <Box>
            <Icon
              color={diskReadOnly ? 'bad' : 'good'}
              name={'check'}
            />
            {' '}
            {diskReadOnly ? 'Disk is read only.' : 'Disk is writeable.'}
          </Box>
        </Section>
      )}
    </>
  );
};

const StatusSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    scannerLocked,
    occupantScanned,
    scannerOccupied,
    scannerGone,
    cloningWithRecords,
  } = data;

  const message = data.message || { text: '', status: '' };

  return (
    <>
      <Section
        title="Status Messages"
        height={7}
      >
        {message.text && (
          <TypedNoticeBox
            type={message.status}
            textColor="white"
            height={3.17}
            align="center"
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }}
          >
            <Box
              style={{
                position: 'relative', left: '50%', top: '50%',
                transform: 'translate(-50%, -50%)',
              }}
            >
              {message.text}
            </Box>
          </TypedNoticeBox>
        )}
      </Section>
      <Section
        title="Scanner Controls"
        buttons={
          <Button
            width={7}
            icon={scannerLocked ? 'unlock' : 'lock-open'}
            align="center"
            color={scannerLocked ? 'bad' : 'good'}
            onClick={() => act('toggleLock')}
          >
            {scannerLocked ? 'Locked' : 'Unlocked'}
          </Button>
        }
      >
        {(!!cloningWithRecords && (!!scannerGone || !!occupantScanned || !scannerOccupied)) && (
          <Box>
            <Icon
              color={(scannerGone || !scannerOccupied) ? 'bad' : 'good'}
              name={(scannerGone || !scannerOccupied) ? 'times' : 'check'}
            />
            {' '}
            {!!scannerGone && 'No scanner detected.'}
            {!scannerGone && (scannerOccupied ? 'Occupant scanned.' : 'Scanner has no occupant.')}
          </Box>
        )}
        {(!scannerGone && !occupantScanned && !!scannerOccupied && !!cloningWithRecords) && (
          <Button
            width={scannerGone ? 8 : 7}
            icon="dna"
            align="center"
            color={scannerGone ? 'bad' : 'good'}
            disabled={occupantScanned || scannerGone}
            onClick={() => act('scan')}
          >
            Scan
          </Button>
        )}
        {(!scannerGone && !!scannerOccupied && !cloningWithRecords) && (
          <Button
            icon="dna"
            align="center"
            color={'good'}
            onClick={() => act('scanAndClone')}
          >
            Scan & Clone
          </Button>
        )}
      </Section>
    </>
  );
};

const Records = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    disk,
    diskReadOnly,
    allowedToDelete,
    meatLevels,
  } = data;
  const records = data.cloneRecords || [];
  // N.B. uses `deletionTarget` that is shared with CloningConsole component
  const [, setDeletionTarget] = useLocalState(context, 'deletionTarget', '');

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Section
          mb={0}
          title="Records"
          style={{ 'border-bottom': '2px solid rgba(51, 51, 51, 0.4);' }}
        >
          <Flex className="cloning-console__flex__head">
            <Flex.Item className="cloning-console__head__row" mr={2}>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ 'width': '190px' }}
              >
                Name
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ 'width': '160px' }}
              >
                <Box>Damage</Box>
                <Box
                  style={{
                    position: 'absolute',
                    left: '50%',
                    top: '20%',
                    transform: 'translate(-40%, 22px)',
                  }}
                  fontSize="9px"
                >
                  OXY / TOX / BURN / BRUTE
                </Box>
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ 'width': '155px' }}
              >
                Actions
              </Flex.Item>
            </Flex.Item>
          </Flex>
        </Section>
      </Flex.Item>
      <Flex.Item grow={1}>
        <Section scrollable fill>
          <Flex>
            <Flex.Item className="cloning-console__flex__table">
              <Flex.Item>
                {records.map(record => (
                  <Flex.Item key={record.id} className="cloning-console__body__row">
                    <Flex.Item
                      inline
                      className="cloning-console__body__item"
                      style={{ 'width': '190px' }}
                    >
                      {record.name}
                    </Flex.Item>
                    <Flex.Item
                      className="cloning-console__body__item"
                      style={{ 'width': '160px' }}
                    >
                      <ColorBox
                        mr={1}
                        color={healthToColor(
                          record.health.OXY,
                          record.health.TOX,
                          record.health.BURN,
                          record.health.BRUTE,
                        )}
                      />
                      {
                        (record.implant && record.health.OXY >= 0)
                          ? (
                            <Box inline>
                              <HealthStat inline align="center" type="oxy" width={2}>
                                {shortenNumber(record.health.OXY)}
                              </HealthStat>
                              {"/"}
                              <HealthStat inline align="center" type="toxin" width={2}>
                                {shortenNumber(record.health.TOX)}
                              </HealthStat>
                              {"/"}
                              <HealthStat inline align="center" type="burn" width={2}>
                                {shortenNumber(record.health.BURN)}
                              </HealthStat>
                              {"/"}
                              <HealthStat inline align="center" type="brute" width={2}>
                                {shortenNumber(record.health.BRUTE)}
                              </HealthStat>
                            </Box>
                          )
                          : 'No Implant Detected'
                      }
                    </Flex.Item>
                    <Flex.Item
                      align="baseline"
                      className="cloning-console__body__item"
                      style={{ 'width': '155px' }}
                    >
                      {!!allowedToDelete && (
                        <Button
                          icon="trash"
                          color="bad"
                          onClick={() => setDeletionTarget(record.ckey)} />
                      )}
                      {!!disk && (
                        <Button
                          icon={(!!diskReadOnly || !!record.saved) ? '' : 'save'}
                          color="blue"
                          alignText="center"
                          width="22px"
                          disabled={record.saved || diskReadOnly}
                          onClick={() => act('saveToDisk', { ckey: record.ckey })}
                        >
                          {(!diskReadOnly && !!record.saved) && (
                            <Icon color="black" name="check" />
                          )}
                          {!!diskReadOnly && (
                            <Icon.Stack>
                              <Icon color="black" name="pen" />
                              <Icon color="black" name="slash" />
                            </Icon.Stack>
                          )}
                        </Button>
                      )}
                      <Button
                        icon="dna"
                        color={"good"}
                        disabled={!meatLevels.length}
                        onClick={() => act('clone', { ckey: record.ckey })}>
                        Clone
                      </Button>
                    </Flex.Item>
                  </Flex.Item>
                ))}
              </Flex.Item>
            </Flex.Item>
          </Flex>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const Pods = (props, context) => {
  const { data } = useBackend(context);
  const {
    completion,
    meatLevels,
    podNames,
  } = data;

  if (!meatLevels.length) {
    return (
      <Section title="Cloning Pod Status">
        <Box>
          <Icon color="bad"
            name="times" />
          {" No Pod Detected"}
        </Box>
      </Section>
    );
  }

  return meatLevels.map((meat, i) => (
    <Section key={"pod" + i} title={podNames[i].replace(/cloning pod/, "Cloning Pod") + " Status"}>
      <LabeledList>
        <LabeledList.Item label="Completion">
          <ProgressBar
            value={completion[i]}
            maxValue={100}
            minValue={0}
            ranges={{
              good: [90, Infinity],
              average: [25, 90],
              bad: [-Infinity, 25],
            }} />
        </LabeledList.Item>
        <LabeledList.Item label="Bio-Matter">
          <ProgressBar
            value={meat}
            maxValue={100}
            minValue={0}
            ranges={{
              good: [50, 100],
              average: [25, 50],
              bad: [0, 25],
            }} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ));
};
