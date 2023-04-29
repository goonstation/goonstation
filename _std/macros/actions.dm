/**
 * Creates an actionbar that calls the specified `proc_path` on -either- owner or target if the duration passes without interruption.
 *
 * `icon` / `icon_state` can also be set. `duration` should be in seconds. `end_message` is a string that displays once the action succeeds.
 *
 * You can also directly instantiate a [callback actionbar][/datum/action/bar/icon/callback] if you need to modify variables on it that the macro doesnt easily let you do.
 * For instance, callback actionbars have an `args` variable you can modify to call the callback proc with arguements. Just make sure to start it once its been made!
 *
 * Example:
 * ```
 * /obj/item/foo
 * 	name = "foo"
 * 	icon = 'icons/obj/foo.dmi'
 * 	icon_state = "foo"
 *
 * 	attack_self(var/mob/M)
 * 		M.visible_message("[M] starts fiddling with \the [src].")
 * 		SETUP_GENERIC_ACTIONBAR(M, src, 5 SECONDS, /obj/item/foo/proc/cool_proc, list(M, src), src.icon, src.icon_state,\
 * 		"[M] finishes fiddling with \the [src]", null)
 *
 * 	proc/cool_proc(var/mob/arg_1, var/obj/item/arg_2)
 * 		boutput(world, "[arg_1.name] farted, [arg_2.name]!")
 * ```
 */
#define SETUP_GENERIC_ACTIONBAR(owner, target, duration, proc_path, proc_args, action_icon, action_icon_state, end_message, interrupt_flags) \
	actions.start(new /datum/action/bar/icon/callback(owner, target, duration, proc_path, proc_args, action_icon, action_icon_state,\
	end_message, interrupt_flags), owner)

/// The same thing but only the owner can see it
#define SETUP_GENERIC_PRIVATE_ACTIONBAR(owner, target, duration, proc_path, proc_args, action_icon, action_icon_state, end_message, interrupt_flags) \
	actions.start(new /datum/action/bar/private/icon/callback(owner, target, duration, proc_path, proc_args, action_icon, action_icon_state,\
	end_message, interrupt_flags), owner)
