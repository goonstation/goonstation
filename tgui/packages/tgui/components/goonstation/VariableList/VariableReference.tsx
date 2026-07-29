/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Button, Tooltip } from 'tgui-core/components';

import { VarValueParent } from './type';

interface VarReferenceProps extends VarValueParent {
  title: string;
  tooltip: string;
  action: [string, object | undefined];
}

/** Component for a variable value that should perform an action when clicked. */
export const VariableReference = (props: VarReferenceProps) => {
  return (
    <Tooltip content={props.tooltip}>
      <Button onClick={() => props.onAction(...props.action)}>
        {props.title}
      </Button>
    </Tooltip>
  );
};

interface VarReferenceListProps extends VarValueParent {
  variable_list: VarReferenceProps[];
}

/** Component for a list of variable values that should each perform an action when clicked. */
export const VariableReferenceList = (props: VarReferenceListProps) => {
  if (props.variable_list === undefined || props.variable_list.length === 0) {
    return 'None';
  }

  return props.variable_list.map((item, index) => (
    <VariableReference key={index} {...item} onAction={props.onAction} />
  ));
};
