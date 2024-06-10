
/*
 * assumes that COOLDOWN_OWNER has a (not necessarily initialized) associative list `cooldowns` (it will store the timestamp when the thing goes off cooldown next)
 * currently all atoms and /datum/player have this list, you can also use it with `global` for global cooldowns
 * returns time left on the cooldown with id ID, and if it was 0 it sets it to DELAY
 */

/**
	* # Simple Cooldown System
	* Easy way to set cooldowns on an object.
	*
	* Arguments:
	* * COOLDOWN_OWNER: The object to store the cooldown data on. Can be `global`.
	* * ID: The specific ID of the cooldown, ex. "ahelp"
	* * DELAY: The amount of time(ds) that you want the cooldown to last.
	*
	* Usage:
	* ```
	*	if(!ON_COOLDOWN(global, "butt_talker", src.butt_cooldown))
	*		speak(pick("butts", "butt"))
	* ```
	*/
#define ON_COOLDOWN(COOLDOWN_OWNER, ID, DELAY) (\
	isnull(COOLDOWN_OWNER.cooldowns) && (COOLDOWN_OWNER.cooldowns = list()) && 0 || \
	max(COOLDOWN_OWNER.cooldowns[ID] - TIME, 0) || \
	(COOLDOWN_OWNER.cooldowns[ID] = TIME + DELAY) && 0)

/// like [ON_COOLDOWN] but only gets the cooldown, doesn't refresh it
#define GET_COOLDOWN(COOLDOWN_OWNER, ID) (isnull(COOLDOWN_OWNER.cooldowns) ? 0 : max(COOLDOWN_OWNER.cooldowns[ID] - TIME, 0))

/// overrides cooldown to this value
#define OVERRIDE_COOLDOWN(COOLDOWN_OWNER, ID, DELAY) (\
	isnull(COOLDOWN_OWNER.cooldowns) && (COOLDOWN_OWNER.cooldowns = list()) && 0 || \
	(COOLDOWN_OWNER.cooldowns[ID] = TIME + DELAY))

/// overrides cooldown to the maximum of the current cooldown and this value
#define EXTEND_COOLDOWN(COOLDOWN_OWNER, ID, DELAY) (\
	isnull(COOLDOWN_OWNER.cooldowns) && (COOLDOWN_OWNER.cooldowns = list()) && 0 || \
	(COOLDOWN_OWNER.cooldowns[ID] = max(COOLDOWN_OWNER.cooldowns[ID], TIME + DELAY)))
