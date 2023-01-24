/**
 * @file
 * @copyright 2022
 * @author LeahTheTech (https://github.com/TobleroneSwordfish)
 * @license MIT
 */
import { Button } from '../../components';

export const IDCard = (props, context) => {
  if (!props.card) {
    return;
  }
  const {
    card,
    onEject,
  } = props;
  return (
    <Button
      icon="eject"
      content={card.name + ` (${card.role})`}
      tooltip="Clear scanned card"
      tooltipPosition="bottom-end"
      onClick={onEject}
    />
  );
};
