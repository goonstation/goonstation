import { Fragment } from 'inferno';
import { useBackend, useSharedState } from '../backend';
import { truncate } from '../format.js';
import { Box, Button, ColorBox, Section, Table, Tabs, ProgressBar, NoticeBox, AnimatedNumber, LabeledList, Tooltip } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';

const HEALTH_COLOR_BY_LEVEL = [
  '#17d568',
  '#2ecc71',
  '#e67e22',
  '#ed5100',
  '#e74c3c',
  '#ed2814',
];

const healthToColor = (oxy, tox, burn, brute) => {
  const healthSum = oxy + tox + burn + brute;
  const level = Math.min(Math.max(Math.ceil(healthSum / 25), 0), 5);
  return HEALTH_COLOR_BY_LEVEL[level];
};

const HealthStat = props => {
  const { type, value } = props;
  return (
    <Box
      inline
      width={2}
      color={COLORS.damageType[type]}
      textAlign="center">
      {value}
    </Box>
  );
};

export const CloningConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const error = data.Message;
  const [tab, setTab] = useSharedState(context, 'tab', 'check-records');
  const IsCloneSlaved = Boolean(data.cloneslave);
  return (
    <Window
      theme={IsCloneSlaved ? 'syndicate' : ''}
      width={540}
      height={550}>
      <Window.Content scrollable>
        {error && (
          <NoticeBox info textAlign="center">
            {error}
          </NoticeBox>
        )}
        <Section fitted>
          {/* draws the tabs at the top of the gui */}
          <Tabs>
            <Tabs.Tab
              icon="list"
              textColor={tab === 'check-records'
              && 'white'}
              selected={tab === 'Records'}
              onClick={() => setTab('check-records')}>
              Records
            </Tabs.Tab>
            <Tabs.Tab
              icon="wrench"
              textColor={tab === 'check-functions'
              && 'white'}
              selected={tab === 'Functions'}
              onClick={() => setTab('check-functions')}>
              Functions
            </Tabs.Tab>
          </Tabs>
        </Section>
        {/* used for the wagesystem */}
        {(!!data.clones_for_cash && (
          <Section>
            Current machine credit: {data.balance}
          </Section>
        ))}
        <UpperBar />
        {tab === 'check-records' && (
          <Records />
        )}
        {tab === 'check-functions' && (
          <Functions />
        )}
      </Window.Content>
    </Window>
  );
};


const Functions = (props, context) => {
  const { act, data } = useBackend(context);
  const GeneticAnalysis = Boolean(data.GeneticAnalysis);
  const DiskInserted = Boolean(data.Disk);
  const AllowMindErasure = Boolean(data.AllowMindErasure);
  const WipeActive = Boolean(data.MindWipe);
  return (
    <Fragment>
      <Section
        title="Advanced Genetic Analysis">
        <Box>
          <Box bold>Notice:</Box>
          <Box>Enabling this feature will prompt the attached clone pod to
            transfer active genetic mutations from the genetic record to the
            subject during cloning.
          </Box>
          <Box>The cloning process will be slightly slower as a result.</Box>
        </Box>
        <Box pt={2}>
          <Button
            content={GeneticAnalysis ? 'Enabled' : 'Disabled'}
            onClick={() => act('ToggleGeneticAnalysis')} />
        </Box>
      </Section>
      {/* will only be active if the minderaser module is installed */}
      {(!!AllowMindErasure && (
        <Section
          title="Criminal Rehabilitation Controls">
          <Box>
            <Box bold>Notice:</Box>
            <Box>Enabling this feature will enable an experimental criminal
              rehabilitation routine.
            </Box>
            <Box bold>Human use is specifically forbidden by the space geneva
              convention.
            </Box>
          </Box>
          <Box pt={2}>
            <Button
              content={WipeActive ? 'Enabled' : "Disabled"}
              onClick={() => act('MindWipeToggle')} />
          </Box>
        </Section>
      ))}
      {(!!DiskInserted && (
        <Section
          title="Disk Controls">
          <Button
            content={"Load from disk"}
            onClick={() => act('load')} />
          <Button
            content={"Eject Disk"}
            onClick={() => act('eject')} />
        </Section>
      ))}
    </Fragment>
  );
};

const UpperBar = (props, context) => {
  const { act, data } = useBackend(context);
  const message = data.Message;
  const PercentageComp = data.Completion;
  const MeatLevels = data.MeatLevels;
  const ScannerLocked = Boolean(data.ScannerLocked);
  const OccupantScanned = data.OccupantScanned;
  const ScannerOccupied = data.ScannerOccupied;
  const ScannerGone = Boolean(data.ScannerGone);
  const PodGone = Boolean(data.PodGone);

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Completion">
          {!PodGone && (
            <ProgressBar
              value={PercentageComp}
              maxValue={100}
              minValue={0}
              ranges={{
                good: [90, Infinity],
                average: [25, 90],
                bad: [-Infinity, 25],
              }}>
              <AnimatedNumber value={Math.round(PercentageComp)} />%
            </ProgressBar>
          )}
          {PodGone && (
            'No Pod Detected'
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Biomatter">
          {!PodGone && (
            <ProgressBar
              value={MeatLevels}
              maxValue={100}
              minValue={0}
              ranges={{
                good: [50, 100],
                average: [25, 50],
                bad: [0, 25],
              }}>
              <AnimatedNumber value={Math.round(MeatLevels)} />%
            </ProgressBar>
          )}
          {PodGone && (
            'No Pod Detected'
          )}
        </LabeledList.Item>
      </LabeledList>
      <Box pt={2}>
        <Button px={(OccupantScanned ? 2 : (ScannerGone ? 1 : 3.8))}
          disabled={OccupantScanned | ScannerGone}
          content={(OccupantScanned ? 'Scanned' : (ScannerGone ? 'No Scanner Detected' : 'Scan'))}
          onClick={() => act('scan')} />
        <Button px={ScannerLocked ? 3.1 : 2}
          disabled={!ScannerOccupied}
          content={ScannerLocked ? 'Locked' : 'Unlocked'}
          onClick={() => act('ToggleLock')} />
      </Box>
    </Section>
  );
};

const Records = (props, context) => {
  const { act, data } = useBackend(context);
  const records = data.clone_records || [];
  const DiskInserted = Boolean(data.Disk);

  return (
    <Section title="Records">
      <Table>
        <Table.Row>
          <Table.Cell bold>
            Name
          </Table.Cell>
          <Table.Cell bold collapsing />
          <Table.Cell bold collapsing textAlign="center">
            Vitals
          </Table.Cell>
          <Table.Cell bold collapsing>
            Delete
          </Table.Cell>
          {(!!DiskInserted && (
            <Table.Cell bold collapsing textAlign="center">
              Save
            </Table.Cell>
          ))}
          <Table.Cell bold collapsing textAlign="center">
            Clone
          </Table.Cell>
        </Table.Row>
        {records.map(record => (
          <Table.Row key={record.name}>
            <Table.Cell collapsing textAlign="center">
              {record.id}-{truncate(record.name, 20)}
              {/* shorten down that name so it doesn't break the damn gui */}
              {record.name.length > 20 && (
                <Tooltip
                  overrideLong
                  position="bottom"
                  content={truncate(record.name, 64)} />
              /* if you have a name over 64 chars fuckyou cause it'll not show*/
              )}
            </Table.Cell>
            <Table.Cell collapsing textAlign="center">
              <ColorBox
                color={healthToColor(
                  record.health.OXY,
                  record.health.TOX,
                  record.health.BURN,
                  record.health.BRUTE)} />
            </Table.Cell>
            <Table.Cell collapsing textAlign="center">
              {record.implant ? (
                <Box inline>
                  <HealthStat type="oxy" value={record.health.OXY} />
                  {'/'}
                  <HealthStat type="toxin" value={record.health.TOX} />
                  {'/'}
                  <HealthStat type="burn" value={record.health.BURN} />
                  {'/'}
                  <HealthStat type="brute" value={record.health.BRUTE} />
                </Box>
              ) : (
                'No Implant Detected'
              )}
            </Table.Cell>
            <Table.Cell>
              <Box inline>
                <Button
                  mt={1.2}
                  content={"Delete"}
                  onClick={() => act('delete', { ckey: record.ckey })} />
              </Box>
            </Table.Cell>
            {(!!DiskInserted && (
              <Table.Cell textAlign="center">
                <Box>
                  <Button
                    mt={1.2}
                    content={record.saved ? 'Saved' : 'Save'}
                    disabled={record.saved}
                    onClick={() => act('SaveToDisk', { ckey: record.ckey })} />
                </Box>
              </Table.Cell>
            ))}
            <Table.Cell textAlign="center">
              <Box inline>
                <Button
                  mt={1.2}
                  content={"Clone"}
                  onClick={() => act('clone', { ckey: record.ckey })} />
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
