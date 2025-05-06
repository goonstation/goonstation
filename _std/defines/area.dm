// NOTE: defines below are marked 0 and > 0 values specifically for true/false checks

/// teleports into this area are allowed
#define AREA_TELEPORT_ALLOWED (1 << 0)
/// teleports, but not porter-machinery summons, into this area are blocked
#define AREA_TELEPORT_BLOCKED (1 << 1)
/// teleports and porter machinery summons into this area are blocked
#define AREA_TELEPORT_AND_PORTER_BLOCKED (1 << 2)
