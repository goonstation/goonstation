/**
 * @file
 * @copyright 2026
 * @author FlameArrow57 (https://github.com/FlameArrow57)
 * @license ISC
 */

import { BooleanLike } from 'common/react';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface TourInfo {
  tour_guide: string | null;
  tour_ready: BooleanLike;
  guide_location: string | null;
}

export const TourConsole = () => {
  const { data, act } = useBackend<TourInfo>();
  const { tour_guide, tour_ready, guide_location } = data;
  return (
    <Window title="Tour Monitor" width={400} height={180}>
      <Window.Content>
        <Section title="Station Tour" fill>
          <Stack vertical>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item
                  label="Tour Guide"
                  color={tour_guide ? undefined : 'red'}
                >
                  {tour_guide ? tour_guide : 'Not found!'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Current Location"
                  color={guide_location ? undefined : 'red'}
                >
                  {guide_location ? guide_location : 'Unknown'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item align="center" mt={2} fontSize={1.25}>
              <Button
                disabled={!tour_guide || !tour_ready || !guide_location}
                onClick={() => act('begin_tour')}
              >
                Begin Tour
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
