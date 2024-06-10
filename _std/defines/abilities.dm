// Constants for return values. I used the legacy values for ease of find-replace.

/// Cast was successful, deduct points, modify cooldowns, etc
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

// restricted_area_check values. default is 0 (none)
/// Cannot cast on restricted Z levels (mostly Z2 and Z4)
#define ABILITY_AREA_CHECK_ALL_RESTRICTED_Z 1
/// Cannot cast in VR
#define ABILITY_AREA_CHECK_VR_ONLY 2

