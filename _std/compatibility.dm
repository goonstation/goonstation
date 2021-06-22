
// Compatibility checks
#if DM_VERSION < 514 && !defined(SPACEMAN_DMM)

#error =======================================================================================
#error Please update your BYOND to the version in /buildByond.conf in order to build the game.
#error =======================================================================================

#else
#define BYOND_VERSION_OK
#endif
