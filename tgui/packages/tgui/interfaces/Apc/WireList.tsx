/**
 * @file
 * @copyright 2022-2023
 * @author Original 56Kyle (https://github.com/56Kyle)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { SFC } from 'inferno';
import { useBackend } from '../../backend';
import {
  Button,
  LabeledList,
} from '../../components';
import type { ApcData, ApcWireCutData } from './types';

enum WireColor {
  Orange = 1,
  DarkRed = 2,
  White = 3,
  Yellow = 4,
}

interface WireColorConfig {
  id: WireColor,
  name: string;
  color: string;
  getIsCut: (data: ApcWireCutData) => boolean;
}

const wireColorConfigs: WireColorConfig[] = [
  { id: WireColor.Orange, name: 'Orange', color: 'orange', getIsCut: ({ orange_cut }) => !!orange_cut },
  { id: WireColor.DarkRed, name: 'Dark red', color: 'darkred', getIsCut: ({ dark_red_cut }) => !!dark_red_cut },
  { id: WireColor.White, name: 'White', color: 'white', getIsCut: ({ white_cut }) => !!white_cut },
  { id: WireColor.Yellow, name: 'Yellow', color: 'yellow', getIsCut: ({ yellow_cut }) => !!yellow_cut },
];

export const WireList = (_props, context) => {
  const { act, data } = useBackend<ApcData>(context);

  // #region event handlers
  const handleMend = (wireColor: WireColor) => act('onMendWire', { wire: wireColor });
  const handleCut = (wireColor: WireColor) => act('onCutWire', { wire: wireColor });
  const handlePulse = (wireColor: WireColor) => act('onPulseWire', { wire: wireColor });
  const handleBite = (wireColor: WireColor) => act('onBiteWire', { wire: wireColor });
  // #endregion

  return (
    <LabeledList>
      {wireColorConfigs.map(({ color, getIsCut, id, name }) => (
        <WireListItem
          key={id}
          color={color}
          isCut={getIsCut(data)}
          name={name}
          onBite={() => handleBite(id)}
          onCut={() => handleCut(id)}
          onMend={() => handleMend(id)}
          onPulse={() => handlePulse(id)}
        />
      ))}
    </LabeledList>
  );
};

interface WireProps {
  color: string;
  isCut: boolean;
  name: string;
  onBite: () => void;
  onCut: () => void;
  onMend: () => void;
  onPulse: () => void;
}

export const WireListItem: SFC<WireProps> = (props) => {
  const { color, isCut, name, onBite, onCut, onMend, onPulse } = props;

  const actions = isCut ? (
    <Button content="Mend" onClick={onMend} selected />
  ) : (
    <>
      <Button icon="cut" onClick={onCut}>Cut</Button>
      <Button icon="bolt" onClick={onPulse}>Pulse</Button>
      <Button icon="tooth" onClick={onBite}>Bite</Button>
    </>
  );

  return (
    <LabeledList.Item
      label={`${name} wire`}
      labelColor={color}
      buttons={actions}
    />
  );
};
