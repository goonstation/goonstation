/**
 * @file
 * @copyright 2023
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { toTitleCase } from 'common/string';
import {
  Box,
  Button,
  Divider,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  AntagonistData,
  AntagonistPanelData,
  GangLockerData,
  HeadsData,
  NuclearBombData,
  TabSectionData,
} from './type';

export const AntagonistTypeTabBody = (props: AntagonistPanelData) => {
  const { currentTabSections } = props;
  return (
    <Box>
      {currentTabSections ? (
        currentTabSections.map((section, index) => (
          <AntagonistTabSection key={index} {...section} />
        ))
      ) : (
        <GeneralInformation {...props} />
      )}
    </Box>
  );
};

const GeneralInformation = (props: AntagonistPanelData) => {
  const { gameMode, mortalityRates } = props;
  return (
    <>
      <Section>
        <Stack vertical align="center" my={3}>
          <Stack.Item mb={-2.5} italic>
            The Game Mode Is:
          </Stack.Item>
          <Stack.Item fontSize={2.75} bold>
            {toTitleCase(gameMode)}
          </Stack.Item>
        </Stack>
      </Section>
      <Stack justify="space-around">
        <Stack.Item grow>
          <Section title="Antagonist Mortality Rate">
            <ProgressBar
              minValue={0}
              maxValue={
                mortalityRates.antagonistsAlive +
                  mortalityRates.antagonistsDead || 1
              }
              value={mortalityRates.antagonistsDead}
              color="red"
              backgroundColor="green"
              mb={1}
            />
            <LabeledList>
              <LabeledList.Item label="Alive Antagonists">
                {mortalityRates.antagonistsAlive}
              </LabeledList.Item>
              <LabeledList.Item label="Dead Antagonists">
                {mortalityRates.antagonistsDead}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section title="Crew Mortality Rate">
            <ProgressBar
              minValue={0}
              maxValue={mortalityRates.crewAlive + mortalityRates.crewDead || 1}
              value={mortalityRates.crewDead}
              color="red"
              backgroundColor="green"
              mb={1}
            />
            <LabeledList>
              <LabeledList.Item label="Alive Crew">
                {mortalityRates.crewAlive}
              </LabeledList.Item>
              <LabeledList.Item label="Dead Crew">
                {mortalityRates.crewDead}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

const AntagonistTabSection = (props: TabSectionData) => {
  const { sectionType } = props;
  const SectionContents = getSectionComponent(sectionType);

  return <SectionContents {...props} />;
};

const AntagonistList = (props: TabSectionData) => {
  const { sectionData, sectionName } = props;
  const antagonistData: AntagonistData[] = sectionData;

  if (!antagonistData.length) {
    return;
  }

  const sortAntagonists =
    antagonistData.sort((a, b) =>
      (a.real_name ?? '').localeCompare(b.real_name ?? ''),
    ) || [];

  return (
    <Section>
      <Table>
        <Table.Row bold>
          <Table.Cell>{sectionName || 'Name'}</Table.Cell>
          <Table.Cell>Location</Table.Cell>
          <Table.Cell>Commands</Table.Cell>
        </Table.Row>
        <TableDividerRow />
        {sortAntagonists?.map((antagonist, index) => (
          <TableAntagonistEntry key={index} {...antagonist} />
        ))}
      </Table>
    </Section>
  );
};

const TableDividerRow = () => (
  <Table.Row>
    <Table.Cell>
      <Divider />
    </Table.Cell>
    <Table.Cell>
      <Divider />
    </Table.Cell>
    <Table.Cell>
      <Divider />
    </Table.Cell>
  </Table.Row>
);

const TableAntagonistEntry = (props: AntagonistData) => {
  const { antagonist_datum, has_subordinate_antagonists, mind_ref } = props;
  const { act, data } = useBackend<AntagonistPanelData>();

  const sortSubordinateAntagonists =
    data.subordinateAntagonists[antagonist_datum]?.sort((a, b) =>
      a.real_name.localeCompare(b.real_name),
    ) || [];

  return (
    <>
      <Table.Row>
        <Table.Cell py="0.5em">
          <Tooltip
            content={
              <LabeledList>
                <ClientTooltip {...props} />
                <JobTooltip {...props} />
              </LabeledList>
            }
          >
            <Box inline>
              {!!has_subordinate_antagonists && (
                <Button
                  width={2}
                  textAlign="center"
                  my={-0.5}
                  mr={0.8}
                  icon={
                    data.subordinateAntagonists[antagonist_datum]
                      ? 'chevron-down'
                      : 'chevron-right'
                  }
                  onClick={() =>
                    act(
                      `${
                        data.subordinateAntagonists[antagonist_datum]
                          ? 'unrequest_subordinate_antagonist_data'
                          : 'request_subordinate_antagonist_data'
                      }`,
                      { antagonist_datum },
                    )
                  }
                  tooltip="Subordinate Antagonists"
                />
              )}
              <PlayerName {...props} />
            </Box>
          </Tooltip>
        </Table.Cell>
        <TablePositionCell
          mind_ref={mind_ref}
          {...data.mindLocations[mind_ref]}
        />
        <TableButtonsCell {...props} />
      </Table.Row>
      {sortSubordinateAntagonists.map((antagonist, index) => (
        <Table.Row key={index}>
          <Table.Cell py="0.5em" pl={1.6}>
            <Tooltip
              content={
                <LabeledList>
                  <AntagonistRoleTooltip {...antagonist} />
                  <ClientTooltip {...antagonist} />
                  <JobTooltip {...antagonist} />
                </LabeledList>
              }
            >
              <Box inline>
                <Icon name="caret-right" mr={1.6} />
                <PlayerName {...antagonist} />
              </Box>
            </Tooltip>
          </Table.Cell>
          <TablePositionCell {...antagonist} />
          <TableButtonsCell {...antagonist} />
        </Table.Row>
      ))}
    </>
  );
};

const AntagonistRoleTooltip = (props) => {
  const { display_name } = props;

  return (
    <LabeledList.Item label="Antagonist Role">
      {toTitleCase(display_name)}
    </LabeledList.Item>
  );
};

const ClientTooltip = (props) => {
  const { ckey } = props;

  return (
    <LabeledList.Item label="Client">
      {ckey || (
        <Box inline italic>
          No Client
        </Box>
      )}
    </LabeledList.Item>
  );
};

const JobTooltip = (props) => {
  const { job } = props;

  return (
    <LabeledList.Item label="Job">
      {job || (
        <Box inline italic>
          N/A
        </Box>
      )}
    </LabeledList.Item>
  );
};

const PlayerName = (props) => {
  const { real_name, ckey, dead } = props;

  return (
    <Box inline>
      {!!dead && <Icon name="skull" />} {`${real_name} `}
      {!ckey && (
        <Box inline italic>
          (no client)
        </Box>
      )}
    </Box>
  );
};

const TablePositionCell = (props) => {
  const { mind_ref, area, coordinates } = props;
  const { act } = useBackend<AntagonistPanelData>();

  return (
    <Table.Cell>
      {area}
      <Button
        color="transparent"
        onClick={() => act('jump_to', { target: mind_ref })}
        tooltip="Jump To Position"
      >
        {coordinates}
      </Button>
    </Table.Cell>
  );
};

const TableButtonsCell = (props: AntagonistData) => (
  <Table.Cell>
    <AdminPMButton {...props} />
    <PlayerOptionsButton {...props} />
    <ViewVariablesButton {...props} />
  </Table.Cell>
);

const AdminPMButton = (props) => {
  const { mind_ref } = props;
  const { act } = useBackend<AntagonistPanelData>();

  return (
    <Button
      onClick={() => act('admin_pm', { mind_ref })}
      tooltip="Admin PM"
      mr={1}
    >
      PM
    </Button>
  );
};

const PlayerOptionsButton = (props) => {
  const { mind_ref } = props;
  const { act } = useBackend<AntagonistPanelData>();

  return (
    <Button
      width={2}
      textAlign="center"
      icon="user-gear"
      onClick={() => act('player_options', { mind_ref })}
      tooltip="Player Options"
      mr={1}
    />
  );
};

const ViewVariablesButton = (props) => {
  const { antagonist_datum } = props;
  const { act } = useBackend<AntagonistPanelData>();

  return (
    <Button
      width={2}
      textAlign="center"
      icon="gear"
      onClick={() => act('view_variables', { antagonist_datum })}
      tooltip="Antagonist Datum Vars"
    />
  );
};

const NuclearBombReadout = (props: TabSectionData) => {
  const { sectionData, sectionName } = props;
  const { act } = useBackend<AntagonistPanelData>();

  if (!sectionData) {
    return null;
  }

  const nuclearBombData: NuclearBombData = sectionData;

  return (
    <Section title={toTitleCase(sectionName)}>
      <Stack align="center">
        <Stack.Item>
          <Box
            textAlign="center"
            textColor="red"
            fontFamily="Consolas"
            fontSize={5}
            m={0.5}
            mr={2}
          >
            {nuclearBombData.timeRemaining}
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Health" verticalAlign="middle">
              <ProgressBar
                minValue={0}
                maxValue={nuclearBombData.maxHealth}
                value={nuclearBombData.health}
                color="green"
                backgroundColor="red"
                mb={1}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Location" verticalAlign="middle">
              {nuclearBombData.area}
              <Button
                color="transparent"
                onClick={() =>
                  act('jump_to', { target: nuclearBombData.nuclearBomb })
                }
                tooltip="Jump To Position"
              >
                {nuclearBombData.coordinates}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const HeadsList = (props: TabSectionData) => {
  const { sectionData } = props;
  const headsData: HeadsData[] = sectionData;

  if (!headsData.length) {
    return;
  }

  const headsOrder = [
    'Captain',
    'Head of Personnel',
    'Head of Security',
    'Chief Engineer',
    'Research Director',
    'Medical Director',
  ];

  const sortHeads =
    headsData.sort(
      (a, b) => headsOrder.indexOf(a.role) - headsOrder.indexOf(b.role),
    ) || [];

  return (
    <Section>
      <Table>
        <Table.Row bold>
          <Table.Cell> Role </Table.Cell>
          <Table.Cell> Name </Table.Cell>
          <Table.Cell> Location </Table.Cell>
          <Table.Cell> Commands </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Divider />
          </Table.Cell>
          <Table.Cell>
            <Divider />
          </Table.Cell>
          <Table.Cell>
            <Divider />
          </Table.Cell>
          <Table.Cell>
            <Divider />
          </Table.Cell>
        </Table.Row>
        {sortHeads?.map((head, index) => (
          <TableHeadEntry key={index} {...head} />
        ))}
      </Table>
    </Section>
  );
};

const TableHeadEntry = (props: HeadsData) => {
  const { mind_ref, role } = props;
  const { data } = useBackend<AntagonistPanelData>();

  return (
    <Table.Row>
      <Table.Cell py="0.5em">{toTitleCase(role)}</Table.Cell>
      <Table.Cell>
        <Tooltip
          content={
            <LabeledList>
              <ClientTooltip {...props} />
            </LabeledList>
          }
        >
          <Box inline>
            <PlayerName {...props} />
          </Box>
        </Tooltip>
      </Table.Cell>
      <TablePositionCell
        mind_ref={mind_ref}
        {...data.mindLocations[mind_ref]}
      />
      <Table.Cell>
        <AdminPMButton {...props} />
        <PlayerOptionsButton {...props} />
      </Table.Cell>
    </Table.Row>
  );
};

const GangReadout = (props: TabSectionData) => {
  const { sectionData, sectionName } = props;
  const gangData: TabSectionData[] = sectionData;

  if (!gangData.length) {
    return;
  }

  return (
    <Section title={sectionName}>
      {gangData.map((section, index) => (
        <AntagonistTabSection key={index} {...section} />
      ))}
    </Section>
  );
};

const GangLockerReadout = (props: TabSectionData) => {
  const { sectionData, sectionName } = props;
  const { act } = useBackend<AntagonistPanelData>();

  if (!sectionData) {
    return null;
  }

  const gangLockerData: GangLockerData = sectionData;

  return (
    <Section>
      <Box bold>{toTitleCase(sectionName)}</Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Location" verticalAlign="middle">
          {gangLockerData.area}
          <Button
            color="transparent"
            onClick={() =>
              act('jump_to', { target: gangLockerData.gangLocker })
            }
            tooltip="Jump To Position"
          >
            {gangLockerData.coordinates}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const getSectionComponent = (sectionType) => {
  if (sectionType === undefined) {
    return;
  }
  if (sectionType in sectionComponents) {
    return sectionComponents[sectionType];
  }
};

const sectionComponents = {
  AntagonistList: AntagonistList,
  NuclearBombReadout: NuclearBombReadout,
  HeadsList: HeadsList,
  GangReadout: GangReadout,
  GangLockerReadout: GangLockerReadout,
};
