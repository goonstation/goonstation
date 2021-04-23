//device for engineers to prepare for and preempt random events

/obj/machinery/interdictor
	name = "spatial interdictor"
	desc = "A sophisticated device that lessens or nullifies the effects of assorted stellar phenomena."
	icon = 'icons/obj/machines/interdictor.dmi'
	icon_state = "interdictor"
	power_usage = 50
	var/obj/item/cell/PCEL = null
	var/active = 1
	var/gridtie = 1
	var/sound/sound_on = "sound/effects/shielddown.ogg"
	var/sound/sound_off = "sound/effects/shielddown2.ogg"
	var/sound/sound_shieldhit = "sound/effects/shieldhit2.ogg"
	var/sound/sound_battwarning = "sound/machines/pod_alarm.ogg"

	New()
		src.PCEL = new /obj/item/cell/supercell(src) //deliberately not charged

		..()

		src.updateicon()

/obj/machinery/interdictor/proc/updateicon()
	var/ratio = min(1, src.PCEL.charge / src.PCEL.maxcharge)
	ratio = round(ratio, 0.33) * 100

	var/image/I_chrg = SafeGetOverlayImage("charge", 'icons/obj/machines/interdictor.dmi', "idx-charge-[ratio]")
	var/image/I_grid = SafeGetOverlayImage("grid", 'icons/obj/machines/interdictor.dmi', "idx-grid-[gridtie]")
	var/image/I_actv = SafeGetOverlayImage("active", 'icons/obj/machines/interdictor.dmi', "idx-active-[active]")

	UpdateOverlays(I_chrg, "charge", 0, 1)
	UpdateOverlays(I_grid, "grid", 0, 1)
	UpdateOverlays(I_actv, "active", 0, 1)
