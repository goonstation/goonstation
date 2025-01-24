/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { Box, Button, Collapsible, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ContributorRewardsData {
  rewardDescs;
  rewardTitles;
}

export const ContributorRewards = () => {
  const { act, data } = useBackend<ContributorRewardsData>();
  const { rewardTitles, rewardDescs } = data;
  return (
    <Window title="Contributor Rewards" width={350} height={200}>
      <Window.Content scrollable>
        {
          "Howdy, contributor! These rewards don't revert until you respawn somehow."
        }
        <Section>
          <Box>
            {rewardTitles.map((_item, index) => (
              <Collapsible key={index} title={rewardTitles[index]} open>
                {rewardDescs[index]}
                <Button
                  ml={1}
                  icon="check-circle"
                  onClick={() => act('redeem', { reward_idx: index + 1 })}
                >
                  Redeem
                </Button>
              </Collapsible>
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
