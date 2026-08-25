/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license ISC
 */

import {
  BlockQuote,
  Button,
  Image,
  Input,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { useState } from 'react';

interface MedalRewardsData {
  rewards: RewardData[];
  categories: string[];
  eligible_rewards: string[];
}

interface RewardData {
  type: string;
  title: string;
  desc: string;
  icon: string;
  category: string;
}

export const MedalRewards = () => {
  const { data } = useBackend<MedalRewardsData>();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const filteredRewards = data.rewards
    .filter(
      (reward) =>
        selectedCategory === 'All' || reward.category === selectedCategory,
    )
    .filter((reward) =>
      data.eligible_rewards.find((type) => reward.type === type),
    )
    .filter((reward) =>
      (reward.title + reward.desc)
        .toLocaleLowerCase()
        .includes(searchQuery.toLocaleLowerCase()),
    );
  return (
    <Window width={600} height={800} title="Medal Rewards">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Input
              fluid
              value={searchQuery}
              onChange={setSearchQuery}
              placeholder="Filter Rewards"
            />
          </Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                align="center"
                selected={selectedCategory === 'All'}
                onClick={() => setSelectedCategory('All')}
              >
                All
              </Tabs.Tab>
              {data.categories.map((category) => (
                <Tabs.Tab
                  align="center"
                  key={category}
                  selected={selectedCategory === category}
                  onClick={() => setSelectedCategory(category)}
                >
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill>
              <Table>
                {filteredRewards.map((reward) => (
                  <Reward key={reward.type} reward={reward} />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface RewardProps {
  reward: RewardData;
}

const ICON_SIZE = '48px';
const Reward = (props: RewardProps) => {
  const { act, data } = useBackend<MedalRewardsData>();
  const { reward } = props;
  return (
    <Table.Row className="candystripe">
      <Stack py="5px" align="center">
        <Stack.Item>
          <Image width={ICON_SIZE} height={ICON_SIZE} src={reward.icon} />
        </Stack.Item>
        <Stack.Item grow>
          <b>{reward.title}</b>
          <br />
          <BlockQuote py="2px">{reward.desc}</BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <Button onClick={() => act('redeem', { reward_type: reward.type })}>
            Redeem
          </Button>
        </Stack.Item>
      </Stack>
    </Table.Row>
  );
};
