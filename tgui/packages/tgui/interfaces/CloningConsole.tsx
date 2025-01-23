/**
 * @file
 * @copyright 2020
 * @author Original ThePotato97 (https://github.com/ThePotato97)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @author Changes glowbold (https://github.com/pgmzeta)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';

import { useBackend, useSharedState } from '../backend';
import { HealthStat } from '../components/goonstation/HealthStat';
import { COLORS } from '../constants';
import { Window } from '../layouts';

interface CloningConsoleData {
  allowDeadScan: BooleanLike;
  allowMindErasure;
  allowedToDelete;
  balance;
  cloneHack;
  cloneRecords;
  clonesForCash;
  cloningWithRecords;
  completion;
  disk;
  diskReadOnly;
  geneticAnalysis;
  meatLevels;
  message;
  mindWipe;
  occupantScanned;
  podEfficient: BooleanLike[];
  podNames;
  podSpeed: BooleanLike[];
  scannerGone;
  scannerLocked;
  scannerOccupied;
}

const Suffixes = ['', 'k', 'M', 'B', 'T'];

export const shortenNumber = (value, minimumTier = 0) => {
  const tier = (Math.log10(Math.abs(value)) / 3) | 0;
  return tier === minimumTier
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

const TypedNoticeBox = (props) => {
  const { type, ...rest } = props;
  const typeProps = {
    ...(type === Types.Danger ? { danger: true } : {}),
    ...(type === Types.Info ? { info: true } : {}),
    ...(type === Types.Success ? { success: true } : {}),
  };
  return <NoticeBox {...typeProps} {...rest} />;
};

export const CloningConsole = () => {
  const { data, act } = useBackend<CloningConsoleData>();
  const {
    balance,
    cloneHack,
    clonesForCash,
    cloningWithRecords,
    allowedToDelete,
  } = data;

  // N.B. uses `deletionTarget` that is shared with Records component
  const [deletionTarget, setDeletionTarget] = useState('');
  const [viewingNote, setViewingNote] = useState<{
    id: string;
    note: string;
  } | null>(null);
  const [tab, setTab] = useSharedState('tab', Tab.Records);

  if (!cloningWithRecords && tab === Tab.Records) {
    setTab(Tab.Pods);
  }

  return (
    <Window
      theme={cloneHack.some(Boolean) ? 'syndicate' : 'ntos'}
      width={540}
      height={595}
    >
      <Window.Content>
        {deletionTarget && (
          <Modal mx={7} fontSize="31px">
            <Flex align="center">
              <Flex.Item mr={2} mt={1}>
                <Icon name="trash" />
              </Flex.Item>
              <Flex.Item>Delete Record?</Flex.Item>
            </Flex>
            <Box mt={2} textAlign="center" fontSize="24px">
              <Button
                lineHeight="40px"
                icon="check"
                color="good"
                onClick={() => {
                  act('delete', { id: deletionTarget });
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
        {viewingNote && (
          <Modal mx={7} width={25} fontSize="15px">
            <Button
              fontSize="26px"
              color="blue"
              onClick={() => setViewingNote(null)}
              style={{ position: 'absolute', top: '5px', right: '5px' }}
            >
              X
            </Button>
            {viewingNote.note}
            {!!allowedToDelete && (
              <Button
                color="bad"
                icon="trash"
                mx={1}
                onClick={() => {
                  act('deleteNote', { id: viewingNote.id });
                  setViewingNote(null);
                }}
              />
            )}
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
              <Section>Current machine credit: {balance}</Section>
            </Stack.Item>
          )}
          <Stack.Item>
            <StatusSection />
          </Stack.Item>
          <Stack.Item grow={1}>
            {tab === Tab.Records && !!cloningWithRecords && (
              <Records
                setDeletionTarget={setDeletionTarget}
                setViewingNote={setViewingNote}
              />
            )}
            {tab === Tab.Pods && <Pods />}
            {tab === Tab.Functions && <Functions />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Functions = () => {
  const { act, data } = useBackend<CloningConsoleData>();
  const {
    allowDeadScan,
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
            Enabling this feature will prompt the attached clone pod to transfer
            active genetic mutations from the genetic record to the subject
            during cloning.
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
      {!!allowDeadScan && (
        <Section title="Necrosis Scanning Module">
          <Box bold>Notice:</Box>
          <Box>
            Installation of the NecroScan II cloner upgrade module enables
            scanning of rotted and skeletal remains.
          </Box>
          <Box fontSize="0.9em">
            Disclaimer: Extreme genetic degredation is not covered by the
            NecroScan II cloner module.
          </Box>
        </Section>
      )}
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
      {!!disk && (
        <Section
          title="Disk Controls"
          buttons={
            <>
              {cloningWithRecords ? (
                <Button
                  icon="upload"
                  color={'blue'}
                  onClick={() => act('load')}
                >
                  Load from disk
                </Button>
              ) : (
                <Button
                  icon="upload"
                  color={'blue'}
                  onClick={() => act('loadAndClone')}
                >
                  Clone from disk
                </Button>
              )}
              <Button icon="eject" color={'bad'} onClick={() => act('eject')}>
                Eject Disk
              </Button>
            </>
          }
        >
          <Box>
            <Icon color={diskReadOnly ? 'bad' : 'good'} name={'check'} />
            {` ${diskReadOnly ? 'Disk is read only.' : 'Disk is writeable.'}`}
          </Box>
        </Section>
      )}
    </>
  );
};

const StatusSection = () => {
  const { act, data } = useBackend<CloningConsoleData>();
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
      <Section title="Status Messages" height={7}>
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
                position: 'relative',
                left: '50%',
                top: '50%',
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
        {!!cloningWithRecords &&
          (!!scannerGone || !!occupantScanned || !scannerOccupied) && (
            <Box>
              <Icon
                color={scannerGone || !scannerOccupied ? 'bad' : 'good'}
                name={scannerGone || !scannerOccupied ? 'times' : 'check'}
              />
              {` ${scannerGone ? 'No scanner detected.' : scannerOccupied ? 'Occupant scanned.' : 'Scanner has no occupant.'}`}
            </Box>
          )}
        {!scannerGone &&
          !occupantScanned &&
          !!scannerOccupied &&
          !!cloningWithRecords && (
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
        {!scannerGone && !!scannerOccupied && !cloningWithRecords && (
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

interface RecordsProps {
  setDeletionTarget: (data: string) => void;
  setViewingNote: (data: { note: string; id: string }) => void;
}

const Records = (props: RecordsProps) => {
  const { setDeletionTarget, setViewingNote } = props;
  const { act, data } = useBackend<CloningConsoleData>();
  const { disk, diskReadOnly, allowedToDelete, meatLevels } = data;
  const records = data.cloneRecords || [];
  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Section
          mb={0}
          title="Records"
          style={{ borderBottom: '2px solid rgba(51, 51, 51, 0.4);' }}
        >
          <Flex className="cloning-console__flex__head">
            <Flex.Item className="cloning-console__head__row" mr={2}>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ width: '190px' }}
              >
                Name
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ width: '160px' }}
              >
                <Box>Damage</Box>
                <Box
                  style={{
                    position: 'absolute',
                    left: '48%',
                    top: '20%',
                    transform: 'translate(-40%, 22px)',
                  }}
                  fontSize="9px"
                >
                  TOTAL : OXY / TOX / BURN / BRUTE
                </Box>
              </Flex.Item>
              <Flex.Item
                className="cloning-console__head__item"
                style={{ width: '180px' }}
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
                {records.map((record) => (
                  <Flex.Item
                    key={record.id}
                    className="cloning-console__body__row"
                  >
                    <Flex.Item
                      inline
                      className="cloning-console__body__item"
                      style={{ width: '190px' }}
                    >
                      {record.name}
                    </Flex.Item>
                    <Flex.Item
                      className="cloning-console__body__item"
                      style={{ width: '180px' }}
                    >
                      {record.implant && record.health.OXY >= 0 ? (
                        <Box inline>
                          {!!record.health.HealthImplant && (
                            <>
                              <Box
                                inline
                                align="center"
                                width={3}
                                color={healthToColor(
                                  record.health.OXY,
                                  record.health.TOX,
                                  record.health.BURN,
                                  record.health.BRUTE,
                                )}
                              >
                                {record.health.OXY +
                                  record.health.TOX +
                                  record.health.BURN +
                                  record.health.BRUTE}
                              </Box>
                              {':'}
                              <HealthStat
                                inline
                                align="center"
                                type="oxy"
                                width={2}
                              >
                                {shortenNumber(record.health.OXY)}
                              </HealthStat>
                              {'/'}
                              <HealthStat
                                inline
                                align="center"
                                type="toxin"
                                width={2}
                              >
                                {shortenNumber(record.health.TOX)}
                              </HealthStat>
                              {'/'}
                              <HealthStat
                                inline
                                align="center"
                                type="burn"
                                width={2}
                              >
                                {shortenNumber(record.health.BURN)}
                              </HealthStat>
                              {'/'}
                              <HealthStat
                                inline
                                align="center"
                                type="brute"
                                width={2}
                              >
                                {shortenNumber(record.health.BRUTE)}
                              </HealthStat>
                            </>
                          )}
                          {!record.health.HealthImplant && (
                            <>
                              <Box
                                inline
                                align="center"
                                width={3}
                                color={healthToColor(
                                  record.health.OXY,
                                  record.health.TOX,
                                  record.health.BURN,
                                  record.health.BRUTE,
                                )}
                              >
                                {record.health.OXY +
                                  record.health.TOX +
                                  record.health.BURN +
                                  record.health.BRUTE}
                              </Box>
                              {':'}
                              <Box
                                inline
                                align="center"
                                width={2}
                                color={COLORS.damageType['oxy']}
                              >
                                ??
                              </Box>
                              {'/'}
                              <Box
                                inline
                                align="center"
                                width={2}
                                color={COLORS.damageType['toxin']}
                              >
                                ??
                              </Box>
                              {'/'}
                              <Box
                                inline
                                align="center"
                                width={2}
                                color={COLORS.damageType['burn']}
                              >
                                ??
                              </Box>
                              {'/'}
                              <Box
                                inline
                                align="center"
                                width={2}
                                color={COLORS.damageType['brute']}
                              >
                                ??
                              </Box>
                            </>
                          )}
                        </Box>
                      ) : (
                        'No Implant Detected'
                      )}
                    </Flex.Item>
                    <Flex.Item
                      align="baseline"
                      className="cloning-console__body__item"
                      style={{ width: '180px' }}
                    >
                      {!!allowedToDelete && (
                        <>
                          <Button
                            icon="trash"
                            color="bad"
                            onClick={() => setDeletionTarget(record.id)}
                          />
                          <Button
                            icon="pencil"
                            color="blue"
                            onClick={() => act('editNote', { id: record.id })}
                            tooltip="Edit note"
                          />
                        </>
                      )}
                      {!!disk && (
                        <Button
                          icon={!!diskReadOnly || !!record.saved ? '' : 'save'}
                          color="blue"
                          textAlign="center"
                          width="22px"
                          disabled={record.saved || diskReadOnly}
                          onClick={() => act('saveToDisk', { id: record.id })}
                        >
                          {!diskReadOnly && !!record.saved && (
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
                        color={'good'}
                        disabled={!meatLevels.length}
                        onClick={() => act('clone', { id: record.id })}
                      >
                        Clone
                      </Button>
                      {!!record.note && (
                        <Button
                          color="blue"
                          circular
                          icon="circle-exclamation"
                          onClick={() =>
                            setViewingNote({ note: record.note, id: record.id })
                          }
                          tooltip="View note"
                        />
                      )}
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

const Pods = () => {
  const { data } = useBackend<CloningConsoleData>();
  const { completion, meatLevels, podNames, podSpeed, podEfficient } = data;

  if (!meatLevels.length) {
    return (
      <Section title="Cloning Pod Status">
        <Box>
          <Icon color="bad" name="times" />
          {' No Pod Detected'}
        </Box>
      </Section>
    );
  }

  return meatLevels.map((meat, i) => (
    <Section
      key={'pod' + i}
      title={podNames[i].replace(/cloning pod/, 'Cloning Pod') + ' Status'}
    >
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
            }}
          />
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
            }}
          />
        </LabeledList.Item>
        {(!!podSpeed[i] || !!podEfficient[i]) && (
          <LabeledList.Item label="Upgrades">
            {!!podSpeed[i] && 'SpeedyClone2000'}
            {!!podSpeed[i] && !!podEfficient[i] && ', '}
            {!!podEfficient[i] && 'Recycling Unit'}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  ));
};
