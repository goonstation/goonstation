/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { BooleanLike } from 'tgui-core/react';

export interface WizardSpellbookData {
  spellbook_contents: Record<string, SpellData[]>;
  spell_slots: number;
  owner_name: string;
  vr: BooleanLike;
}

export interface SpellData {
  name: string;
  desc: string;
  cost: number;
  cooldown: number | null;
  vr_allowed: BooleanLike;
  spell_img: string | null;
}

export interface EnvironmentProps {
  isVr: boolean;
  spellSlots: number;
}
