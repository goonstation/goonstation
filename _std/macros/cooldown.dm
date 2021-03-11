
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

#ifdef SPACEMAN_DMM // spacemandmm can't understand the fine art of the "many dots" syntax
/// the [same thing][ON_COOLDOWN] but uses src as the cooldown owner and generates the ID based on the current proc's / verb's path
#define PROC_ON_COOLDOWN(DELAY) UNLINT(FALSE)
#else
#define PROC_ON_COOLDOWN(DELAY) ON_COOLDOWN(src, "[....]", DELAY)
#endif

/* Example use:
/mob/verb/spam_chat()
	if(PROC_ON_COOLDOWN(1 MINUTE))
		boutput(src, "Verb on cooldown for [time_to_text(PROC_ON_COOLDOWN(0))].")
		return
	actually_spam_the_chat()
*/
