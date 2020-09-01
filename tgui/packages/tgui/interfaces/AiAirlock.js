import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Modal, Flex, Icon, Box, NoticeBox } from '../components';
import { Window } from '../layouts';

const dangerMap = {
  0: {
    color: 'bad',
    localStatusText: 'Offline',
  },
  1: {
    color: 'good',
    localStatusText: 'Optimal',
  },
  2: {
    color: 'average',
    localStatusText: 'Caution',
  },
};


export const AiAirlock = (props, context) => {
  const { act, data, config } = useBackend(context);
  const MainPower = (data.power.main_timeleft === 0);
  const BackupPower = (data.power.backup_timeleft === 0);
  const isDisabled = (config.status === 3 || config.status === 1);
  return (
    <Window
      width={500}
      height={365}>
      {!!isDisabled && (
        <Modal
          fontSize="20px"
          fontFamily="Times New Roman"
          mr={2}
          pt={1}>
          <Flex align="center">
            <Flex.Item mr={2} mt={2}>
              <Icon
                size="2"
                name="bolt"
              />
            </Flex.Item>
            <Flex.Item mr={2}>
              {'TermOS McDoor is shutting down'}
            </Flex.Item>
          </Flex>
        </Modal>
      )}
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
  const MainPower = (data.power.main_timeleft === 0);
  const BackupPower = (data.power.backup_timeleft === 0);
  const shocked = (data.shock === 1);
  const statusElectrify = dangerMap[data.shock]
  || dangerMap[0];
  const statusMain = dangerMap[Number((data.power.main_timeleft === 0))]
  || dangerMap[0];
  const statusBackup = dangerMap[Number((data.power.backup_timeleft === 0))]
  || dangerMap[0];

  return (
    <Section title="Power Status">
      <LabeledList>
        <LabeledList.Item
          label="Main"
          color={statusMain.color}
          buttons={(
            <Button
              icon="lightbulb-o"
              disabled={!MainPower}
              content="Disrupt"
              onClick={() => act('disrupt-main')} />
          )}>
          {MainPower ? 'Online' : 'Offline'}
          {' '}
          {(!data.wires.main_1 || !data.wires.main_2)
            && '[Wires have been cut!]'
            || (data.power.main_timeleft > 0
              && `[${data.power.main_timeleft}s]`)}
        </LabeledList.Item>
        <LabeledList.Item
          label="Backup"
          color={statusBackup.color}
          buttons={(
            <Button
              icon="lightbulb-o"
              disabled={!BackupPower}
              content="Disrupt"
              onClick={() => act('disrupt-backup')} />
          )}>
          {BackupPower ? 'Online' : 'Offline'}
          {' '}
          {(!data.wires.backup_1 || !data.wires.backup_2)
            && '[Wires have been cut!]'
            || (data.power.backup_timeleft > 0
              && `[${data.power.backup_timeleft}s]`)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const AccessAndDoorControl = (props, context) => {
  const { act, data } = useBackend(context);
  const MainPower = (data.power.main_timeleft === 0);
  const BackupPower = (data.power.backup_timeleft === 0);
  const DisabledStatus = (data.status === 2);

  return (
    <Section title="Access and Door Control">
      <LabeledList>
        <LabeledList.Item
          label="ID Scan"
          color="bad"
          buttons={(
            <Button
              icon={data.id_scanner ? 'power-off' : 'times'}
              content={data.id_scanner ? 'Enabled' : 'Disabled'}
              selected={data.id_scanner}
              disabled={!data.wires.id_scanner
                || (!MainPower && !BackupPower) || (DisabledStatus)}
              onClick={() => act('idscan-toggle')} />
          )}>
          {!data.wires.id_scanner && '[Wires have been cut!]'}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Door Bolts"
          color="bad"
          buttons={(
            <Button
              icon={data.locked ? 'lock' : 'unlock'}
              content={data.locked ? 'Lowered' : 'Raised'}
              selected={data.locked}
              disabled={!data.wires.bolts
                || (!MainPower && !BackupPower) || (DisabledStatus)}
              onClick={() => act('bolt-toggle')} />
          )}>
          {!data.wires.bolts && '[Wires have been cut!]'}
        </LabeledList.Item>
        <LabeledList.Divider />
        <LabeledList.Item
          label="Door Control"
          color="bad"
          buttons={(
            <Button
              icon={data.opened ? 'sign-out-alt' : 'sign-in-alt'}
              content={data.opened ? 'Open' : 'Closed'}
              selected={data.opened}
              disabled={(data.locked || data.welded)
                || (!MainPower && !BackupPower) || (DisabledStatus)}
              onClick={() => act('open-close')} />
          )}>
          {!!(data.locked || data.welded) && (
            <span>
              [Door is {data.locked ? 'bolted' : ''}
              {(data.locked && data.welded) ? ' and ' : ''}
              {data.welded ? 'welded' : ''}!]
            </span>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};


const Electrify = (props, context) => {
  const { act, data } = useBackend(context);
  const MainPower = (data.power.main_timeleft === 0);
  const BackupPower = (data.power.backup_timeleft === 0);
  const shocked = (data.shock === 1);
  const statusElectrify = dangerMap[data.shock]
  || dangerMap[0];
  const statusMain = dangerMap[Number((data.power.main_timeleft === 0))]
  || dangerMap[0];
  const statusBackup = dangerMap[Number((data.power.backup_timeleft === 0))]
  || dangerMap[0];

  return (
    <NoticeBox danger>
      <Section title="Danger Zone" m={-1}>
        <LabeledList>
          <LabeledList.Item
            label="Electrify"
            color={statusElectrify.color}
            buttons={(
              <Fragment>
                <Button
                  icon="wrench"
                  disabled={(!data.wires.shock) || (shocked)
                  || (!MainPower && !BackupPower)}
                  content="Restore"
                  onClick={() => act('shock-restore')} />
                <Button
                  icon="bolt"
                  disabled={(!data.wires.shock) || (!shocked)
                  || (!MainPower && !BackupPower)}
                  content="Temporary"
                  onClick={() => act('shock-temp')} />
                <Button
                  icon="bolt"
                  disabled={(!data.wires.shock) || (!shocked)
                  || (!MainPower && !BackupPower)}
                  content="Permanent"
                  onClick={() => act('shock-perm')} />
              </Fragment>
            )}>
            {data.shock === 1 ? 'Safe' : 'Electrified'}
            {' '}
            {!data.wires.shock
          && '[Wires have been cut!]'
          || (data.shock_timeleft > 0
          && `[${data.shock_timeleft}s]`)
          || (data.shock_timeleft === -1
          && '[Permanent]')}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </NoticeBox>
  );
};
