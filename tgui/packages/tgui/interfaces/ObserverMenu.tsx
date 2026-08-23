import { useState } from 'react';
import {
  BlockQuote,
  Button,
  Collapsible,
  Input,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Observable = {
  name: string;
  ref: string;
  real_name: string;
  dead: boolean;
  job: string;
  npc: boolean;
  antag: string;
  player: boolean;
  dup_name_count: number;
  ghost_count: number;
};

interface Observables {
  mydata: Observable[];
  dnrset: boolean;
}

const ObserverButton = (props) => {
  const { act } = useBackend();
  const { obsObject } = props;
  let icon: string | undefined;
  let displayed_name = obsObject.name;
  let extra: string | null = null;
  if (obsObject.dead) {
    icon = 'skull';
  }
  if (obsObject.name !== obsObject.real_name) {
    displayed_name += ' (' + obsObject.real_name + ')';
  }
  if (obsObject.job !== null) {
    extra = 'Job: ' + obsObject.job;
  }
  if (obsObject.dup_name_count > 0) {
    displayed_name += ' #' + obsObject.dup_name_count;
  }
  if (obsObject.ghost_count > 0) {
    icon = 'ghost';
    displayed_name = obsObject.ghost_count + ' ' + displayed_name;
  }
  if (obsObject.antag !== null) {
    displayed_name += ' [' + obsObject.antag + ']';
  }
  return (
    <Button
      key={obsObject.ref}
      icon={icon}
      onClick={() => act('observe', { targetref: obsObject.ref })}
      tooltip={extra}
    >
      {displayed_name}
    </Button>
  );
};

const GetRandomAlivePlayer = function (observableArray: Array<Observable>) {
  let alivePlayers = observableArray.filter((obs) => obs.player && !obs.dead);
  return alivePlayers[Math.floor(Math.random() * alivePlayers.length)];
};

export const ObserverMenu = () => {
  const { act, data } = useBackend<Observables>();
  const [searchQuery, setSearchQuery] = useState<string>('');
  const filteredItems = data.mydata.filter(
    (item) =>
      item?.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item?.real_name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item?.job?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item?.antag?.toLowerCase().includes(searchQuery.toLowerCase()),
  );
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    setSearchQuery(query);
  };
  const [deadFilter, setDeadFilter] = useState<boolean>(false);

  return (
    <Window title="Choose something to observe" width={600} height={600}>
      <Window.Content scrollable>
        <Section
          fill
          title="Observables"
          buttons={
            <>
              <Button
                disabled={
                  data.mydata.filter((obs) => obs.player && !obs.dead)
                    .length === 0
                }
                onClick={() =>
                  act('observe', {
                    targetref: GetRandomAlivePlayer(data.mydata)?.ref,
                  })
                }
                icon="random"
                tooltip="Observe a random player"
              />
              <Button.Checkbox
                icon="skull"
                tooltip={deadFilter ? 'Show dead mobs' : 'Hide dead mobs'}
                checked={!deadFilter}
                onClick={() => setDeadFilter(!deadFilter)}
              />
              <Input
                width={20}
                autoFocus
                autoSelect
                onChange={(value) => onSearch(value)}
                placeholder="Search by name or job"
                value={searchQuery}
              />
            </>
          }
        >
          <Collapsible
            key="Antags"
            title="Antagonists"
            open={!!data.dnrset}
            color="red"
          >
            {!data.dnrset && (
              <BlockQuote>You must set DNR to view the antagonists</BlockQuote>
            )}
            {filteredItems
              .filter((obs) => obs.antag !== null && !(obs.dead && deadFilter))
              .map((obs) => (
                <ObserverButton obsObject={obs} key={obs.ref} />
              ))}
          </Collapsible>
          <Collapsible key="Players" title="Players" open color="green">
            {filteredItems
              .filter((obs) => obs.player && !(obs.dead && deadFilter))
              .map((obs) => (
                <ObserverButton obsObject={obs} key={obs.ref} />
              ))}
          </Collapsible>
          <Collapsible key="NPCs" title="NPCs" color="blue">
            {filteredItems
              .filter((obs) => obs.npc && !(obs.dead && deadFilter))
              .map((obs) => (
                <ObserverButton obsObject={obs} key={obs.ref} />
              ))}
          </Collapsible>
          <Collapsible key="Objects" title="Objects" color="brown">
            {filteredItems
              .filter((obs) => !obs.npc && !obs.player)
              .map((obs) => (
                <ObserverButton obsObject={obs} key={obs.ref} />
              ))}
          </Collapsible>
        </Section>
      </Window.Content>
    </Window>
  );
};
