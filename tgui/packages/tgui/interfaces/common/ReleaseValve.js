import { useBackend } from '../../backend';
import { NumberInput, LabeledList, Button } from '../../components';

export const ReleaseValve = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    valve_open,
    release_pressure = 0,
    min_release = 0,
    max_release = 0,
  } = props;

  return (
    <LabeledList>
      <LabeledList.Item label="Release valve">
        <Button
          content={valve_open ? 'Open' : 'Closed'}
          color={valve_open ? 'average' : 'default'}
          onClick={() => act('toggle-valve')} />
      </LabeledList.Item>
      <LabeledList.Item label="Release pressure">
        <Button
          onClick={() => act('set-pressure', {
            release_pressure: min_release,
          })}
          content="Min" />
        <NumberInput
          animated
          width="85px"
          value={release_pressure}
          minValue={min_release}
          maxValue={max_release}
          onChange={(e, target_pressure) => act('set-pressure', {
            release_pressure: target_pressure,
          })} />
        <Button
          onClick={() => act('set-pressure', {
            release_pressure: max_release,
          })}
          content="Max" />
      </LabeledList.Item>
    </LabeledList>
  );

};
