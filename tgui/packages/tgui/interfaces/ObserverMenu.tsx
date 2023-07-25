import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Button, Input, Section, Collapsible, BlockQuote, Flex } from '../components';


type Observable = {
  name: string;
  ref: string;
  real_name: string;
  dead: boolean;
  job: string;
  npc: boolean;
  antag: boolean;
  player: boolean;
  dup_name_count: number;
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
  if (obsObject.dup_name_count > 0) { displayed_name += " #"+obsObject.dup_name_count; }
  if (obsObject.ghost_count > 0) { icon="ghost"; displayed_name = obsObject.ghost_count+" "+displayed_name; }
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
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );
  const filteredItems = data.mydata.filter((item) =>
    item?.name.toLowerCase().includes(searchQuery.toLowerCase())
    || item?.job?.toLowerCase().includes(searchQuery.toLowerCase())
  );
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    setSearchQuery(query);
  };

  return (
    <Window title="Choose something to observe" width={600} height={600}>
      <Window.Content scrollable>
        <Section fill
          title="Observables"
          buttons={(
            <Flex.Item textAlign="center" basis={1.5} >
              <Input
                width={20}
                autoFocus
                autoSelect
                fluid
                id="search_bar"
                onInput={(_, value) => onSearch(value)}
                placeholder="Search by name or job"
                value={searchQuery}
              />
            </Flex.Item>
          )}>
          <Collapsible key="Antags" title="Antagonists" open={!!data.dnrset} color="red" >
            {(!data.dnrset) && <BlockQuote>You must set DNR to view the antagonists</BlockQuote>}
            {filteredItems.filter((obs) => obs.antag).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
          <Collapsible key="Players" title="Players" open color="green">
            {filteredItems.filter((obs) => obs.player).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
          <Collapsible key="NPCs" title="NPCs" open color="blue">
            {filteredItems.filter((obs) => obs.npc).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
          <Collapsible key="Objects" title="Objects" open color="brown">
            {filteredItems.filter((obs) => !obs.npc && !obs.player).map((obs) => (
              <ObserverButton obsObject={obs} key={obs.ref} />
            ))}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};
