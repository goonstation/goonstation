import { Fragment } from "inferno";
import { useBackend, useLocalState } from "../backend";
import { Button, LabeledList, Section, Modal, Flex, Tabs, Box, NoticeBox, Divider } from "../components";
import { Window } from "../layouts";

export const uiCurrentUserPermissions = data => {
  const {
    panelOpen,
    userStates,
  } = data;

  return {
    airlock: (userStates.isBorg) || (userStates.isAi),
    accessPanel: (
      (userStates.isBorg && userStates.distance <= 3 && panelOpen)
      || (userStates.isCarbon && panelOpen)
    ),
    // shows too far message on access panel when the mob is
    accessPanelNotTooFar: (
      userStates.isBorg && userStates.distance <= 1 && panelOpen
    ),
  };

};

export const Airlock = (props, context) => {
  const { data } = useBackend(context);

  const userPerms = uiCurrentUserPermissions(data);

  return (
    <Window>
      <Window.Content>
        {(userPerms["airlock"] && userPerms["accessPanel"])
          && <AirlockAndAccessPanel />
          || userPerms["airlock"] && <AirlockControlsOnly />
          || userPerms["accessPanel"] && <AccessPanelOnly />}
      </Window.Content>
    </Window>
  );
};


const AirlockAndAccessPanel = (props, context) => {
  const { data } = useBackend(context);
  const userPerms = uiCurrentUserPermissions(data);

  const {
    name,
    canAiControl,
    hackMessage,
    canAiHack,
    netId,
  } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex',
    (userPerms["airlock"] && userPerms["accessPanel"])
      ? 1
      : userPerms["airlock"]
        ? 1
        : userPerms["accessPanel"]
          ? 2
          : 1);
  return (
    <Window
      width={354}
      height={495}
      theme="ntos"
      title={"Airlock - " + name}>
      <Window.Content>
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
            onClick={() => {
              setTabIndex(2);
            }}>
            Access Panel
          </Tabs.Tab>
        </Tabs>
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
            <Section>
              {"Access sensor reports the net identifer is:"} <Box inline italic>{netId}</Box>
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

const AirlockControlsOnly = (props, context) => {
  const { data } = useBackend(context);

  const {
    name,
    canAiControl,
    hackMessage,
    canAiHack,
    netId,
  } = data;

  return (
    <Window
      width={354}
      height={405}
      theme="ntos"
      title={"Airlock - " + name}>
      <Window.Content>
        <Section fitted backgroundColor="rgba(0,0,0,0)">
          {(!canAiControl) && (
            <Modal
              textAlign="center"
              fontSize="24px">
              {hackMessage ? hackMessage : "Airlock Controls Disabled"}
              {!!canAiHack && (
                <Hack />
              )}
            </Modal>
          )}
          <PowerStatus />
          <AccessAndDoorControl />
          <Electrify />
        </Section>
        <Section>
          {"Access sensor reports the net identifer is:"} <Box inline italic>{netId}</Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const AccessPanelOnly = (props, context) => {
  const { data } = useBackend(context);
  const {
    name,
  } = data;

  return (
    <Window
      width={354}
      height={460}
      theme="ntos"
      title={"Airlock - " + name}>
      <Window.Content>
        <AccessPanel />
      </Window.Content>
    </Window>
  );
};

const PowerStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mainTimeLeft,
    backupTimeLeft,
    wires,
  } = data;

  return (
    <Section title="Power Status">
      <LabeledList>
        <LabeledList.Item
          label="Main"
          color={mainTimeLeft ? "bad" : "good"}
          buttons={(
            <Button
              py={0.5}
              width={6.7}
              align="center"
              color="bad"
              icon="plug"
              disabled={!!mainTimeLeft}
              onClick={() => act("disruptMain")}>
              Disrupt
            </Button>
          )}>
          {mainTimeLeft ? "Offline" : "Online"}
          {" "}
          {(!wires.main_1 || !wires.main_2)
            && "[Wires cut!]"
            || (mainTimeLeft > 0
              && `[${mainTimeLeft}s]`)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Backup"
          color={backupTimeLeft ? "bad": "good"}
          buttons={(
            <Button
              py={0.5}
              width={6.7}
              align="center"
              mt={0.5}
              color="bad"
              icon="plug"
              disabled={!!backupTimeLeft}
              onClick={() => act("disruptBackup")}>
              Disrupt
            </Button>
          )}>
          {backupTimeLeft ? "Offline" : "Online"}
          {" "}
          {(!wires.backup_1 || !wires.backup_2)
            && "[Wires cut!]"
            || (backupTimeLeft > 0
              && `[${backupTimeLeft}s]`)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const AccessAndDoorControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    mainTimeLeft,
    backupTimeLeft,
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
                || (mainTimeLeft && backupTimeLeft)}
              onClick={() => act("idScanToggle")}>
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
                || (mainTimeLeft && backupTimeLeft) || (isDisabled)}
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
                || (mainTimeLeft && backupTimeLeft) || (isDisabled)}
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
    mainTimeLeft,
    backupTimeLeft,
    wires,
    shockTimeLeft,
    netId,
  } = data;

  return (
    <NoticeBox danger>
      <Section m={-1} py={0.5}>
        <LabeledList>
          <LabeledList.Item
            color={shockTimeLeft ? "average" : "good"}
            label="Electrify">
            {!shockTimeLeft ? "Safe" : "Electrified"}
            {" "}
            {!wires.shock
            && "[Wires cut!]"
            || (shockTimeLeft > 0
            && `[${shockTimeLeft}s]`)
            || (shockTimeLeft === -1
            && "[Permanent]")}
          </LabeledList.Item>
          <LabeledList.Item
            color={!shockTimeLeft ? "Average" : "Bad"}>
            <Box
              pl={shockTimeLeft ? 21 : 0}
              pb={0}
              pt={0.5}>
              {(!shockTimeLeft &&(
                <Button.Confirm
                  p={1}
                  width={9}
                  align="center"
                  color="average"
                  content="Temporary"
                  confirmContent="Are you sure?"
                  icon="bolt"
                  disabled={(!wires.shock) || shockTimeLeft === -1
                || (mainTimeLeft && backupTimeLeft)}
                  onClick={(() => act("shockTemp"))} />
              ))}
              <Button.Confirm
                p={1}
                width={9}
                align="center"
                color={shockTimeLeft ? "good" : "bad"}
                icon="bolt"
                confirmContent="Are you sure?"
                content={shockTimeLeft ? "Restore" : "Permanent"}
                disabled={(!wires.shock)
                || (mainTimeLeft && backupTimeLeft)}
                onClick={shockTimeLeft ? (() => act("shockRestore"))
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
    <Box
      m={-1} py={0.5} pt={2}
      align="center">
      <Button
        bold
        color="bad"
        fontSize="25px"
        fontFamily="monospace"
        disabled={aiHacking}
        width={20}
        onClick={() => act("hackAirlock")}>
        {aiHacking ? "Hacking..." : "HACK"}
      </Button>
    </Box>
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
    canAiControl,
    safety,
    panelOpen,
  } = data;

  const userPerms = uiCurrentUserPermissions(data);

  const handleWireInteract = (wireColorIndex, action) => {
    act(action, { wireColorIndex });
  };

  const wires = Object.keys(wireColors);

  return (
    <Section
      title="Access Panel">
      {!userPerms["accessPanelNotTooFar"] && (
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
              color={canAiControl ? "green" : "red"}>
              {canAiControl ? "Enabled" : "Disabled"}
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

