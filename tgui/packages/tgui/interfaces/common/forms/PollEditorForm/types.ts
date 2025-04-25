/**
 * @file
 * @copyright 2024
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

// not implemented as an enum because the linter gets mad about it, feel free to change if you can work it out
export type ExpiryType = 'never' | 'minutes' | 'hours' | 'days' | 'timestamp';

export interface ExpiryOptions {
  expiryType: ExpiryType | undefined;
  expiryValue: string;
}

export interface PollSettings {
  alertPlayers: boolean;
  expiry: ExpiryOptions;
  multipleChoice: boolean;
  title: string;
  servers: string | undefined;
}
