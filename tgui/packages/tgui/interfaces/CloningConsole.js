/**
* @file
* @copyright 2020
* @author ThePotato97 (https://github.com/ThePotato97)
* @license ISC
*/

import { Fragment } from "inferno";
import { useBackend, useSharedState, useLocalState } from "../backend";
import { Box, Button, ColorBox, Section, Tabs, ProgressBar, NoticeBox, LabeledList, Flex, Modal, Icon, HealthStat } from "../components";
import { Window } from "../layouts";
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

const Types = {
  Danger: 'danger',
  Info: 'info',
  Success: 'success',
};

// future proofing a better way of setting type by mordent

export const TypedNoticeBox = props => {
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

TypedNoticeBox.Types = Types;

export const CloningConsole = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    cloneSlave,
    clonesForCash,
    balance,
  } = data;
  const [
    deletionTarget,
    setDeletionTarget,
  ] = useLocalState(context, 'deletionTarget', '');

  const [tab, setTab] = useSharedState(context, "tab", "checkRecords");

  return (
    <Window
      theme={cloneSlave ? "syndicate" : "ntos"}
      width={550}
      height={530}>
      <Window.Content>
        {(deletionTarget && (
          <Modal
            mx={7}
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
                  setDeletionTarget("");
                }}>
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
                onClick={() => {
                  setDeletionTarget("");
                }}>
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
        {/* used for the wage system */}
        {(!!clonesForCash && (
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
            textAlign="center"
            width={6.7}
            icon={geneticAnalysis ? "toggle-on" : "toggle-off"}
            color={geneticAnalysis ? "good" : "bad"}
            onClick={() => act("toggleGeneticAnalysis")}>
            {geneticAnalysis ? "Enabled" : "Disabled"}
          </Button>
        </Box>
      </Section>
      {/* will only be active if the mind eraser module is installed */}
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
              textAlign="center"
              width={6.7}
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

  const message = data.message || { text: "", status: "" };

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
        <LabeledList.Item label="Bio-Matter">
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
      <Flex>
        <Flex.Item mt={3.5} width={scannerGone ? 16 : 15}>
          <Button
            width={scannerGone ? 8 : 7}
            icon="dna"
            align={"center"}
            color={scannerGone ? "bad" : "good"}
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
        </Flex.Item>
        <Flex.Item width={25} mt={2} height={1} ml={5}>
          {message.text && (
            <TypedNoticeBox
              type={message.status}
              textColor="white"
              width={25.45}
              height={3.17}
              align="center"
              style={{
                'vertical-align': 'middle',
                'horizontal-align': 'middle',
              }}>
              <Box
                style={{
                  position: 'relative', left: '50%', top: '50%',
                  transform: 'translate(-50%, -50%)',
                }}>
                {message.text}
              </Box>
            </TypedNoticeBox>
          )}
        </Flex.Item>
      </Flex>
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
  const [,
    setDeletionTarget] = useLocalState(context, 'deletionTarget', '');

  return (
    <Fragment>
      <Section mb={0}>
        <Flex>
          <Flex.Item className="Cloning-Console_HeadRow" mr={2}>
            <Flex.Item className="Cloning-Console_HeadRow_Item"
              style={{ 'width': '190px' }}>
              Name
            </Flex.Item>
            <Flex.Item className="Cloning-Console_HeadRow_Item"
              style={{ 'width': '150px' }}>
              Damage
            </Flex.Item>
            <Flex.Item className="Cloning-Console_HeadRow_Item"
              style={{ 'width': '205px' }}>
              Actions
            </Flex.Item>
          </Flex.Item>
        </Flex>
      </Section>
      <Section scrollable>
        <Flex>

          <Flex.Item className="Cloning-Console_FlexTable">

            <Flex.Item className="Cloning-Console_Body">
              {records.map(record => (
                <Flex.Item key={record.id} className="Cloning-Console_BodyRow">
                  <Flex.Item inline className="Cloning-Console_BodyRow_Item"
                    style={{ 'width': '190px', 'height': '15px' }}>
                    {record.name}
                  </Flex.Item>
                  <Flex.Item
                    className="Cloning-Console_BodyRow_Item"
                    style={{ 'width': '150px' }}>
                    <ColorBox
                      mr={1}
                      color={healthToColor(
                        record.health.OXY,
                        record.health.TOX,
                        record.health.BURN,
                        record.health.BRUTE)} />
                    {record.implant ? (
                      <Box inline>
                        <HealthStat inline align="center" type="oxy" width={2}
                          content={shortenNumber(record.health.OXY)} />
                        {"/"}
                        <HealthStat inline align="center" type="toxin" width={2}
                          content={shortenNumber(record.health.TOX)} />
                        {"/"}
                        <HealthStat inline align="center" type="burn" width={2}
                          content={shortenNumber(record.health.BURN)} />
                        {"/"}
                        <HealthStat inline align="center" type="brute" width={2}
                          content={shortenNumber(record.health.BRUTE)} />
                      </Box>
                    ) : (
                      "No Implant Detected"
                    )}
                  </Flex.Item>
                  <Flex.Item className="Cloning-Console_BodyRow_Item"
                    style={{ 'width': '205px' }}>
                    <Button
                      icon="trash"
                      color={"bad"}
                      onClick={() =>
                      { setDeletionTarget(record.ckey);
                      }}>
                      Delete
                    </Button>
                    {(!!disk && (
                      <Button
                        icon="save"
                        color={"blue"}
                        disabled={record.saved || diskReadOnly}
                        onClick={() => act("saveToDisk", { ckey: record.ckey })}>
                        {record.saved ? (diskReadOnly ? "Read Only" : "Saved") : (diskReadOnly ? "Read Only" : "Save")}
                      </Button>
                    ))}
                    <Button
                      icon="dna"
                      color={"good"}
                      disabled={podGone}
                      onClick={() => act("clone", { ckey: record.ckey })}>
                      Clone
                    </Button>
                  </Flex.Item>
                </Flex.Item>
              ))}
            </Flex.Item>
          </Flex.Item>
        </Flex>
      </Section>
    </Fragment>
  );
};
