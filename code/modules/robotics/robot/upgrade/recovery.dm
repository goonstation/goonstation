/obj/item/roboupgrade/aware
	name = "cyborg recovery upgrade"
	desc = "Allows a cyborg to immediately reboot its systems if incapacitated in any way."
	icon_state = "up-aware"
	active = 1
	drainrate = 3333

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (..())
			return
		boutput(user, "<b>REBOOTING...</b>")
		user.remove_stuns()
		user.blinded = 0
		user.take_eye_damage(-INFINITY)
		user.take_eye_damage(-INFINITY, 1)
		user.blinded = 0
		user.take_ear_damage(-INFINITY)
		user.take_ear_damage(-INFINITY, 1)
		user.change_eye_blurry(-INFINITY)
		user.druggy = 0
		user.change_misstep_chance(-INFINITY)
		user.dizziness = 0
		boutput(user, "<b>REBOOT COMPLETE</b>")
