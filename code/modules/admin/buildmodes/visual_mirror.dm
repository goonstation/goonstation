/datum/buildmode/visual_mirror
	name = "Visual Mirror Setup"
	desc = {"<pre>***********************************************************
Right Mouse Button on buildmode button = Start calibration
Ctrl-RMB on buildmode button           = Manual calibration
Shift-RMB on buildmode button          = Toggle warpmode on/off
Left Mouse Button on turf              = Create mirror zone
Shift-LMB on turf                      = Cleanup mirror zone
***********************************************************</pre>"}
	icon_state = "buildmode_zap"
	var/offset_x = 0
	var/offset_y = 0
	var/target_z = 1
	var/warp_mode = LANDMARK_VM_WARP_ALL
	var/calibration_stage = 0
	var/turf/source_turf
	var/turf/target_turf
	var/image/marker

	New(datum/buildmode_holder/H)
		. = ..()
		update_button_text("Offset: [src.offset_x], [src.offset_y] | Target Z: [src.target_z] | Warp mode: [src.warp_mode == LANDMARK_VM_WARP_NONE ? "Off" : "On"]")
		marker = image('icons/misc/buildmode.dmi', "marker")
		marker.plane = PLANE_OVERLAY_EFFECTS
		marker.layer = NOLIGHT_EFFECTS_LAYER_BASE
		marker.appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM | PIXEL_SCALE

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (shift)
			if (warp_mode == LANDMARK_VM_WARP_NONE)
				warp_mode = LANDMARK_VM_WARP_ALL
				update_button_text("Offset: [src.offset_x], [src.offset_y] | Target Z: [src.target_z] | Warp mode: [src.warp_mode == LANDMARK_VM_WARP_NONE ? "Off" : "On"]")
			else
				warp_mode = LANDMARK_VM_WARP_NONE
				update_button_text("Offset: [src.offset_x], [src.offset_y] | Target Z: [src.target_z] | Warp mode: [src.warp_mode == LANDMARK_VM_WARP_NONE ? "Off" : "On"]")
			return
		else if (ctrl)//manual input
			//x
			src.offset_x = tgui_input_number(src.holder.owner.mob, "Enter X offset", "Manual Calibration", 0)
			if (isnull(src.offset_x))
				update_button_text("Invalid input")
				return
			//y
			src.offset_y = tgui_input_number(src.holder.owner.mob, "Enter Y offset", "Manual Calibration", 0)
			if (isnull(src.offset_y))
				update_button_text("Invalid input")
				return
			//z
			src.target_z = tgui_input_number(src.holder.owner.mob, "Enter Target Z", "Manual Calibration", 1, min_value = 1)
			if (isnull(src.target_z))
				update_button_text("Invalid input")
				return
			update_button_text("Offset: [src.offset_x], [src.offset_y] | Target Z: [src.target_z] | Warp mode: [src.warp_mode == LANDMARK_VM_WARP_NONE ? "Off" : "On"]")
			return
		else
			src.calibration_stage = 1
			update_button_text("Left click the mirror source / warp exit turf")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (shift) //cleanup
			var/turf/T = get_turf(object)
			if (!T) return
			blink(get_turf(object))
			if (T.vistarget)
				//remove mirror
				T.vistarget.vis_contents -= T
				T.vistarget.warptarget = null
				//fix lights
				T.vistarget.fullbright = initial(T.vistarget.fullbright)
				T.vistarget.RL_Init()
				T.vistarget = null
			else if (T.warptarget)
				//remove mirror
				T.vis_contents -= T.warptarget
				//fix lights
				T.fullbright = initial(T.fullbright)
				T.RL_Init()
				T.warptarget.vistarget = null
				T.warptarget = null
			else if (locate(/turf) in T.vis_contents)
				var/turf/linked_turf = locate(/turf) in T.vis_contents
				linked_turf.vistarget = null
				T.vis_contents -= linked_turf
				T.fullbright = initial(T.fullbright)
				T.RL_Init()
			return
		else
			switch (src.calibration_stage)
				if(1)
					src.source_turf = get_turf(object)
					if (!istype(src.source_turf))
						update_button_text("An error occured")
						return
					update_button_text("Left click the mirror display / warp enterance turf")
					src.calibration_stage = 2
					src.marker.loc = src.source_turf
					src.holder.owner.images += marker
					blink(get_turf(object))
				if (2)
					src.target_turf = get_turf(object)
					if (!istype(src.target_turf))
						update_button_text("An error occured")
						return
					src.offset_x = src.target_turf.x - src.source_turf.x
					src.offset_y = src.target_turf.y - src.source_turf.y
					src.target_z = src.target_turf.z
					update_button_text("Offset: [src.offset_x], [src.offset_y] | Target Z: [src.target_z] | Warp mode: [src.warp_mode == LANDMARK_VM_WARP_NONE ? "Off" : "On"]")
					src.calibration_stage = 0
					src.source_turf = null
					src.target_turf = null
					src.holder.owner.images -= marker
					blink(get_turf(object))
				else
					new /obj/landmark/viscontents_spawn(get_turf(object), src.offset_x, src.offset_y, src.target_z, src.warp_mode)
					blink(get_turf(object))
