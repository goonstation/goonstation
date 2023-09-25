// Wire Panel Component: Wire Controls
export const WirePanelControls = {
  "WIRE_CONTROL_INERT": 0,
  "WIRE_CONTROL_GROUND": (1<<0),
  "WIRE_CONTROL_POWER_A": (1<<1),
  "WIRE_CONTROL_POWER_B": (1<<2),
  "WIRE_CONTROL_BACKUP_A": (1<<3),
  "WIRE_CONTROL_BACKUP_B": (1<<4),
  "WIRE_CONTROL_SILICON": (1<<5),
  "WIRE_CONTROL_ACCESS": (1<<6),
  "WIRE_CONTROL_SAFETY": (1<<7),
  "WIRE_CONTROL_LIMITER": (1<<8),
  "WIRE_CONTROL_TRIGGER": (1<<9),
  "WIRE_CONTROL_RECEIVE": (1<<10),
  "WIRE_CONTROL_TRANSMIT": (1<<11),
};

export const WirePanelControlLabels = {
  0: "Inert",
  1: "Ground",
  2: "Power",
  4: "Power Alt",
  8: "Backup",
  16: "Backup Alt",
  32: "AI Control",
  64: "ID Scanner",
  128: "Safety",
  256: "Limiter",
  512: "Trigger",
  1024: "Receive",
  2048: "Transmit",
};


// Wire Panel Component: Wire Actions
export const WirePanelActions = {
  "WIRE_ACT_NONE": 0,
  "WIRE_ACT_CUT": (1<<0),
  "WIRE_ACT_MEND": (1<<1),
  "WIRE_ACT_PULSE": (1<<2),
};

// Wire Panel Component: Cover Status
export const WirePanelCoverStatus = {
  "WPANEL_COVER_OPEN": 0,
  "WPANEL_COVER_CLOSED": 1,
  "WPANEL_COVER_BROKEN": 2,
  "WPANEL_COVER_LOCKED": 3,
};
