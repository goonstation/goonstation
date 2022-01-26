/datum/buildmode/animate
	name = "Animate"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Pick animation<br>
Left Mouse Button on turf/mob/obj      = Animate!<br>
***********************************************************"}
	icon_state = "buildmode_zap"
	var/animation = null
	var/list/animations = list(
		/proc/animate_buff_in,
		/proc/animate_buff_out,
		/proc/animate_melt_pixel,
		/proc/animate_explode_pixel,
		/proc/animate_weird,
		/proc/animate_door_squeeze,
		/proc/animate_flockdrone_item_absorb,
		/proc/animate_flock_convert_complete,
		/proc/animate_flock_drone_split,
		/proc/animate_flock_passthrough,
		/proc/animate_flock_floorrun_start,
		/proc/animate_flock_floorrun_end,
		/proc/animate_tile_dropaway,
		/proc/attack_twitch,
		/proc/hit_twitch,
		/proc/violent_twitch,
		/proc/violent_standup_twitch,
		/proc/eat_twitch,
		/proc/animate_portal_appear,
		/proc/animate_portal_tele,
		/proc/animate_glitchy_freakout,
		/proc/animate_fading_leap_up,
		/proc/animate_fading_leap_down,
		/proc/animate_teleport,
		/proc/animate_teleport_wiz,
		/proc/animate_rainbow_glow_old,
		/proc/animate_rainbow_glow,
		/proc/animate_clownspell,
		/proc/animate_blink,
		/proc/animate_shockwave,
		/proc/animate_glitchy_fuckup1,
		/proc/animate_glitchy_fuckup2,
		/proc/animate_glitchy_fuckup3,
		/proc/animate_storage_rustle,
		/proc/spawn_animation1,
		/proc/leaving_animation,
		/proc/animate_storage_thump,
		/proc/animate_open_from_floor,
		/proc/animate_close_into_floor,
		/proc/animate_wave,
		/proc/animate_ripple
	)

	New()
		..()
		animation = null
		update_button_text("Animate")

	click_mode_right(var/ctrl, var/alt, var/shift)
		var/animationpick = input("Select animation.", "anim8", null) in animations
		if (animationpick)
			animation = animationpick
			update_button_text("Animate: [animationpick]")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (animation)
			call(animation)(object)
