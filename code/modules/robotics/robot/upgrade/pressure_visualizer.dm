/obj/item/roboupgrade/pressure_visualizer
	name = "cyborg pressure visualizer upgrade"
	desc = "A sensing array that enables a cyborg to see atmospheric pressures."
	icon_state = "up-convis"
	drainrate = 5
	borg_overlay = "up-meson"
	var/list/image/atmos_overlays = list()
	//this is literally just a 32x32 white square, someone please tell me if there's a less dumb way to do this
	var/icon/overlay_icon = 'icons/effects/effects.dmi'
	var/overlay_state = "atmos_overlay"

/obj/item/roboupgrade/pressure_visualizer/upgrade_activate(mob/living/silicon/robot/user)
	if (..())
		return
	global.processing_items |= src

/obj/item/roboupgrade/pressure_visualizer/upgrade_deactivate(mob/living/silicon/robot/user)
	if (..())
		return
	global.processing_items -= src

/obj/item/roboupgrade/pressure_visualizer/proc/clear_overlays(mob/M)
	if (!M.client)
		return
	for (var/image/image as anything in src.atmos_overlays)
		M.client.images -= image
	src.atmos_overlays = list()

/obj/item/roboupgrade/pressure_visualizer/proc/generate_overlays(mob/M)
	if (!M.client)
		return
	for (var/turf/simulated/T in view(M, M.client.view))
		if (!T.air)
			continue
		var/image/new_overlay = image(src.overlay_icon, T, src.overlay_state)
		var/relative_pressure = MIXTURE_PRESSURE(T.air)/ONE_ATMOSPHERE
		//make more orange if over one atmosphere
		new_overlay.color = rgb(91 * (max(1,relative_pressure)), 103, 231 / (max(1,relative_pressure)))
		new_overlay.alpha = 0
		animate(new_overlay, alpha=min(200, 200 * relative_pressure), time=2 DECI SECONDS)
		animate(alpha=0, time=2 SECONDS)
		src.atmos_overlays += new_overlay
		M.client.images += new_overlay

/obj/item/roboupgrade/pressure_visualizer/process()
	var/mob/M = src.loc
	if (!istype(M) || !M.client)
		return
	src.clear_overlays(M)
	src.generate_overlays(M)
