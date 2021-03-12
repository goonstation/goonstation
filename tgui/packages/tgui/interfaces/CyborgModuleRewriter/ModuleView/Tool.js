/**
 * @file
 * @copyright 2020
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { Button } from '../../../components';
import * as styles from '../style';

const Tool = props => {
  const {
    children,
    onMoveToolDown,
    onMoveToolUp,
    onRemoveTool,
  } = props;
  return (
    <div>
      <Button icon="arrow-up" onClick={onMoveToolUp} title="Move Up" />
      <Button icon="arrow-down" onClick={onMoveToolDown} title="Move Down" />
      <Button icon="trash" onClick={onRemoveTool} title="Remove" />
      <span className={styles.ToolLabel}>{children}</span>
    </div>
  );
};

export default Tool;
