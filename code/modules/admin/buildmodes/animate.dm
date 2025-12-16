/datum/buildmode/animate
	name = "Animate"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Pick animation<br>
Left Mouse Button on turf/mob/obj      = Animate!<br>
***********************************************************"}
	icon_state = "buildmode_zap"
	var/animation = null

	New()
		..()
		animation = null
		update_button_text("Animate")

	click_mode_right(var/ctrl, var/alt, var/shift)
		var/list/animation_procs = ANIMATE._get_namespace_procs()
		var/animationpick = tgui_input_list(usr, "Select animation.", "Animation", animation_procs, capitalize = FALSE)
		if (animationpick)
			animation = animation_procs[animationpick]
			update_button_text("Animate: [animationpick]")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (animation)
			call(animation)(object)
