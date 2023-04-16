#define DMM_SUITE_VERSION 2

// TODO: someone rename the flags so it's clear which are reader and which writer or sometihng

// writer flags
#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24
#define DMM_IGNORE_OVERLAYS 32
#define DMM_IGNORE_SPACE 64

// reader flags
#define DMM_OVERWRITE_MOBS (1 << 0)
#define DMM_OVERWRITE_OBJS (1 << 1)
#define DMM_BESPOKE_AREAS (1 << 2)
#define DMM_LOAD_SPACE (1 << 3)
