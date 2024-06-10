import { GameKit } from '.';
import chessKit from './chess';
import draughtsKit from './draughts';

// Add new kits here

export type GameName = 'chess' | 'draughts';

export const kits: GameKit[] = [chessKit, draughtsKit];
