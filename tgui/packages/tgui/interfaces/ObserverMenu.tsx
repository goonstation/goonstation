import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Button, Section, Collapsible, BlockQuote, Flex } from '../components';


type Observable = {
  name: string;
  ref: string;
  real_name: string;
  dead: boolean;
  job: string;
  npc: boolean;
  antag: boolean;
  player: boolean;
  ghost_count: number;
};

interface Observables {
  mydata: Observable[];
  dnrset: boolean;
}

const ObserverButton = (props, context) => {
  const { act } = useBackend(context);
  const { obsObject } = props;
  let icon=null;
  let displayed_name=obsObject.name;
  let extra=null;
  if (obsObject.dead) { icon = "skull"; }
  if (obsObject.name !== obsObject.real_name) { displayed_name += " ("+obsObject.real_name+")"; }
  if (obsObject.job !== null) { extra = "Job: "+obsObject.job; }
  return (
    <Button
      key={obsObject.ref}
      icon={icon}
      onClick={() => act('observe', { 'targetref': obsObject.ref })}
      tooltip={extra}
    >
      {displayed_name}
    </Button>
  );
};

export const ObserverMenu = (props, context) => {
  const { act, data } = useBackend<Observables>(context);
  return (
    <Window title="Choose something to observe" width={600} height={600}>
      <Window.Content scrollable>
        <Section fill
          title="Observables"
          buttons={(
            <Flex.Item textAlign="center" basis={1.5} >
              <Button.Input
                icon="search"
                tooltip="Filter by name"
                onCommit={() => act('ejectseeds')}>
                Search By Name
              </Button.Input>
            </Flex.Item>
          )}>
          <Collapsible key="Antags" title="Antagonists" open={!!data.dnrset} color="red" >
            {(!data.dnrset) && <BlockQuote>You must set DNR to view the antagonists</BlockQuote>}
            {data.mydata.filter((obs) => obs.antag).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
          <Collapsible key="Players" title="Players" open color="green">
            {data.mydata.filter((obs) => obs.player).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
          <Collapsible key="NPCs" title="NPCs" open color="blue">
            {data.mydata.filter((obs) => obs.npc).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
          <Collapsible key="Objects" title="Objects" open color="brown">
            {data.mydata.filter((obs) => !obs.npc && !obs.player).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};
