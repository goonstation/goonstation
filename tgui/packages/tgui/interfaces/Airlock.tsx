/**
 * @file
 * @copyright 2020
 * @author ThePotato97 (https://github.com/ThePotato97)
 * @license ISC
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  LabeledList,
  Modal,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { truncate } from '../format';
import { Window } from '../layouts';

interface AirlockData {
  accessCode: number;
  aiControlVar: number;
  aiHacking;
  backupTimeLeft;
  boltsAreUp;
  canAiControl: BooleanLike;
  canAiHack: BooleanLike;
  hackMessage;
  hackingProgression;
  idScanner;
  mainTimeLeft;
  name;
  netId;
  noPower;
  opened;
  panelOpen;
  powerIsOn: BooleanLike;
  safety;
  shockTimeLeft;
  signalers;
  userStates;
  welded;
  wireColors;
  wireStates;
  wires;
}

export const uiCurrentUserPermissions = (data: AirlockData) => {
  const { panelOpen, userStates } = data;

  return {
    // can only access airlock if they're AI or a borg.
    airlock: userStates.isBorg || userStates.isAi,
    /** borgs can only access panel when they're next to the airlock
     * carbons are checked on the backend so no need to check their distance here
     * so we'll return true
     */
    accessPanel:
      (userStates.isBorg && userStates.distance <= 1 && panelOpen) ||
      (panelOpen && !userStates.isBorg && !userStates.isAi),
  };
};

export const Airlock = () => {
  const { data } = useBackend<AirlockData>();
  const { name } = data;
  const userPerms = uiCurrentUserPermissions(data);
  //  We render 3 different interfaces so we can change the window sizes
  return (
    <>
      {!userPerms['airlock'] && !userPerms['accessPanel'] && (
        <Window
          width={355}
          height={455}
          title={`Airlock - ${truncate(name, 19)}`}
        >
          <Window.Content>
            <Modal textAlign="center" fontSize="24px">
              <Box width={25} align="center">
                Access Panel is Closed
              </Box>
            </Modal>
          </Window.Content>
        </Window>
      )}
      {(!!userPerms['airlock'] && !!userPerms['accessPanel'] && (
        <AirlockAndAccessPanel />
      )) ||
        (!!userPerms['airlock'] && <AirlockControlsOnly />) ||
        (!!userPerms['accessPanel'] && <AccessPanelOnly />)}
    </>
  );
};

const AirlockAndAccessPanel = () => {
  const { data } = useBackend<AirlockData>();

  const { name, canAiControl, hackMessage, canAiHack, noPower } = data;

  const [tabIndex, setTabIndex] = useState(1);
  return (
    <Window width={355} height={490} title={`Airlock - ${truncate(name, 19)}`}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => {
              setTabIndex(1);
            }}
          >
            Airlock Controls
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => {
              setTabIndex(2);
            }}
          >
            Access Panel
          </Tabs.Tab>
        </Tabs>
        {tabIndex === 1 && (
          <>
            <Section backgroundColor="transparent">
              {(!canAiControl || !!noPower) && (
                <Modal textAlign="center" fontSize="24px">
                  <Box width={20} height={5} align="center">
                    {hackMessage ? hackMessage : 'Airlock Controls Disabled'}
                  </Box>
                </Modal>
              )}
              <PowerStatus />
              <AccessAndDoorControl />
              <Electrify />
            </Section>
            {!!canAiHack && <Hack />}
          </>
        )}
        {tabIndex === 2 && <AccessPanel />}
      </Window.Content>
    </Window>
  );
};

const AirlockControlsOnly = () => {
  const { data } = useBackend<AirlockData>();

  const { name, canAiControl, hackMessage, canAiHack, noPower } = data;

  return (
    <Window width={300} height={365} title={`Airlock - ${truncate(name, 19)}`}>
      <Window.Content>
        {(!canAiControl || !!noPower) && (
          <Modal textAlign="center" fontSize="26px">
            <Box width={20} height={5} align="center">
              {hackMessage ? hackMessage : 'Airlock Controls Disabled'}
            </Box>
            {!!canAiHack && <Hack />}
          </Modal>
        )}
        <PowerStatus />
        <AccessAndDoorControl />
        <Electrify />
      </Window.Content>
    </Window>
  );
};

const AccessPanelOnly = () => {
  const { data } = useBackend<AirlockData>();
  const { name } = data;

  return (
    <Window width={355} height={455} title={`Airlock - ${truncate(name, 19)}`}>
      <Window.Content>
        <AccessPanel />
      </Window.Content>
    </Window>
  );
};

const PowerStatus = () => {
  const { act, data } = useBackend<AirlockData>();
  const { mainTimeLeft, backupTimeLeft, wires, netId, accessCode } = data;

  const buttonProps = {
    width: 6.7,
    textAlign: 'center',
  };

  return (
    <Section title="Power Status">
      <Box>
        {'Access sensor reports the net ID is: '}
        <code>{netId}</code>
      </Box>
      <Box>
        {'Net access code: '}
        <code>{accessCode}</code>
      </Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item
          label="Main"
          color={mainTimeLeft ? 'bad' : 'good'}
          buttons={
            <Button
              {...buttonProps}
              color="bad"
              icon="plug"
              disabled={!!mainTimeLeft}
              onClick={() => act('disruptMain')}
            >
              Disrupt
            </Button>
          }
        >
          {mainTimeLeft ? 'Offline' : 'Online'}
          {((!wires.main_1 || !wires.main_2) && ' [Wires cut!]') ||
            (mainTimeLeft > 0 && ` [${mainTimeLeft}s]`)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Backup"
          color={backupTimeLeft ? 'bad' : 'good'}
          buttons={
            <Button
              {...buttonProps}
              mt={0.5}
              color="bad"
              icon="plug"
              disabled={!!backupTimeLeft}
              onClick={() => act('disruptBackup')}
            >
              Disrupt
            </Button>
          }
        >
          {backupTimeLeft ? 'Offline' : 'Online'}
          {((!wires.backup_1 || !wires.backup_2) && ' [Wires cut!]') ||
            (backupTimeLeft > 0 && ` [${backupTimeLeft}s]`)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const AccessAndDoorControl = () => {
  const { act, data } = useBackend<AirlockData>();
  const {
    mainTimeLeft,
    backupTimeLeft,
    wires,
    idScanner,
    boltsAreUp,
    opened,
    welded,
  } = data;

  const buttonProps = {
    width: 6.7,
    textAlign: 'center',
  };
  return (
    <Section title="Access and Door Control" pt={1}>
      <LabeledList>
        <LabeledList.Item
          label="ID Scan"
          color="bad"
          buttons={
            <Button
              {...buttonProps}
              color={idScanner ? 'good' : 'bad'}
              icon={idScanner ? 'power-off' : 'times'}
              disabled={!wires.idScanner || (mainTimeLeft && backupTimeLeft)}
              onClick={() => act('idScanToggle')}
            >
              {idScanner ? 'Enabled' : 'Disabled'}
            </Button>
          }
        >
          {!wires.idScanner && '[Wires cut!]'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Door Bolts"
          color="bad"
          buttons={
            <Button
              mt={0.5}
              {...buttonProps}
              color={!boltsAreUp ? 'bad' : 'good'}
              icon={!boltsAreUp ? 'unlock' : 'lock'}
              disabled={!wires.bolts || (mainTimeLeft && backupTimeLeft)}
              onClick={() => act('boltToggle')}
            >
              {!boltsAreUp ? 'Lowered' : 'Raised'}
            </Button>
          }
        >
          {!wires.bolts && '[Wires cut!]'}
        </LabeledList.Item>
        <LabeledList.Item
          label="Door Control"
          color="bad"
          buttons={
            <Button
              {...buttonProps}
              mt={0.5}
              color={opened ? 'bad' : 'good'}
              icon={opened ? 'sign-out-alt' : 'sign-in-alt'}
              disabled={
                !boltsAreUp || welded || (mainTimeLeft && backupTimeLeft)
              }
              onClick={() => act('openClose')}
            >
              {opened ? 'Open' : 'Closed'}
            </Button>
          }
        >
          {!!(!boltsAreUp || welded) && (
            <span>
              [{!boltsAreUp && 'Bolted'}
              {!boltsAreUp && welded && ' & '}
              {welded && 'Welded'}!]
            </span>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Electrify = () => {
  const { act, data } = useBackend<AirlockData>();
  const { mainTimeLeft, backupTimeLeft, wires, shockTimeLeft } = data;

  return (
    <NoticeBox backgroundColor="#601B1B">
      <LabeledList>
        <LabeledList.Item
          labelColor="white"
          color={shockTimeLeft ? 'average' : 'good'}
          label="Electrify"
        >
          {!shockTimeLeft ? 'Safe' : 'Electrified'}
          {(!wires.shock && ' [Wires cut!]') ||
            (shockTimeLeft > 0 && ` [${shockTimeLeft}s]`) ||
            (shockTimeLeft === -1 && ' [Permanent]')}
        </LabeledList.Item>
      </LabeledList>

      <Stack pt={1} justify="flex-end">
        {!shockTimeLeft && (
          <Button.Confirm
            width={9}
            p={0.5}
            align="center"
            color="average"
            confirmContent="Are you sure?"
            icon="bolt"
            disabled={!wires.shock || (mainTimeLeft && backupTimeLeft)}
            onClick={() => act('shockTemp')}
          >
            Temporary
          </Button.Confirm>
        )}
        <Button.Confirm
          width={9}
          p={0.5}
          align="center"
          color={shockTimeLeft ? 'good' : 'bad'}
          icon="bolt"
          confirmContent="Are you sure?"
          disabled={!wires.shock || (mainTimeLeft && backupTimeLeft)}
          onClick={
            shockTimeLeft ? () => act('shockRestore') : () => act('shockPerm')
          }
        >
          {shockTimeLeft ? 'Restore' : 'Permanent'}
        </Button.Confirm>
      </Stack>
    </NoticeBox>
  );
};

const Hack = () => {
  const { act, data } = useBackend<AirlockData>();
  const { aiHacking, hackingProgression } = data;

  return (
    <Box py={0.5} pt={2} align="center">
      {!aiHacking && (
        <Button
          className="Airlock-hack-button"
          fontSize="29px"
          backgroundColor="#00FF00"
          disabled={aiHacking}
          textColor="black"
          textAlign="center"
          width={16}
          onClick={() => act('hackAirlock')}
        >
          HACK
        </Button>
      )}
      {!!aiHacking && (
        <ProgressBar
          ranges={{
            good: [6, Infinity],
            average: [2, 5],
            bad: [-Infinity, 1],
          }}
          minValue={0}
          maxValue={6}
          value={hackingProgression}
        />
      )}
    </Box>
  );
};

export const AccessPanel = () => {
  const { act, data } = useBackend<AirlockData>();
  const {
    signalers,
    wireColors,
    wireStates,
    netId,
    powerIsOn,
    boltsAreUp,
    canAiControl,
    aiControlVar,
    safety,
    panelOpen,
    accessCode,
  } = data;

  const handleWireInteract = (wireColorIndex, action) => {
    act(action, { wireColorIndex });
  };

  const wires = Object.keys(wireColors);

  return (
    <Section title="Access Panel">
      {!panelOpen && (
        <Modal textAlign="center" fontSize="24px">
          Access Panel is Closed
        </Modal>
      )}
      <Box>
        {'An ID is engraved under the card sensor: '}
        <code>{netId}</code>
      </Box>
      <Box>
        {'A display shows net access code: '}
        <code>{accessCode}</code>
      </Box>
      <Divider />
      <LabeledList>
        {wires.map((entry, i) => (
          <LabeledList.Item
            key={entry}
            label={`${entry} wire`}
            labelColor={entry.toLowerCase()}
          >
            {!wireStates[i] ? (
              <Box height={1.8}>
                <Button icon="cut" onClick={() => handleWireInteract(i, 'cut')}>
                  Cut
                </Button>
                <Button
                  icon="bolt"
                  onClick={() => handleWireInteract(i, 'pulse')}
                >
                  Pulse
                </Button>
                <Button
                  icon="broadcast-tower"
                  width={10.5}
                  className="AccessPanel-wires-btn"
                  selected={signalers[i]}
                  onClick={() => handleWireInteract(i, 'signaler')}
                >
                  {!signalers[i] ? 'Attach Signaler' : 'Detach Signaler'}
                </Button>
              </Box>
            ) : (
              <Button
                color="green"
                height={1.8}
                onClick={() => handleWireInteract(i, 'mend')}
              >
                Mend
              </Button>
            )}
          </LabeledList.Item>
        ))}
      </LabeledList>
      <Divider />
      <Stack>
        <Stack.Item grow={1}>
          <LabeledList>
            <LabeledList.Item
              label="Door bolts"
              color={boltsAreUp ? 'green' : 'red'}
            >
              {boltsAreUp ? 'Disengaged' : 'Engaged'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Test light"
              color={powerIsOn ? 'green' : 'red'}
            >
              {powerIsOn ? 'Active' : 'Inactive'}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item grow={1}>
          <LabeledList>
            <LabeledList.Item
              label="AI control"
              color={
                canAiControl ? (aiControlVar === 2 ? 'orange' : 'green') : 'red'
              }
            >
              {canAiControl ? 'Enabled' : 'Disabled'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Safety light"
              color={safety ? 'green' : 'red'}
            >
              {safety ? 'Active' : 'Inactive'}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
