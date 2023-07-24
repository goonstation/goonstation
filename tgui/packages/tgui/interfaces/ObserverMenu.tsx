import { useBackend } from '../backend';
import { Button } from '../components';
import { Window } from '../layouts';


type Observable = {
  name: string;
  ref: string;
  real_name: string;
  dead: boolean;
  job: string;
  npc: boolean;
  antag: boolean;
  player: string;
};

export const ObserverMenu = (props, context) => {
  const { data } = useBackend<Observable[]>(context);
  return (
    <Window title="Choose something to observe" width={600} height={600}>
      <Window.Content scrollable>
        {data.map(
          (obs, index) =>
            <Button key={obs.ref} text={obs.name} />
        )}
      </Window.Content>
    </Window>
  );
};
