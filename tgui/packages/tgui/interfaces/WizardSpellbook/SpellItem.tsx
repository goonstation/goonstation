/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend, useSharedState } from '../../backend';
import { Box, Button, Dimmer, Image, LabeledList, Section, Stack } from '../../components';
import { pluralize } from '../common/stringUtils';
import type { EnvironmentProps, SpellData, WizardSpellbookData } from './type';

const THUMBNAIL_SIZE = '32px';

const buildPurchaseText = (purchased: boolean, cost: number, spellSlots: number) => {
  if (purchased) {
    return 'Spell purchased';
  } else if (cost > spellSlots) {
    return 'Not enough spell slots';
  }
  return `Purchase for ${cost} ${pluralize('spell slot', cost)}`;
};

interface SpellItemProps extends EnvironmentProps {
  spell: SpellData;
}

export const SpellItem = (props: SpellItemProps, context) => {
  const { act } = useBackend<WizardSpellbookData>(context);
  const { spell, isVr, spellSlots } = props;
  const { name, desc, cooldown, cost, spell_img, vr_allowed } = spell;
  const [purchased, setPurchased] = useSharedState(context, name + '-purchased', false);

  return (
    <Stack.Item>
      <Section>
        {isVr && !vr_allowed && (
          <Dimmer>
            <Box fontSize={1.5} backgroundColor="#384e68">
              Spell unavailable in VR
            </Box>
          </Dimmer>
        )}
        <Stack vertical>
          <Stack.Item>
            <Stack align="center" height={THUMBNAIL_SIZE}>
              {!!spell_img && (
                <Stack.Item>
                  <Image
                    pixelated
                    height={THUMBNAIL_SIZE}
                    width={THUMBNAIL_SIZE}
                    src={`data:image/png;base64,${spell_img}`}
                  />
                </Stack.Item>
              )}
              <Stack.Item grow fontSize={1.25}>
                <Box>{name}</Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="good"
                  disabled={spellSlots < cost || purchased}
                  onClick={() => {
                    setPurchased(true);
                    act('buyspell', { spell: name });
                  }}>
                  {buildPurchaseText(purchased, cost, spellSlots)}
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              {cooldown && <LabeledList.Item label="Cooldown">{`${cooldown} seconds`}</LabeledList.Item>}
              <LabeledList.Item label="Description">{desc}</LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};
