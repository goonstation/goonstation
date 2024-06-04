/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

export interface MapVoteMapData {
  id: string,
  name: string
}

export interface MapVoteData {
  playersVoting: boolean,
  mapList: Array<MapVoteMapData>,
  clientVoteMap: any,
}
