import { TileSizeData } from '../../utils/types';

export const screenToBoard = (screenX: number, screenY: number, tileSize: TileSizeData): [number, number] => {
  let boardX = screenX / tileSize.width;
  let boardY = screenY / tileSize.height;
  // alert(screenX + ' ' + screenY);

  return [boardX, boardY];
};
