/**
 * @file
 * @copyright 2023
 * @author DisturbHerb (https://github.com/disturbherb)
 * @license MIT
 */

export interface PhoneData {
  dialing: boolean;
  inCall: boolean;
  lastCalled: string;
  name: string;
  phonebook: Phonebook[];
}

export interface Phonebook {
  category: string;
  phones: PhoneID[];
}

export interface PhoneID {
  id: string;
}
