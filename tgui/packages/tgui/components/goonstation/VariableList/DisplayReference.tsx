/**
 * @file
 * @copyright 2026
 * @author Mr. Moriarty (https://github.com/Mister-Moriarty)
 * @license MIT
 */

import { Button, Tooltip } from 'tgui-core/components';

import { ValueDisplayParent } from './type';

interface DisplayReferenceProps extends ValueDisplayParent {
  title: string;
  tooltip: string;
  action: [string, object | undefined];
}

/** Component for a variable value that should perform an action when clicked. */
export const DisplayReference = (props: DisplayReferenceProps) => {
  return (
    <Tooltip content={props.tooltip}>
      <Button onClick={() => props.onAction(...props.action)}>
        {props.title}
      </Button>
    </Tooltip>
  );
};

interface DisplayReferenceListProps extends ValueDisplayParent {
  variable_list: DisplayReferenceProps[];
}

/** Component for a list of variable values that should each perform an action when clicked. */
export const DisplayReferenceList = (props: DisplayReferenceListProps) => {
  if (props.variable_list === undefined || props.variable_list.length === 0) {
    return 'None';
  }

  return props.variable_list.map((item, index) => (
    <DisplayReference key={index} {...item} onAction={props.onAction} />
  ));
};
