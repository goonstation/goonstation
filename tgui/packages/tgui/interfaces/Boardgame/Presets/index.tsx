import { Component, InfernoNode, VNode } from 'inferno';
import chessPresets from './chess';
import draughtsPresets from './draughts';

/* eslint-disable max-len */
export type PresetType = {
  name: string;
  game: string;
  description: string;
  rules?: JSX.Element;
  // string or function that returns string
  setup: string | (() => string);
  boardWidth: number;
  boardHeight: number;
  wikiPage?: string; // Wiki page for the game from https://wiki.ss13.co/
};

export const presets: PresetType[] = [];

presets.push(...chessPresets);
presets.push(...draughtsPresets);

export const getPresetsBySize = (width: number, height: number): PresetType[] => {
  return presets.filter((preset) => preset.boardWidth === width && preset.boardHeight === height);
};

// Create record of all the presets, indexed by game
export const presetsByGame = () => {
  const record: Record<string, PresetType[]> = {};
  presets.forEach((preset) => {
    if (!record[preset.game]) {
      record[preset.game] = [];
    }
    record[preset.game].push(preset);
  });
  return record;
};

export default presets;
