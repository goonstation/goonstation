/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

export interface MapVoteMapData {
  name: string,
  thumbnail: string,
}

export interface MapVoteData {
  playersVoting: boolean,
  mapList: Array<MapVoteMapData>,
  clientVoteMap: any,
}
