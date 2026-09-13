/**
 * @file
 * @copyright 2026
 * @author Sovexe (https://github.com/Sovexe)
 * @license ISC
 */

import type { PacketLog } from './type';

export const getPacketField = (packet: PacketLog, key: string) =>
  packet.fields.find((field) => field.key === key)?.value;

export const isNetId = (
  address: string | null | undefined,
): address is string => !!address && /^[0-9a-f]{8}$/i.test(address);

export const displayValue = (value: string | null | undefined) =>
  value === undefined ? '-' : value === '' ? '""' : (value ?? '<NULL>');

export const getPacketSignature = (packet: PacketLog) => {
  if (getPacketField(packet, 'address_1') === 'ping') {
    return 'NETWORK PROBE';
  }
  switch (getPacketField(packet, 'command')) {
    case 'ping_reply':
      return 'DISCOVERY REPLY';
    case 'term_ping':
      // The receiver answers data=reply with a term_ping that has no data.
      return getPacketField(packet, 'data') === 'reply'
        ? 'KEEPALIVE / REPLY REQUESTED'
        : 'KEEPALIVE';
    case 'term_connect':
      return 'CONNECTION HANDSHAKE';
    case 'term_message':
      return 'TERMINAL MESSAGE';
    case 'term_file':
      return 'FILE TRANSFER';
    default:
      return 'UNCLASSIFIED';
  }
};

// This is a text rendering of captured fields, not a serialized wire protocol.
export const formatPacketText = (packet: PacketLog) => {
  const fields = packet.fields
    .map(({ key, value }) => key + '=' + displayValue(value) + ';')
    .join(' ');

  if (!packet.file) {
    return fields || '[NO FIELDS]';
  }

  const { name, extension, content } = packet.file;
  return (
    fields +
    '\n[ATTACHMENT: ' +
    name +
    '.' +
    extension +
    ']\n' +
    (content ?? '[NOT PRINTABLE]')
  );
};
