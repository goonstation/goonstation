/// Are we running tutorial code on this server?
//#define TUTORIAL_ENABLED
/// Is the tutorial available for us to send players to?
//#define TUTORIAL_AVAILABLE FALSE

#ifdef TUTORIAL_ENABLED
#include "_tutorial_defines.dm"
#include "tutorial_box.dm"
#include "tutorial_controller.dm"
#include "tutorial_group.dm"
#include "tutorial_manager.dm"
#include "tutorial_player_state.dm"
#include "tutorial_stage.dm"
#include "tutorial_task.dm"
#include "stages\stage_examine.dm"
#endif
