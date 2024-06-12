/**
 * @file
 * @copyright 2024
 * @author Garash2k (https://github.com/Garash2k)
 * @license ISC
 */

import { MapVoteMapData } from '../MapVote/type';

interface MapVoteReportMapData extends MapVoteMapData {
  count: number,
  voters?: Array<string>
}

export interface MapVoteReportData {
  mapList: Array<MapVoteReportMapData>,
  winner: string
}
