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
		killswitch_status = silicon.hasStatus("killswitch_robot") || silicon.hasStatus("killswitch_ai") || silicon.mainframe?.hasStatus("killswitch_ai")
		var/datum/statusEffect/lockdown/lockdown_status
		lockdown_status = silicon.hasStatus("lockdown_robot") || silicon.hasStatus("lockdown_ai") || silicon.mainframe?.hasStatus("lockdown_ai")

		if (killswitch_status)
			src.handle_killswitch_timer(killswitch_status)
		else if (lockdown_status)
			src.handle_lockdown_timer(lockdown_status)
		else
			killswitch.invisibility = INVIS_ALWAYS
			killswitch.maptext = ""

	proc/handle_killswitch_timer(var/datum/statusEffect/killswitch/killswitch_status)
		var/timeleft = round((killswitch_status.duration)/10, 1)
		timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

		killswitch.invisibility = INVIS_NONE
		if(killswitch_status.owner_is_immune())
			killswitch.maptext = "<span class='vga vt c ol' style='color: green;'>KILLSWITCH TIMER: [timeleft]\n You are immune!</span>"
		else
			killswitch.maptext = "<span class='vga vt c ol' style='color: red;'>KILLSWITCH TIMER\n<span style='font-size: 24px;'>[timeleft]</span></span>"

	proc/handle_lockdown_timer(var/datum/statusEffect/lockdown/lockdown_status)
		var/timeleft = round((lockdown_status.duration)/10, 1)
		timeleft = "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]"

		killswitch.invisibility = INVIS_NONE
		if(lockdown_status.fake)
			killswitch.maptext = "<span class='vga vt c ol' style='color: green;'>LOCKDOWN TIMER: [timeleft]\n You are immune!</span>"
		else
			killswitch.maptext = "<span class='vga vt c ol' style='color: yellow;'>LOCKDOWN TIMER\n<span style='font-size: 24px;'>[timeleft]</span></span>"
