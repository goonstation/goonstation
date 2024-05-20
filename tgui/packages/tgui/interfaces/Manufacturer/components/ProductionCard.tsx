/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { truncate } from '../../../format';
import { Stack, Tooltip } from "../../../components";
import { ButtonWithBadge } from "./ButtonWithBadge";
import { CenteredText } from "./CenteredText";
import { ProductionCardStyle } from "../constant";

export type ProductionCardProps = {
  actionQueueRemove: (index:number) => void;
  img:string;
  index:number;
  mode: 'working' | 'halt' | 'ready';
  name:string;
}

/*
  Card which shows the blueprint being produced/queued, and if currently being produced,
  a progressbar for how close it is to being done.
*/
export const ProductionCard = (props:ProductionCardProps) => {
  const {
    actionQueueRemove,
    img,
    index,
    mode,
    name,
  } = props;

  // dont display Weird things
  if (img === undefined
      || index === undefined
      || mode === undefined
      || name === undefined
  ) {
    return null;
  }
  return (
    <Stack.Item>
      <Tooltip
        content={"Click to remove from queue."}
      >
        <ButtonWithBadge
          imagePath={img}
          onClick={() => actionQueueRemove(index)}
          width={ProductionCardStyle.Width}
          height={ProductionCardStyle.Height}
        >
          <CenteredText
            height={ProductionCardStyle.Height}
            text={truncate(name, 40)}
          />
        </ButtonWithBadge>
      </Tooltip>
    </Stack.Item>
  );
};
