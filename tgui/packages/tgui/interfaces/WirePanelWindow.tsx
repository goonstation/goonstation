import { Window } from '../layouts';
import { Section } from "../components";

import { WirePanelInsert } from './common/WirePanel';

export const WirePanelWindow = (props, context) => {
  return (
    <Window width={350}>
      <Window.Content>
        <Section title="Maintenance Panel"><WirePanelInsert /></Section>
      </Window.Content>
    </Window>
  );
};
