import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const dangerMap = {
  1: {
    color: 'good',
    localStatusText: 'Offline',
  },
  0: {
    color: 'bad',
    localStatusText: 'Optimal',
  },
};

export const AiAirlock = (props, context) => {
  const { act, data } = useBackend(context);
  const statusMain = dangerMap[data.power.main] || dangerMap[0];
  const statusBackup = dangerMap[data.power.backup] || dangerMap[0];
  const statusElectrify = dangerMap[data.shock] || dangerMap[0];
  return (
    <Window
      width={500}
      height={315}>
      <Window.Content>
        <Section title="Power Status">
          <LabeledList>
            <LabeledList.Item
              label="Main"
              color={statusMain.color}
              buttons={(
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.main}
                  content="Disrupt"
                  onClick={() => act('disrupt-main')} />
              )}>
              {data.power.main ? 'Online' : 'Offline'}
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
                  disabled={!data.power.backup}
                  content="Disrupt"
                  onClick={() => act('disrupt-backup')} />
              )}>
              {data.power.backup ? 'Online' : 'Offline'}
              {' '}
              {(!data.wires.backup_1 || !data.wires.backup_2)
                && '[Wires have been cut!]'
                || (data.power.backup_timeleft > 0
                  && `[${data.power.backup_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Electrify"
              color={statusElectrify.color}
              buttons={(
                <Fragment>
                  <Button
                    icon="wrench"
                    disabled={!(data.wires.shock && !data.shock
                      && !data.power.main && !data.power.backup)}
                    content="Restore"
                    onClick={() => act('shock-restore')} />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock || !data.shock
                      || !data.power.main && !data.power.backup}
                    content="Temporary"
                    onClick={() => act('shock-temp')} />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock || !data.shock
                      || !data.power.main && !data.power.backup}
                    content="Permanent"
                    onClick={() => act('shock-perm')} />
                </Fragment>
              )}>
              {data.shock === 2 ? 'Safe' : 'Electrified'}
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
                    || (!data.power.main && !data.power.backup)}
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
                    || (!data.power.main && !data.power.backup)}
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
                    || (!data.power.main && !data.power.backup)}
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
      </Window.Content>
    </Window>
  );
};
