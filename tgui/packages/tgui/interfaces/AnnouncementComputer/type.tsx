/**
 * @file
 * @copyright 2024
 * @author Valtsu0 (https://github.com/Valtsu0)
 * @license ISC
 */

import { BooleanLike } from 'tgui-core/react';

export interface AnnouncementCompData {
  announces_arrivals: BooleanLike;
  arrivalalert: string;
  theme: string;
  card_name: string;
  status_message: string;
  time: number;
  max_length: number;
}
