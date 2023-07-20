/**
 * @file
 * @copyright 2022
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Collapsible, Box, Section } from '../components';
import { Window } from '../layouts';

export const ContributorRewards = (_props, context) => {
  const { act, data } = useBackend(context);
  const {
    rewardTitles,
    rewardDescs,
  } = data;
  return (
    <Window
      resizable
      title="Contributor Rewards"
      width={350}
      height={200}>
      <Window.Content scrollable>
        {"Howdy, contributor! These rewards don't revert until you respawn somehow."}
        <Section>
          <Box>
            {rewardTitles.map((_item, index) => (
              <Collapsible
                key={index}
                title={rewardTitles[index]}
                open>
                {rewardDescs[index]}
                <Button
                  ml={1}
                  icon="check-circle"
                  content="Redeem"
                  onClick={() => act("redeem", { reward_idx: index+1 })}
                />
              </Collapsible>
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
