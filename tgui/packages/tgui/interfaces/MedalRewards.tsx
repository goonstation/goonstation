/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license ISC
 */

import { useState } from 'react';
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

interface MedalRewardsData {
  rewards: RewardData[];
  categories: string[];
  ineligible_rewards: UnavailableRewardData[];
  user_medals: string[];
}
interface UnavailableRewardData {
  type: string;
  reason: string;
}

interface RewardData {
  type: string;
  title: string;
  desc: string;
  medal: string;
  icon: string;
  category: string;
}

export const MedalRewards = () => {
  const { data } = useBackend<MedalRewardsData>();
  const [searchQuery, setSearchQuery] = useState('');
  const [filterAvailable, setFilterAvailable] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState('All');
  const filteredRewards = data.rewards
    // Never show medals they have not earned
    .filter((reward) =>
      data.user_medals.find((medal) => reward.medal === medal),
    )
    // User selected filters
    .filter(
      (reward) =>
        selectedCategory === 'All' || reward.category === selectedCategory,
    )
    .filter(
      (reward) =>
        !filterAvailable ||
        !data.ineligible_rewards.find(
          (ineligible_reward) => ineligible_reward.type === reward.type,
        ),
    )
    .filter((reward) =>
      (reward.title + reward.desc + reward.medal)
        .toLocaleLowerCase()
        .includes(searchQuery.toLocaleLowerCase()),
    );
  return (
    <Window width={600} height={800} title="Medal Rewards">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <Input
                  fluid
                  value={searchQuery}
                  onChange={setSearchQuery}
                  placeholder="Filter Rewards"
                />
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  checked={filterAvailable}
                  onClick={() => {
                    setFilterAvailable(!filterAvailable);
                  }}
                >
                  Filter Available
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
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
  const ineligible_reason = data.ineligible_rewards.find(
    (ineligible_reward) => ineligible_reward.type === reward.type,
  )?.reason;
  return (
    <Table.Row className="candystripe">
      <Section>
        <Stack py="5px" align="center">
          <Stack.Item>
            <Image width={ICON_SIZE} height={ICON_SIZE} src={reward.icon} />
          </Stack.Item>
          <Stack.Item grow>
            <b>{reward.title}</b>
            <br />
            <BlockQuote>
              {'Earned from medal "'}
              {reward.medal}
              {'"'}
              <br />
              {reward.desc}
            </BlockQuote>
          </Stack.Item>
          <Stack.Item pr="5px">
            <Button
              color={ineligible_reason ? 'grey' : 'green'}
              disabled={!!ineligible_reason}
              tooltip={ineligible_reason}
              onClick={() => act('redeem', { reward_type: reward.type })}
            >
              Redeem
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Table.Row>
  );
};
