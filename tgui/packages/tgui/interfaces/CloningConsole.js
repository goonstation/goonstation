import { Fragment } from "inferno";
import { useBackend, useSharedState } from "../backend";
import { truncate } from "../format.js";
import { Box, Button, ColorBox, Section, Table, Tabs, ProgressBar, NoticeBox, LabeledList, Tooltip, Flex, Modal, Icon } from "../components";
import { COLORS } from "../constants";
import { Window } from "../layouts";

let deletionTarget;

const HEALTH_COLOR_BY_LEVEL = [
  "#17d568",
  "#2ecc71",
  "#e67e22",
  "#ed5100",
  "#e74c3c",
  "#ed2814",
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
  const { data, act } = useBackend(context);
  const {
    cloneSlave,
    message,
    clones_for_cash,
    balance,
  } = data;

  const [tab, setTab] = useSharedState(context, "tab", "checkRecords");

  const clearTarget = function () {
    deletionTarget = "";
  };

  return (
    <Window
      theme={cloneSlave ? "syndicate" : "ntos"}
      width={550}
      height={550}>
      <Window.Content scrollable>
        {message && (
          <NoticeBox info textAlign="center">
            {message}
          </NoticeBox>
        )}
        {(deletionTarget && (
          <Modal
            fontSize="31px">
            <Flex align="center">
              <Flex.Item mr={2} mt={1}>
                <Icon
                  name="trash" />
              </Flex.Item>
              <Flex.Item>
                {'Delete Record?'}
              </Flex.Item>
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
                  act("delete", { ckey: deletionTarget });
                  clearTarget();
                }}>
                Yes
              </Button>
              <Button
                lineHeight="40px"
                icon="times"
                color="bad"
                onClick={() => clearTarget()}>
                No
              </Button>
            </Box>
          </Modal>
        ))}
        <Section fitted>
          {/* draws the tabs at the top of the gui */}
          <Tabs>
            <Tabs.Tab
              icon="list"
              textColor={tab === "checkRecords"
              && "white"}
              selected={tab === "Records"}
              onClick={() => setTab("checkRecords")}>
              Records
            </Tabs.Tab>
            <Tabs.Tab
              icon="wrench"
              textColor={tab === "checkFunctions"
              && "white"}
              selected={tab === "Functions"}
              onClick={() => setTab("checkFunctions")}>
              Functions
            </Tabs.Tab>
          </Tabs>
        </Section>
        {/* used for the wagesystem */}
        {(clones_for_cash && (
          <Section>
            Current machine credit: {balance}
          </Section>
        ))}
        <StatusSection />
        {tab === "checkRecords" && (
          <Records />
        )}
        {tab === "checkFunctions" && (
          <Functions />
        )}
      </Window.Content>
    </Window>
  );
};


const Functions = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    geneticAnalysis,
    disk,
    allowMindErasure,
    mindWipe,
  } = data;

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
            icon={geneticAnalysis ? "toggle-on" : "toggle-off"}
            color={geneticAnalysis ? "good" : "bad"}
            onClick={() => act("toggleGeneticAnalysis")}>
            {geneticAnalysis ? "Enabled" : "Disabled"}
          </Button>
        </Box>
      </Section>
      {/* will only be active if the minderaser module is installed */}
      {(!!allowMindErasure && (
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
              icon={mindWipe ? "toggle-on" : "toggle-off"}
              color={mindWipe ? "good" : "bad"}
              onClick={() => act("mindWipeToggle")}>
              {mindWipe ? "Enabled" : "Disabled"}
            </Button>
          </Box>
        </Section>
      ))}
      {(!!disk && (
        <Section
          title="Disk Controls">
          <Button
            icon="upload"
            color={"blue"}
            onClick={() => act("load")}>
            Load from disk
          </Button>
          <Button
            icon="eject"
            color={"red"}
            onClick={() => act("eject")}>
            Eject Disk
          </Button>
        </Section>
      ))}
    </Fragment>
  );
};

const StatusSection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    completion,
    meatLevels,
    scannerLocked,
    occupantScanned,
    scannerOccupied,
    scannerGone,
    podGone,
  } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Completion">
          {!podGone && (
            <ProgressBar
              value={completion}
              maxValue={100}
              minValue={0}
              ranges={{
                good: [90, Infinity],
                average: [25, 90],
                bad: [-Infinity, 25],
              }} />
          )}
          {!!podGone && (
            "No Pod Detected"
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Biomatter">
          {!podGone && (
            <ProgressBar
              value={meatLevels}
              maxValue={100}
              minValue={0}
              ranges={{
                good: [50, 100],
                average: [25, 50],
                bad: [0, 25],
              }} />
          )}
          {!!podGone && (
            "No Pod Detected"
          )}
        </LabeledList.Item>
      </LabeledList>
      <Box pt={2}>
        <Button
          width={7}
          icon="dna"
          align={"center"}
          color={(occupantScanned ? "average" : (scannerGone ? "bad" : "good"))}
          disabled={occupantScanned | scannerGone}
          onClick={() => act("scan")}>
          {(occupantScanned ? "Scanned" : (scannerGone ? "No Scanner" : "Scan"))}
        </Button>
        <Button
          width={7}
          icon={scannerLocked ? "unlock" : "lock-open"}
          align={"center"}
          disabled={!scannerOccupied}
          color={scannerLocked ? "bad" : "good"}
          onClick={() => act("toggleLock")}>
          {scannerLocked ? "Locked" : "Unlocked"}
        </Button>
      </Box>
    </Section>
  );
};

const Records = (props, context) => {
  const { act, data } = useBackend(context);
  const records = data.cloneRecords || [];
  const {
    disk,
    podGone,
    diskReadOnly,
  } = data;

  return (
    <Section title="Records">
      <Table>
        <Table.Row>
          <Table.Cell bold collapsing textAlign="center">
            Name
          </Table.Cell>
          <Table.Cell collapsing />
          <Table.Cell bold textAlign="center">
            Damage
          </Table.Cell>
          <Table.Cell bold textAlign="center">
            Actions
          </Table.Cell>
        </Table.Row>
        {records.map(record => (
          <Table.Row key={record.name}>
            <Table.Cell collapsing textAlign="center">
              <Box
                position="relative">
                {record.id}-{truncate(record.name, 15)}
                {/* shorten down that name so it doesn"t break the damn gui */}
                {record.name.length > 20 && (
                  <Tooltip
                    overrideLong
                    position="right"
                    content={truncate(record.name.toLowerCase(), 39)} />
                /* if you have a name over 39 chars fuckyou cause itll not shw*/
                )}
              </Box>
            </Table.Cell>
            <Table.Cell collapsing textAlign="center" px={-5}>
              <ColorBox
                mx={1}
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
                  {"/"}
                  <HealthStat type="toxin" value={record.health.TOX} />
                  {"/"}
                  <HealthStat type="burn" value={record.health.BURN} />
                  {"/"}
                  <HealthStat type="brute" value={record.health.BRUTE} />
                </Box>
              ) : (
                "No Implant Detected"
              )}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <Button
                icon="trash"
                mt={1.2}
                color={"bad"}
                onClick={() => (deletionTarget = record.ckey)}>
                Delete
              </Button>
              {(!!disk && (
                <Button
                  icon="save"
                  mt={1.2}
                  color={"blue"}
                  disabled={record.saved || diskReadOnly}
                  onClick={() => act("saveToDisk", { ckey: record.ckey })}>
                  {record.saved ? (diskReadOnly ? "Read Only" : "Saved") : (diskReadOnly ? "Read Only" : "Save")}
                </Button>
              ))}
              <Button
                icon="dna"
                mt={1.2}
                color={"good"}
                disabled={podGone}
                onClick={() => act("clone", { ckey: record.ckey })}>
                Clone
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
