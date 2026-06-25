/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { classes } from 'common/react';
import { Box, Button, LabeledList, Table, Tooltip } from 'tgui-core/components';

import { getVariableValueComponent } from './actions';
import { VariableListProps, VariableProps } from './type';

export const VariableList = (props: VariableListProps) => {
  return (
    <Box className={classes(['VariableList', props.className])}>
      <LabeledList>
        {props.variables.map((variable, index) => (
          <Variable
            key={index}
            {...variable}
            className={props.className}
            act={props.act}
          />
        ))}
      </LabeledList>
    </Box>
  );
};

const Variable = (props: VariableProps) => {
  const VariableValueComponent = getVariableValueComponent(props.value_type);

  return (
    <LabeledList.Item
      className={props.className}
      label={
        <Tooltip content={props.tooltip}>
          <Box>{props.name}</Box>
        </Tooltip>
      }
      verticalAlign="middle"
    >
      <Table>
        <Table.Cell height="20px" verticalAlign="middle">
          <VariableValueComponent act={props.act} {...props.value} />
        </Table.Cell>
        {!!props.edit_action && (
          <Table.Cell verticalAlign="middle" collapsing>
            <Button
              onClick={() => props.act(...props.edit_action!)}
              tooltip={props.edit_tooltip}
              icon="pen"
              textAlign="center"
              width={2}
              p="0px"
              style={{ float: 'right' }}
            />
          </Table.Cell>
        )}
      </Table>
    </LabeledList.Item>
  );
};
