import { TileSizeType } from '../../utils';

export const screenToBoard = (
  screenX: number,
  screenY: number,
  tileSize: TileSizeType,
): [number, number] => {
  let boardX = screenX / tileSize.width;
  let boardY = screenY / tileSize.height;
  // alert(screenX + ' ' + screenY);

  return [boardX, boardY];
};
