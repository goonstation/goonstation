/*
 *
 *
 *
 *
 */
/// Admin PM
#define CTX_PM 1
/// Subtle Message
#define CTX_SMSG 2
/// Kick
#define CTX_BOOT 4
/// Ban
#define CTX_BAN 8
/// Gib
#define CTX_GIB 16
/// Player Options
#define CTX_POPT 32
/// Jump To Area
#define CTX_JUMP 64
/// Bring To User
#define CTX_GET 128
/// Observe
#define CTX_OBSERVE 256
/// Jump To Turf
#define CTX_GHOSTJUMP 512

#define CTX_FLAGS_ADMIN (CTX_GIB | CTX_GET | CTX_FLAGS_SECONDARY_ADMIN)
#define CTX_FLAGS_SECONDARY_ADMIN (CTX_BAN | CTX_POPT | CTX_JUMP | CTX_FLAGS_MODERATOR)
#define CTX_FLAGS_MODERATOR (CTX_SMSG | CTX_BOOT | CTX_PM | CTX_FLAGS_DEAD)
#define CTX_FLAGS_DEAD (CTX_OBSERVE | CTX_GHOSTJUMP)

/// Sets client context flags and returns them
/client/proc/set_context_flags()
	if (istype(src.mob, /mob/dead/observer))
		src.ctx_flags |= CTX_FLAGS_DEAD

	if (src.holder && !src.player_mode)
		var/level = src.holder.level
		// ADMIN / CODER / HOST
		if (level >= LEVEL_ADMIN)
			src.ctx_flags |= CTX_FLAGS_ADMIN
		// SA / IA / PA
		else if (level >= LEVEL_SA)
			src.ctx_flags |= CTX_FLAGS_SECONDARY_ADMIN
		else if (level == LEVEL_MOD)
			src.ctx_flags |= CTX_FLAGS_MODERATOR

	return src.ctx_flags

/// Set a client context flag
/client/proc/set_context_flag(var/flag)
	src.ctx_flags |= flag

/// Get client context flags
/client/proc/get_context_flags()
	return src.ctx_flags

/// Clear client context flags
/client/proc/clear_context_flags()
	src.ctx_flags = null

/// Called from TGui panel to do the context menu command
/client/proc/handle_ctx_menu(command, target)
	// Make sure that only those that should be able to use this can
	if (!istype(src.mob, /mob/dead/observer) && !src.holder)
		return
	var/datum/mind/target_mind = locate(target)
	var/mob/target_mob
	if (!target_mind)
		return
	target_mob = target_mind.current

	if (!target_mob)
		return
#ifdef LIVE_SERVER
	// you probably don't want to context act yourself... unless testing locally
	if (target_mob == src.mob)
		return
#endif

	switch(command)
		if ("pm")
			src.cmd_admin_pm(target_mob)

		if ("smsg")
			src.cmd_admin_subtle_message(target_mob)

		if ("jump")
			if (!istype(target_mob, /mob/dead/target_observer))
				src.jumptomob(target_mob)
			else
				var/jumptarget = target_mob.eye
				if (jumptarget)
					src.jumptoturf(get_turf(jumptarget))

		if ("get")
			if (tgui_alert(src, "Are you sure you want to get [target_mob]?", "Confirmation", list("Yes", "No")) == "Yes")
				src.Getmob(target_mob)

		if ("boot")
			src.cmd_boot(target_mob)

		if ("ban")
			src.addBanTempDialog(target_mob)

		if ("gib")
			src.cmd_admin_gib(target_mob)
			logTheThing(LOG_ADMIN, src, "gibbed [constructTarget(target_mob,"admin")].")

		if ("popt")
			if (src.holder)
				src.holder.playeropt(target_mob)

		if ("observe")
			if (istype(src.mob, /mob/dead/target_observer))
				var/mob/dead/target_observer/obs = src.mob
				if (!obs.locked)
					obs.set_observe_target(target_mob)
			if (istype(src.mob, /mob/dead/observer))
				src.mob:insert_observer(target_mob)

		if ("teleport")
			if (istype(src.mob, /mob/dead/target_observer))
				var/mob/dead/target_observer/obs = src.mob
				if (!obs.locked)
					qdel(src.mob)
			if(istype(src.mob, /mob/dead/observer))
				src.mob.set_loc(get_turf(target_mob))
