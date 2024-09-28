/**
 * @file
 * @copyright 2024
 * @author IPingu (https://github.com/IPling)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import {
  Box,
  Button,
  Dimmer,
  Image,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { pluralize } from 'tgui-core/string';

import { useBackend, useSharedState } from '../../backend';
import type { EnvironmentProps, SpellData, WizardSpellbookData } from './type';

const THUMBNAIL_SIZE = '32px';

const buildPurchaseText = (
  purchased: boolean,
  cost: number,
  spellSlots: number,
) => {
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

// needed to standardize a button within the `title` prop of a `Section` component
const titleButtonResetProps = {
  style: { fontWeight: 'normal' },
};

export const SpellItem = (props: SpellItemProps) => {
  const { act } = useBackend<WizardSpellbookData>();
  const { spell, isVr, spellSlots } = props;
  const { name, desc, cooldown, cost, spell_img, vr_allowed } = spell;
  const [purchased, setPurchased] = useSharedState(name + '-purchased', false);

  const title = (
    <Stack align="center">
      {!!spell_img && (
        <Stack.Item height={THUMBNAIL_SIZE}>
          <Image
            height={THUMBNAIL_SIZE}
            width={THUMBNAIL_SIZE}
            src={`data:image/png;base64,${spell_img}`}
          />
        </Stack.Item>
      )}
      <Stack.Item grow>{name}</Stack.Item>
      <Stack.Item>
        <Button
          {...titleButtonResetProps}
          color="good"
          disabled={spellSlots < cost || purchased}
          onClick={() => {
            setPurchased(true);
            act('buyspell', { spell: name });
          }}
        >
          {buildPurchaseText(purchased, cost, spellSlots)}
        </Button>
      </Stack.Item>
    </Stack>
  );
  return (
    <Stack.Item position="relative">
      {isVr && !vr_allowed && (
        <Dimmer>
          <Box fontSize={1.5} backgroundColor="#384e68">
            Spell unavailable in VR
          </Box>
        </Dimmer>
      )}
      <Section title={title}>
        <LabeledList>
          {cooldown && (
            <LabeledList.Item label="Cooldown">{`${cooldown} seconds`}</LabeledList.Item>
          )}
          <LabeledList.Item label="Description">{desc}</LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};
