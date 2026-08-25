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
  icon: string;
}

export const MedalRewards = () => {
  const { data } = useBackend<MedalRewardsData>();
  return (
    <Window width={600} height={800} title="Medal Rewards">
      <Window.Content scrollable>
        <Table>
          {data.rewards.map((reward) => (
            <Reward key={reward.type} reward={reward} />
          ))}
        </Table>
      </Window.Content>
    </Window>
  );
};

interface RewardProps {
  reward: RewardData;
}

const ICON_SIZE = '32px';
const Reward = (props: RewardProps) => {
  const { act, data } = useBackend<MedalRewardsData>();
  const { reward } = props;
  const eligible = !!data.eligible_rewards.find((type) => reward.type === type);
  return (
    eligible && (
      <Table.Row className="candystripe">
        <Stack py="5px">
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
    )
  );
};
