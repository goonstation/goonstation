/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { truncate } from './../../format';
import { Button, Stack } from "./../../components";
import { ButtonWithBadge } from "./ButtonWithBadge";
import { CenteredText } from "./CenteredText";
import { ProductionCardData } from "./type";
/*
  Card which shows the blueprint being produced/queued, and if currently being produced,
  a progressbar for how close it is to being done.
*/
export const ProductionCard = (params:ProductionCardData) => {
  const {
    actionQueueRemove,
    actionQueueTogglePause,
    img,
    index,
    mode,
    name,
  } = params;

  // dont display Weird things
  if (img === undefined
      || index === undefined
      || mode === undefined
      || name === undefined
  ) {
    return null;
  }
  // Simpler badge for the buttons where it doesn't matter, bottommost return for the bestest of buttons
  if (index !== 0) {
    return (
      <Stack.Item>
        <ButtonWithBadge
          imagePath={img}
          onClick={() => actionQueueRemove(index)}
        >
          <CenteredText text={truncate(name, 40)} />
        </ButtonWithBadge>
      </Stack.Item>
    );
  }
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item>
          <ButtonWithBadge
            imagePath={img}
            onClick={() => actionQueueRemove(index)}
          >
            <CenteredText text={truncate(name)} />
          </ButtonWithBadge>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button
                icon="trash"
                onClick={() => actionQueueRemove(index)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon={(mode === "working") ? "pause" : "play"}
                onClick={() => actionQueueTogglePause(mode)}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
