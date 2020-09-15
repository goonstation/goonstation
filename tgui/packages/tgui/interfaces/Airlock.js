import { Fragment } from "inferno";
import { useBackend, useLocalState } from "../backend";
import { Button, LabeledList, Section, Modal, Flex, Tabs, Box, NoticeBox, Divider } from "../components";
import { Window } from "../layouts";

export const uiState = data => {
  const {
    panelOpen,
    userStates,
  } = data;

  // Borg within range and panel open
  if (userStates.isBorg && userStates.distance <= 1 && panelOpen) {
    return { "airlock": true, "accessPanel": true };
  }
  // Borg not within range can only access airlock controls
  if (userStates.isBorg && userStates.distance >= 2) {
    return { "airlock": true, "accessPanel": false };
  }
  // AI can only access airlock controls
  if (userStates.isAi) {
    return { "airlock": true, "accessPanel": false };
  }
  // Human
  if (userStates.isCarbon && panelOpen) {
    return { "airlock": false, "accessPanel": true };
  }
  return { "airlock": false, "accessPanel": false };
};

export const Airlock = (props, context) => {
  const { data } = useBackend(context);

  const {
    name,
    userStates,
    panelOpen,
    canAiControl,
    hackMessage,
    canAiHack,
  } = data;

  const currentState = uiState(data);

  // airlock + accessPanel = 1 / airlock = 1 / accessPanel = 2
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex',
    (currentState["airlock"] && currentState["accessPanel"])
      ? 1
      : currentState["airlock"]
        ? 1
        : currentState["accessPanel"]
          ? 2
          : 1);

  return (
    <Window
      width={354}
      height={485}
      theme="ntos"
      title={"Airlock - " + name}>
      <Window.Content>
        {!!userStates.isBorg && (
          <Tabs>
            <Tabs.Tab
              selected={tabIndex === 1}
              onClick={() => {
                setTabIndex(1);
              }}>
              Airlock Controls
            </Tabs.Tab>
            <Tabs.Tab
              selected={tabIndex === 2}
              disable={!panelOpen}
              onClick={() => {
                setTabIndex(2);
              }}>
              Access Panel
            </Tabs.Tab>
          </Tabs>
        )}
        {tabIndex === 1 && (
          <Fragment>
            <Section fitted backgroundColor="rgba(0,0,0,0)">
              {(!canAiControl) && (
                <Modal
                  textAlign="center"
                  fontSize="24px">
                  {hackMessage ? hackMessage : "Airlock Controls Disabled"}
                </Modal>
              )}
              <PowerStatus />
              <AccessAndDoorControl />
              <Electrify />
            </Section>
            {!!canAiHack && (
              <Hack />
            )}
          </Fragment>
        )}
        {tabIndex === 2 && (
          <AccessPanel />
        )}
      </Window.Content>
    </Window>
  );
};

const PowerStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mainTimeleft,
    backupTimeleft,
    wires,
  } = data;

  return (
    <Section title="Power Status">
      <LabeledList>
        <LabeledList.Item
          label="Main"
          color={mainTimeleft ? "bad" : "good"}
          buttons={(
            <Button
              py={0.5}
              width={6.7}
              align="center"
              color="bad"
              icon="plug"
              disabled={!!mainTimeleft}
              onClick={() => act("disruptMain")}>
              Disrupt
            </Button>
          )}>
          {mainTimeleft ? "Offline" : "Online"}
          {" "}
          {(!wires.main_1 || !wires.main_2)
            && "[Wires cut!]"
            || (mainTimeleft > 0
              && `[${mainTimeleft}s]`)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Backup"
          color={backupTimeleft ? "bad": "good"}
          buttons={(
            <Button
              py={0.5}
              width={6.7}
              align="center"
              mt={0.5}
              color="bad"
              icon="plug"
              disabled={!!backupTimeleft}
              onClick={() => act("disruptBackup")}>
              Disrupt
            </Button>
          )}>
          {backupTimeleft ? "Offline" : "Online"}
          {" "}
          {(!wires.backup_1 || !wires.backup_2)
            && "[Wires cut!]"
            || (backupTimeleft > 0
              && `[${backupTimeleft}s]`)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const AccessAndDoorControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mainTimeleft,
    backupTimeleft,
    wires,
    idScanner,
    boltsAreUp,
    opened,
    welded,
  } = data;

  const isDisabled = (data.status === 2);

  return (
    <Section title="Access and Door Control"
      pt={1}>
      <LabeledList>
        <LabeledList.Item
          label="ID Scan"
          color="bad"
          buttons={(
            <Button
              py={0.5}
              width={6.7}
              align="center"
              color={idScanner ? "good" : "bad"}
              icon={idScanner ? "power-off" : "times"}
              disabled={!wires.idScanner
                || (mainTimeleft && backupTimeleft)}
              onClick={() => act("idscanToggle")}>
              {idScanner ? "Enabled" : "Disabled"}
            </Button>
          )}>
          {!wires.idScanner && "[Wires cut!]"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Door Bolts"
          color="bad"
          buttons={(
            <Button
              py={0.5}
              mt={0.5}
              width={6.7}
              align="center"
              color={!boltsAreUp ? "bad" : "good"}
              icon={!boltsAreUp ? "unlock" : "lock"}
              disabled={!wires.bolts
                || (mainTimeleft && backupTimeleft) || (isDisabled)}
              onClick={() => act("boltToggle")}>
              {!boltsAreUp ? "Lowered" : "Raised"}
            </Button>
          )}>
          {!wires.bolts && "[Wires cut!]"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Door Control"
          color="bad"
          buttons={(
            <Button
              py={0.5}
              width={6.7}
              align="center"
              mt={0.5}
              color={opened ? "bad" : "good"}
              icon={opened ? "sign-out-alt" : "sign-in-alt"}
              disabled={(!boltsAreUp || welded)
                || (mainTimeleft && backupTimeleft) || (isDisabled)}
              onClick={() => act("openClose")}>
              {opened ? "Open" : "Closed"}
            </Button>
          )}>
          {!!(!boltsAreUp || welded) && (
            <span>
              [Door is {!boltsAreUp ? "bolted" : ""}
              {(!boltsAreUp && welded) ? " and " : ""}
              {welded ? "welded" : ""}!]
            </span>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};


const Electrify = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mainTimeleft,
    backupTimeleft,
    wires,
    shockTimeleft,
  } = data;

  return (
    <NoticeBox danger>
      <Section m={-1} py={0.5}>
        <LabeledList>
          <LabeledList.Item
            color={shockTimeleft ? "average" : "good"}
            label="Electrify">
            {!shockTimeleft ? "Safe" : "Electrified"}
            {" "}
            {!wires.shock
            && "[Wires cut!]"
            || (shockTimeleft > 0
            && `[${shockTimeleft}s]`)
            || (shockTimeleft === -1
            && "[Permanent]")}
          </LabeledList.Item>
          <LabeledList.Item
            color={!shockTimeleft ? "Average" : "Bad"}>
            <Box
              pl={shockTimeleft ? 21 : 0}
              pb={0}
              pt={0.5}>
              {(!shockTimeleft &&(
                <Button.Confirm
                  p={1}
                  width={9}
                  align="center"
                  color="average"
                  content="Temporary"
                  confirmContent="Are you sure?"
                  icon="bolt"
                  disabled={(!wires.shock) || shockTimeleft === -1
                || (mainTimeleft && backupTimeleft)}
                  onClick={(() => act("shockTemp"))} />
              ))}
              <Button.Confirm
                p={1}
                width={9}
                align="center"
                color={shockTimeleft ? "good" : "bad"}
                icon="bolt"
                confirmContent="Are you sure?"
                content={shockTimeleft ? "Restore" : "Permanent"}
                disabled={(!wires.shock)
                || (mainTimeleft && backupTimeleft)}
                onClick={shockTimeleft ? (() => act("shockRestore"))
                  : (() => act("shockPerm"))} />
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </NoticeBox>
  );
};


const Hack = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    aiHacking,
  } = data;

  return (
    <Section m={-1} py={0.5}>
      <Box
        align="center">
        <Button
          bold
          color="bad"
          fontSize="33px"
          fontFamily="monospace"
          disabled={aiHacking}
          width={20}
          py={0}
          onClick={() => act("hackAirlock")}>
          {aiHacking ? "Hacking..." : "HACK"}
        </Button>
      </Box>
    </Section>
  );
};

export const AccessPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    signalers,
    wireColors,
    wireStates,
    netId,
    powerIsOn,
    boltsAreUp,
    aiControlDisabled,
    safety,
    panelOpen,
  } = data;

  const currentState = uiState(data);

  const handleWireInteract = (wireColorIndex, action) => {
    act(action, { wireColorIndex });
  };

  const wires = Object.keys(wireColors);

  return (
    <Section
      title="Access Panel">
      {!currentState["accessPanel"] && (
        <Modal
          textAlign="center"
          fontSize="24px">
          {panelOpen ? "You can't reach" : "Access Panel is Closed"}
        </Modal>
      )}
      <Box>
        {"An identifier is engraved under the airlock's card sensors:"} <Box inline italic>{netId}</Box>
      </Box>
      <Divider />
      <LabeledList>
        { wires.map((entry, i) => (
          <LabeledList.Item
            key={entry}
            label={(entry + " wire")}
            labelColor={entry.toLowerCase()}>
            {
              !wireStates[i]
                ? (
                  <Box
                    height={1.8} >
                    <Button
                      icon="cut"
                      onClick={() => handleWireInteract(i, "cut")}>
                      Cut
                    </Button>
                    <Button
                      icon="bolt"
                      onClick={() => handleWireInteract(i, "pulse")}>
                      Pulse
                    </Button>
                    <Button
                      icon="broadcast-tower"
                      width={10.5}
                      className="airlock-wires-btn"
                      selected={!!(signalers[i])}
                      onClick={() => handleWireInteract(i, "signaler")}>
                      {!(signalers[i]) ? "Attach Signaler" : "Detach Signaler"}
                    </Button>
                  </Box>
                )
                : (
                  <Button
                    color="green"
                    height={1.8}
                    onClick={() => handleWireInteract(i, "mend")} >
                    Mend
                  </Button>
                )
            }
          </LabeledList.Item>
        )) }
      </LabeledList>
      <Divider />
      <Flex
        direction="row">
        <Flex.Item>
          <LabeledList>
            <LabeledList.Item
              label="Door bolts"
              color={boltsAreUp ? "green" : "red"}>
              {boltsAreUp ? "Disengaged" : "Engaged"}
            </LabeledList.Item>
            <LabeledList.Item
              label="Test light"
              color={powerIsOn ? "green" : "red"}>
              {powerIsOn ? "Active" : "Inactive"}
            </LabeledList.Item>
          </LabeledList>
        </Flex.Item>
        <Flex.Item>
          <LabeledList>
            <LabeledList.Item
              label="AI control"
              color={!aiControlDisabled ? "green" : "red"}>
              {!aiControlDisabled ? "Enabled" : "Disabled"}
            </LabeledList.Item>
            <LabeledList.Item
              label="Safety light"
              color={safety ? "green" : "red"}>
              {safety ? "Active" : "Inactive"}
            </LabeledList.Item>
          </LabeledList>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

