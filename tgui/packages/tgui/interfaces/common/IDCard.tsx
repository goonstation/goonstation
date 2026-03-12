/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */
import { Button } from 'tgui-core/components';

export const IDCard = (props) => {
  if (!props.card) {
    return;
  }
  const { card, onEject } = props;
  return (
    <Button
      icon="eject"
      tooltip="Clear scanned card"
      tooltipPosition="bottom-end"
      onClick={onEject}
    >
      {`${card.name} (${card.role})`}
    </Button>
  );
};
