/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

export enum WirePanelControl {
  Inert = 0,
  Ground = (1 << 0),
  PowerA = (1 << 1),
  PowerB = (1 << 2),
  BackupA = (1 << 3),
  BackupB = (1 << 4),
  Silicon = (1 << 5),
  Access = (1 << 6),
  Safety = (1 << 7),
  Limiter = (1 << 8),
  Trigger = (1 << 9),
  Recieve = (1 << 10),
  Transmit = (1 << 11),
}

export const WirePanelControlLabelMap = {
  [WirePanelControl.Inert]: "Inert",
  [WirePanelControl.Ground]: "Ground",
  [WirePanelControl.PowerA]: "Power",
  [WirePanelControl.PowerB]: "Power Alt",
  [WirePanelControl.BackupA]: "Backup",
  [WirePanelControl.BackupB]: "Backup Alt",
  [WirePanelControl.Silicon]: "AI Control",
  [WirePanelControl.Access]: "ID Scanner",
  [WirePanelControl.Safety]: "Safety",
  [WirePanelControl.Limiter]: "Limiter",
  [WirePanelControl.Trigger]: "Trigger",
  [WirePanelControl.Recieve]: "Receive",
  [WirePanelControl.Transmit]: "Transmit",
};

export enum WirePanelAction {
  None = 0,
  Cut = (1 << 0),
  Mend = (1 << 1),
  Pulse = (1 << 2),
}

export enum WirePanelCoverStatus {
  Open,
  Closed,
  Broken,
  Locked
}
