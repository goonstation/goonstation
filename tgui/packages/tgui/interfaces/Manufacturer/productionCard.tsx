/**
 * @file
 * @copyright 2024
 * @author Romayne (https://github.com/MeggalBozale)
 * @license ISC
 */

import { truncate } from '../../format';
import { useBackend } from "../../backend";
import { Button, ProgressBar, Stack } from "../../components";
import { ButtonWithBadge } from "../../components/goonstation/ButtonWithBadge";
import { CenteredText } from "../../components/goonstation/CenteredText";
import { clamp } from 'common/math';

/*
  Card which shows the blueprint being produced/queued, and if currently being produced,
  a progressbar for how close it is to being done.
*/
export const ProductionCard = (params, context) => {
  const { act } = useBackend(context);
  const { data, progress_pct, index, mode } = params;
  // Simpler badge for the buttons where it doesn't matter, bottommost return for the bestest of buttons
  if (index !== 0) {
    return (
      <Stack.Item>
        <ButtonWithBadge
          width="100%"
          height={4.6}
          image_path={data.img}
          onClick={() => act("remove", { "index": index+1 })}
        >
          <CenteredText
            text={truncate(data.name, 40)}
            height={4.6}
          />
        </ButtonWithBadge>
      </Stack.Item>
    );
  }
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item>
          <ButtonWithBadge
            width={16.5}
            height={4.6}
            image_path={data.img}
            onClick={() => act("remove", { "index": index+1 })}
          >
            <Stack vertical>
              <Stack.Item>
                <CenteredText text={truncate(data.name)} />
              </Stack.Item>
              <Stack.Item>
                <ProgressBar
                  value={clamp(progress_pct, 0, 1)}
                  minValue={0}
                  maxValue={1}
                  position="relative"
                  color="rgba(0,0,0,0.2)"
                />
              </Stack.Item>
            </Stack>
          </ButtonWithBadge>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Button
                width={2}
                height={2}
                pt={0.5}
                pl={1.1}
                icon="trash"
                onClick={() => act("remove", { "index": index+1 })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                width={2}
                height={2}
                pl={1.3}
                pt={0.5}
                icon={(mode === "working") ? "pause" : "play"}
                onClick={() => act("pause_toggle", { "action": (mode === "working") ? "pause" : "continue" })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
