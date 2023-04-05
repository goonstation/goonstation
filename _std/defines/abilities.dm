// Constants for return values. I used the legacy values for ease of find-replace.

/// Cast was successful
#define CAST_ATTEMPT_SUCCESS 0
/** Awful name, I'm sorry. tryCast() calls cast(), and this is the value returned from cast() if something goes wrong,
 * 	which is then relayed and returned by tryCast(). Think of it as 'tryCast() failed because cast() failed'.
 * 	This is also sometimes used early on in tryCast to abort early if something is really wrong, so uhhh
 */
#define CAST_ATTEMPT_FAIL_CAST_FAILURE 1
/// Cast failed, but we want to put it on cooldown. This is the only return which will cause a cooldown.
#define CAST_ATTEMPT_FAIL_DO_COOLDOWN 998
/// Cast failed for some reason, we don't want to start the cooldown
#define CAST_ATTEMPT_FAIL_NO_COOLDOWN 999
/// Same as above, specifically when we don't have enough points to cast the ability
#define CAST_ATTEMPT_FAIL_POINTS 1000
