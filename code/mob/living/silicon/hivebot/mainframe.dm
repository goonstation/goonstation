/mob/living/silicon/hive_mainframe
	name = "Robot Mainframe"
	voice_name = "synthesized voice"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "hive_main"
	health = 200
	var/health_max = 200
	robot_talk_understand = 2

	anchored = 1
	var/online = 1
	var/mob/living/silicon/hivebot = null
	var/hivebot_name = null
	var/force_mind = 0

/mob/living/silicon/hive_mainframe/New()
	. = ..()
	Namepick()

/mob/living/silicon/hive_mainframe/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return 1
	if (isdead(src))
		return
	else
		health_update_queue |= src

		if (src.health <= 0)
			death()
			return

	if(src.force_mind)
		if(!src.mind)
			if(src.client)
				src.mind = new
				src.mind.ckey = ckey
				src.mind.key = src.key
				src.mind.current = src
				ticker.minds += src.mind
		src.force_mind = 0

	update_icons_if_needed()

/mob/living/silicon/hive_mainframe/death(gibbed)
	setdead(src)
	src.canmove = 0
	vision.set_color_mod("#ffffff") // reset any blindness
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS
	src.see_in_dark = SEE_DARK_FULL
	src.see_invisible = INVIS_CLOAK
	src.lying = 1
	src.icon_state = "hive_main-crash"

	src.mind?.register_death()

	return ..(gibbed)


/mob/living/silicon/hive_mainframe/say_understands(var/other)
	if (ishuman(other))
		var/mob/living/carbon/human/H = other
		if(!H.mutantrace || !H.mutantrace.exclusive_language)
			return 1
	if (isrobot(other))
		return 1
	if (ishivebot(other))
		return 1
	if (isAI(other))
		return 1
	return ..()

/mob/living/silicon/hive_mainframe/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))]\"";

	return "states, \"[text]\"";


/mob/living/silicon/hive_mainframe/proc/return_to(var/mob/user)
	if(user.mind)
		user.mind.transfer_to(src)
		SPAWN(2 SECONDS)
			if (user)
				user:shell = 1
				user:real_name = "Robot [pick(rand(1, 999))]"
				user:name = user:real_name


		return

/mob/living/silicon/hive_mainframe/verb/cmd_deploy_to()
	set category = "Mainframe Commands"
	set name = "Deploy to shell."
	deploy_to()

/mob/living/silicon/hive_mainframe/verb/deploy_to()

	if(isdead(usr))
		boutput(usr, "You can't deploy because you are dead!")
		return

	var/list/bodies = new/list()

	for(var/mob/living/silicon/hivebot/H in mobs)
		if(H.z == src.z)
			if(H.shell)
				if(!H.stat)
					bodies += H

	var/target_shell = tgui_input_list(usr, "Which body to control?", "Deploy", sortList(bodies, /proc/cmp_text_asc))

	if (!target_shell)
		return

	else if(src.mind)
		SPAWN(3 SECONDS)
			target_shell:mainframe = src
			target_shell:dependent = 1
			target_shell:real_name = src.name
			target_shell:name = target_shell:real_name
		src.mind.transfer_to(target_shell)
		return


/client/proc/MainframeMove(n,direct,var/mob/living/silicon/hive_mainframe/user)
	return

/mob/living/silicon/hive_mainframe/Login()
	..()
	update_clothing()
	return



/mob/living/silicon/hive_mainframe/proc/Namepick()
	var/randomname = pick_string_autokey("names/ai.txt")
	var/newname = input(src,"You are the a Mainframe Unit. Would you like to change your name to something else?", "Name change",randomname) as text

	if (length(newname) == 0)
		newname = randomname

	if (newname)
		if (length(newname) >= 26)
			newname = copytext(newname, 1, 26)
		newname = strip_html(newname)
		src.real_name = newname
		src.UpdateName()
