/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { BooleanLike } from 'tgui-core/react';

export interface PacketField {
  key: string;
  value: string | null;
}

export interface PacketLog {
  sequence: number;
  stamp: string;
  device: string | null;
  fields: Array<PacketField>;
  payload_length: number;
  file?: {
    name: string;
    extension: string;
    content: string | null;
    size: number;
  };
}

export interface PacketInfo {
  connected: BooleanLike;
  packet_logs: Array<PacketLog>;
  captured_packets: number;
  max_logs: number;
  filter: string | null;
}

export type FilterProps = {
  filter: string | null;
  onFilter: (address: string) => void;
};
