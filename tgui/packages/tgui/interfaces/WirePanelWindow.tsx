import { Window } from '../layouts';
import { Section } from "../components";

import { WirePanel } from './common/WirePanel';

export const WirePanelWindow = (props, context) => {
  return (
    <Window width={350}>
      <Window.Content>
        <Section title="Maintenance Panel"><WirePanel /></Section>
      </Window.Content>
    </Window>
  );
};
