/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import EmptyPlaceholder from '../EmptyPlaceholder';
import Tool from './Tool';

const Tools = props => {
  const {
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
    tools = [],
  } = props;
  return (
    <div>
      {
        tools.length > 0
          ? tools.map(tool => {
            const {
              name,
              ref: toolRef,
            } = tool;
            return (
              <Tool
                onMoveToolDown={() => onMoveToolDown(toolRef)}
                onMoveToolUp={() => onMoveToolUp(toolRef)}
                onRemoveTool={() => onRemoveTool(toolRef)}
                key={toolRef}>
                {name}
              </Tool>
            );
          })
          : <EmptyPlaceholder>Module has no tools</EmptyPlaceholder>
      }
    </div>
  );
};

export default Tools;
