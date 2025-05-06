/**
 * @file
 * @copyright 2025
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Box, Button, LabeledList, Table, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  ModuleTreeProps,
  VariableProps,
  VarReferenceListProps,
  VarReferenceProps,
  VarToggleableProps,
  VarValueProps,
} from './type';

export const Variable = (props: VariableProps) => {
  const VariableValue = getVariableValueComponent(props.value_type);

  return (
    <LabeledList.Item
      label={
        <Tooltip content={props.tooltip}>
          <Box>{props.name}</Box>
        </Tooltip>
      }
      verticalAlign="middle"
    >
      <Table>
        <Table.Cell height="20px" verticalAlign="middle">
          <VariableValue {...props.value} />
        </Table.Cell>
        {!!props.edit_action && (
          <Table.Cell verticalAlign="middle" collapsing>
            <EditVariableButton
              edit_action={props.edit_action}
              edit_tooltip={props.edit_tooltip}
            />
          </Table.Cell>
        )}
      </Table>
    </LabeledList.Item>
  );
};

const VariableValue = (props: VarValueProps) => {
  return props.value;
};

const VariableToggleable = (props: VarToggleableProps) => {
  const { act } = useBackend<ModuleTreeProps>();

  return (
    <Tooltip content="Toggle Value">
      <Button
        onClick={() => act(props.action, { ...props.arguments })}
        color={props.value ? 'green' : 'red'}
      >
        {props.value ? 'TRUE' : 'FALSE'}
      </Button>
    </Tooltip>
  );
};

const VariableReference = (props: VarReferenceProps) => {
  const { act } = useBackend<ModuleTreeProps>();

  return (
    <Tooltip content={props.tooltip}>
      <Button onClick={() => act(props.action, { ...props.arguments })}>
        {props.title}
      </Button>
    </Tooltip>
  );
};

const VariableReferenceList = (props: VarReferenceListProps) => {
  if (props.variable_list === undefined || props.variable_list.length === 0) {
    return 'None';
  }

  return props.variable_list.map((item, index) => (
    <VariableReference key={index} {...item} />
  ));
};

const getVariableValueComponent = (value_type) => {
  if (value_type === undefined) {
    return ({ value }) => value;
  }
  if (value_type in variableValueComponents) {
    return variableValueComponents[value_type];
  }
};

const variableValueComponents = {
  value: VariableValue,
  toggleable: VariableToggleable,
  reference: VariableReference,
  reference_list: VariableReferenceList,
};

const EditVariableButton = (props) => {
  const { edit_action, edit_tooltip } = props;
  const { act } = useBackend<ModuleTreeProps>();

  return (
    <Button
      onClick={() => act(edit_action)}
      tooltip={edit_tooltip}
      icon="pen"
      textAlign="center"
      width={2}
      p="0px"
      style={{ float: 'right' }}
    />
  );
};
