///A parent type for borg and AI huds used to hold the shared killswitch stuff
/datum/hud/silicon
	var/mob/living/silicon/silicon
	var/atom/movable/screen/hud/killswitch

	New(M)
		..()
		src.silicon = M
		killswitch = create_screen("killswitch", "OH FUCK YOU'RE KILLSWITCHED", 'icons/mob/hud_ai.dmi', "killswitch", "CENTER, NORTH+0.5", HUD_LAYER)
		killswitch.underlays += "killswitchu"
		killswitch.maptext_width = 256
		killswitch.maptext_height = 128
		killswitch.maptext_x = -112
		killswitch.maptext_y = -129
		killswitch.invisibility = INVIS_ALWAYS

	proc/update_health()
		var/datum/statusEffect/killswitch/killswitch_status
		if (isrobot(silicon))
			var/mob/living/silicon/robot/robot = silicon
			if (robot.mainframe)
				killswitch_status = robot.mainframe.hasStatus("killswitch_ai")
			else
				killswitch_status = silicon.hasStatus("killswitch_robot")
		else if (isshell(silicon))
			var/mob/living/silicon/hivebot/eyebot/eyebot = silicon
			if (eyebot.mainframe)
				killswitch_status = eyebot.mainframe.hasStatus("killswitch_ai")
		else if (isAI(silicon))
			killswitch_status = silicon.hasStatus("killswitch_ai")

		if (killswitch_status)
			var/timeleft = round((killswitch_status.duration)/10, 1)
			timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

			killswitch.invisibility = INVIS_NONE
			killswitch.maptext = "<span class='vga vt c ol' style='color: red;'>KILLSWITCH TIMER\n<span style='font-size: 24px;'>[timeleft]</span></span>"
		else
			killswitch.invisibility = INVIS_ALWAYS
			killswitch.maptext = ""
