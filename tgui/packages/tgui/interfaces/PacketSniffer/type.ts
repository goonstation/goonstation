/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { BooleanLike } from 'tgui-core/react';

export interface PacketField {
  name: string;
  value: string | null;
}

export interface PacketFile {
  name: string;
  extension: string;
  content: string | null;
  size: number;
}

export interface PacketLog {
  sequence: number;
  stamp: string;
  device: string | null;
  fields: Array<PacketField>;
  payload_length: number;
  file?: PacketFile;
}

export interface PacketInfo {
  connected: BooleanLike;
  packet_logs: Array<PacketLog>;
  captured_packets: number;
  max_logs: number;
  filter: string | null;
  destination_filter: string | null;
}

export type FilterProps = {
  filter: string | null;
  destinationFilter: string | null;
  onFilter: (address: string) => void;
  onDestinationFilter: (address: string) => void;
};
