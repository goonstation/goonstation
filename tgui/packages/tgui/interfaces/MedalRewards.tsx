/**
 * @file
 * @copyright 2026
 * @author JORJ949 (https://github.com/JORJ949)
 * @license ISC
 */

import {
  BlockQuote,
  Button,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface MedalRewardsData {
  rewards: RewardData[]; // 0 when all accesses needed, true when any
  eligible_rewards: string[];
}

interface RewardData {
  type: string;
  title: string;
  desc: string;
}

export const MedalRewards = () => {
  const { data } = useBackend<MedalRewardsData>();
  return (
    <Window width={600} height={800}>
      <Window.Content>
        <Section title="Medal Rewards" scrollable fill>
          <Table>
            {data.rewards.map((reward) => (
              <Reward reward={reward} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

interface RewardProps {
  reward: RewardData;
}

const Reward = (props: RewardProps) => {
  const { act, data } = useBackend<MedalRewardsData>();
  const { reward } = props;
  const eligible = !!data.eligible_rewards.find((type) => reward.type === type);
  return (
    eligible && (
      <Table.Row className="candystripe">
        <Stack py="5px">
          <Stack.Item grow>
            <b>{reward.title}</b>
            <br />
            <BlockQuote>{reward.desc}</BlockQuote>
          </Stack.Item>
          <Stack.Item align="right">
            <Button onClick={() => act('redeem', { reward_type: reward.type })}>
              Redeem
            </Button>
          </Stack.Item>
        </Stack>
      </Table.Row>
    )
  );
};
