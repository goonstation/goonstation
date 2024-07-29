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
  const { announces_arrivals, theme } = data;

  return (
    <Window theme={theme} width={400} height={announces_arrivals ? 326 : 215}>
      <Window.Content textAlign="center">
        <ManualAnnouncement />
        {!!announces_arrivals && <AutomaticAnnouncement />}
      </Window.Content>
    </Window>
  );
};
