import { Fragment } from "inferno";
import { useBackend } from "../backend";
import { Button, LabeledList, Section, Modal, Flex, Icon, Box, NoticeBox } from "../components";
import { Window } from "../layouts";


export const AiAirlock = (props, context) => {
  const { data } = useBackend(context);
  const {
    name,
  } = data;
  return (
    <Window
      width={314}
      height={335}
      theme="ntos"
      title={"Airlock - " + name}>
      <Window.Content>
        <PowerStatus />
        <AccessAndDoorControl />
        <Electrify />
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
            && "[Wires have been cut!]"
            || (mainTimeleft > 0
              && `[${mainTimeleft}s]`)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Backup"
          color={backupTimeleft ? "bad": "good"}
          buttons={(
            <Button
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
            && "[Wires have been cut!]"
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
    locked,
    opened,
    welded,
  } = data;

  const isDisabled = (data.status === 2);

  return (
    <Section title="Access and Door Control">
      <LabeledList>
        <LabeledList.Item
          label="ID Scan"
          color="bad"
          buttons={(
            <Button
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
          {!wires.idScanner && "[Wires have been cut!]"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Door Bolts"
          color="bad"
          buttons={(
            <Button
              mt={0.5}
              width={6.7}
              align="center"
              color={locked ? "bad" : "good"}
              icon={locked ? "unlock" : "lock"}
              disabled={!wires.bolts
                || (mainTimeleft && backupTimeleft) || (isDisabled)}
              onClick={() => act("boltToggle")}>
              {locked ? "Lowered" : "Raised"}
            </Button>
          )}>
          {!wires.bolts && "[Wires have been cut!]"}
        </LabeledList.Item>
        <LabeledList.Item
          label="Door Control"
          color="bad"
          buttons={(
            <Button
              width={6.7}
              align="center"
              mt={0.5}
              color={opened ? "bad" : "good"}
              icon={opened ? "sign-out-alt" : "sign-in-alt"}
              disabled={(locked || welded)
                || (mainTimeleft && backupTimeleft) || (isDisabled)}
              onClick={() => act("openClose")}>
              {opened ? "Open" : "Closed"}
            </Button>
          )}>
          {!!(locked || welded) && (
            <span>
              [Door is {locked ? "bolted" : ""}
              {(locked && welded) ? " and " : ""}
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
      <Section m={-1}>
        <LabeledList>
          <LabeledList.Item
            color={shockTimeleft ? "average" : "good"}
            label="Electrify">
            {!shockTimeleft ? "Safe" : "Electrified"}
            {" "}
            {!wires.shock
            && <Box>[Wires have been cut!]</Box>
            || (shockTimeleft > 0
            && `[${shockTimeleft}s]`)
            || (shockTimeleft === -1
            && "[Permanent]")}
          </LabeledList.Item>
          <LabeledList.Item
            color={!shockTimeleft ? "Average" : "Bad"}>
            <Box
              ml={-12}
              mt={1}
              pb={1}>
              <Button
                color="good"
                icon="wrench"
                disabled={(!wires.shock) || (!shockTimeleft)
                || (mainTimeleft && backupTimeleft)}
                onClick={() => act("shockRestore")}>
                Restore
              </Button>
              <Button
                color="average"
                icon="bolt"
                disabled={(!wires.shock) || (shockTimeleft)
                  || (mainTimeleft && backupTimeleft)}
                onClick={() => act("shockTemp")}>
                Temporary
              </Button>
              <Button
                color="bad"
                icon="bolt"
                disabled={(!wires.shock) || (shockTimeleft)
                || (mainTimeleft && backupTimeleft)}
                onClick={() => act("shockPerm")}>
                Permanent
              </Button>
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </NoticeBox>
  );
};
