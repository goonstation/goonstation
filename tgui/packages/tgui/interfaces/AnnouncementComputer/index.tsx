/**
 * @file
 * @copyright 2024
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AutomaticAnnouncement } from './automatic';
import { ManualAnnouncement } from './manual';
import { AnnouncementCompData } from './data';

export const AnnouncementComputer = (_props, context) => {
  const { act, data } = useBackend<AnnouncementCompData>(context);
  // Extract `health` and `color` variables from the `data` object.
  const { announces_arrivals, theme } = data;

  return (
    <Window theme={theme} width={400} height={326}>
      <Window.Content textAlign="center">
        <ManualAnnouncement />
        {!!announces_arrivals && (
          <AutomaticAnnouncement />
        )}
      </Window.Content>
    </Window>
  );
};
