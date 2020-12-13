/**
* uses [/datum/action/bar/icon/callback]
*
* creates an actionbar that calls the specified proc on -either- owner or target if the duration passes without interruption.
*
* icon / icon state can also be set. duration should be in seconds. end message is a string that displays once the action succeeds.
*
* you can directly instantiate a callback actionbar if you need to modify variables on it that the macro doesnt easily let you do.
*
* for instance, callback actionbars have an "args" variable you can modify to call the callback proc with arguements.
*
* just make sure to start it once its been made!
*/
#define SETUP_GENERIC_ACTIONBAR(owner, target, duration, proc_path, action_icon, action_icon_state, end_message) \
	actions.start(new /datum/action/bar/icon/callback(owner, target, duration, proc_path, action_icon, action_icon_state,\
	end_message), owner)

/* example that uses the macro:

/obj/item/foo
	name = "foo"
	icon = 'icons/obj/foo.dmi'
	icon_state = "foo"

	attack_self(var/mob/M)
		M.visible_message("[M] starts fiddling with \the [src].")
		SETUP_GENERIC_ACTIONBAR(M, src, 5 SECONDS, /obj/item/foo/proc/cool_proc, src.icon, src.icon_state,\
		"[M] finishes fiddling with \the [src]")

	proc/cool_proc()
		boutput(world, "farts")
*/

/* example that doesnt use the macro because it needs extra functionality the macro doesnt provide (NOT EVERY SCENARIO, BUT STILL GOOD TO SEE)

/obj/item/foo
	name = "foo"
	icon = 'icons/obj/foo.dmi'
	icon_state = "foo"

	attack_self(var/mob/M)
		M.visible_message("[M] starts fiddling with \the [src].")
		var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(M, src, 5 SECONDS, /obj/item/foo/proc/cool_proc,\
		src.icon, src.icon_state, "[M] finishes fiddling with \the [src]")
		action_bar.proc_args = list("[M]")
		actions.start(action_bar, M)

	proc/cool_proc(var/arg_1)
		boutput(world, "[arg_1] farted!")
*/
