//A robuddy that has gone mad. plum loco. unhinged. cabin crazy - from halloween.dm

//A spooky outer-space EVIL robuddy.  I guess that makes it...a roBADDY!
/obj/machinery/bot/guardbot/bad
	name = "Secbuddy"
	desc = "An early sub-model of the popular PR-6S Guardbuddy line. It seems to be in rather poor shape."
	icon = 'icons/misc/hstation.dmi'

	control_freq = FREQ_SECBUDDY
	beacon_freq = FREQ_SECBUDDY_NAVBEACON

	no_camera = 1
	flashlight_red = 0.4
	flashlight_green = 0.1
	flashlight_blue = 0.1

	setup_charge_maximum = 800
	setup_default_startup_task = /datum/computer/file/guardbot_task/security/crazy
	setup_default_tool_path = /obj/item/device/guardbot_tool/taser
	no_camera = 1
	req_access_txt = "8088"
	object_flags = 0

	speak(var/message)
		if((!src.on) || (src.idle) || (!message))
			return

		var/scramblemode = rand(1,10)
		switch(scramblemode)
			if (5)
				var/list/stutterList = splittext(message, " ")
				if (stutterList.len > 1)
					var/stutterPoint = rand( round(stutterList.len/2), stutterList.len )
					stutterList.len = stutterPoint
					message = ""

					var/endPoint = stutterList.len + rand(1,3)
					for (var/i = 1, i <= endPoint, i++)
						if (i <= stutterList.len)
							message += "[stutterList[i]] "
						else
							message += "-[uppertext(stutterList[stutterList.len])]"

			if (6)
				var/list/bzztList = splittext(message, " ")
				if (bzztList.len > 1)
					for (var/i = 1, i <= bzztList.len, i++)
						if (prob( min(5*i, 20) ))
							bzztList[i] = pick("*BZZT*","*ERRT*","*WONK*", "*ZORT*", "*BWOP*", "BWEET")

					message = jointext(bzztList, " ")

			if (7)
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='combat'><b>[src]'s speaker crackles oddly!</b></span>", 2)
				return

			if (8)
				message = uppertext(message)

		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
		return
