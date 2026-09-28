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
import { AnnouncementCompData } from './type';

export const AnnouncementComputer = (_props: unknown) => {
  const { data } = useBackend<AnnouncementCompData>();
  const { announces_arrivals, can_change_anonymous, theme } = data;
  let height = 215;
  if (announces_arrivals) height += 110;
  if (can_change_anonymous) height += 20;

  return (
    <Window theme={theme} width={400} height={height}>
      <Window.Content textAlign="center">
        <ManualAnnouncement />
        {!!announces_arrivals && <AutomaticAnnouncement />}
      </Window.Content>
    </Window>
  );
};
