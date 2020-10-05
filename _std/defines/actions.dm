/// Internal flag that will always interrupt any action.
#define INTERRUPT_ALWAYS -1
/// Interrupted when object moves
#define INTERRUPT_MOVE 1
/// Interrupted when object does anything
#define INTERRUPT_ACT 2
/// Interrupted when object is attacked
#define INTERRUPT_ATTACKED 4
/// Interrupted when owner is stunned or knocked out etc.
#define INTERRUPT_STUNNED 8
/// Interrupted when another action is started.
#define INTERRUPT_ACTION 16

/// Action has not been started yet.
#define ACTIONSTATE_STOPPED 1
/// Action is in progress
#define ACTIONSTATE_RUNNING 2
/// Action was interrupted
#define ACTIONSTATE_INTERRUPTED 4
/// Action ended succesfully
#define ACTIONSTATE_ENDED 8
/// Action is ready to be deleted.
#define ACTIONSTATE_DELETE 16
/// Will finish action after next process.
#define ACTIONSTATE_FINISH 32
/// Will not finish unless interrupted.
#define ACTIONSTATE_INFINITE 64
