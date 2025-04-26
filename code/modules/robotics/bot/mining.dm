/obj/machinery/bot/mining
	name = "Digbot"
	desc = "A little robot with a pickaxe. He looks so jazzed to go hit some rocks!"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "digbot0"
	var/const/base_sprite_pixels_from_floor = 5
	layer = 5
	density = 0
	anchored = UNANCHORED
	on = 0
	var/digging = 0
	health = 25
	var/diglevel = 2
	var/digsuspicious = 0
	var/hardthreshold = 2
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	var/list/digbottargets = list()
	var/lumlevel = 0.2
	var/use_medium_light = 1
	var/image/display_hover = null
	var/image/display_tool_idle = null
	var/image/display_tool_animated = null
	var/datum/digbot_ui/ui = null

/obj/machinery/bot/mining/New()
	..()
	src.ui = new/datum/digbot_ui(src)
	setupOverlayVars()
	sleep(5)
	if(on)
		turnOn()
	else
		setEffectOverlays()

/obj/machinery/bot/mining/proc/setupOverlayVars()
	src.display_hover = image('icons/obj/bots/aibots.dmi', "digbot hover")
	src.display_tool_idle = image('icons/obj/bots/aibots.dmi', "digbot powerpick idle")
	src.display_tool_animated = image('icons/obj/bots/aibots.dmi', "digbot powerpick digging")

/obj/machinery/bot/mining/proc/togglePowerSwitch()
	src.on = !src.on
	if(src.on)
		turnOn()
	else
		turnOff()
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.path = null
	src.updateUsrDialog()

/obj/machinery/bot/mining/proc/turnOn()
	src.on = 1
	src.add_sm_light("digbot\ref[src]", list(255,255,255,lumlevel * 255), use_medium_light)
	setEffectOverlays()

/obj/machinery/bot/mining/proc/turnOff()
	src.on = 0
	src.remove_sm_light("digbot\ref[src]")
	setEffectOverlays()

/obj/machinery/bot/mining/proc/setEffectOverlays()
	src.icon_state = "digbot[on]"
	if(src.on)
		src.UpdateOverlays(display_hover, "hover")
		pixel_y = 0
	else
		src.UpdateOverlays(null, "hover")
		var/const/volume = 50
		var/const/vary = 1
		playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', volume, vary)
		pixel_y = -base_sprite_pixels_from_floor
	if(src.digging)
		src.UpdateOverlays(display_tool_animated, "tool")
	else
		src.UpdateOverlays(display_tool_idle, "tool")

/obj/machinery/bot/mining/attack_hand(user)
	src.add_fingerprint(user)
	ui.show_ui(user)

/obj/machinery/bot/mining/attack_ai()
	togglePowerSwitch()

/obj/machinery/bot/mining/attackby(var/obj/item/W , mob/user as mob)
	src.add_fingerprint(user)
	//////////////////////
	///Emagged code///////
	//////////////////////
	if ((istype(W, /obj/item/card/emag)) && (!src.emagged))
		boutput(user,  SPAN_ALERT("You short out [src]. It.. didn't really seem to affect anything, though."))
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='alert bold'><B>[src] buzzes oddly!</span>", 1)
		src.target = null
		src.oldtarget = null
		src.anchored = UNANCHORED
		src.emagged = 1
		if(!src.on)
			turnOn()

/obj/machinery/bot/mining/process()
	if(!src.on) return
	if(src.digging) return
	if(!istype(target, /turf/simulated/wall/auto/asteroid/))
		src.target = null
	if(!src.target)
		src.findTarget()
	if(!src.target)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && (!src.path || !length(src.path)))
		src.buildPath()

	if(src.path && src.path.len && src.target)
		step_to(src, src.path[1])
		src.path -= src.path[1]

	if(src.target in range(1,src))
		startToolAction()
		src.path = null

	src.oldloc = src.loc

/obj/machinery/bot/mining/proc/findTarget()
	digbottargets = list()
	for(var/obj/machinery/bot/mining/bot in machine_registry[MACHINES_BOTS])
		if(bot != src) digbottargets += bot.target
	for (var/turf/simulated/wall/auto/asteroid/D in view(7,src))
		if(!(D in digbottargets) && D != src.oldtarget)
			if (D.hardness <= src.hardthreshold)
				if (!src.digsuspicious && D.event)
					continue
				src.oldtarget = D
				src.target = D
				pointAtTarget()
				break
	return

/obj/machinery/bot/mining/proc/pointAtTarget()
	if (src.target)
		for (var/mob/O in hearers(src, null))
			O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] points and beeps, \"Doomed rock detected!\"")), 2)
		point(target)

/obj/machinery/bot/mining/proc/buildPath()
	if (!isturf(src.loc)) return
	if (!target) return
	src.path = findPath(src.loc, src.target, , 7)
	if (!src.path)
		src.oldtarget = src.target
		src.target = null
		return

/obj/machinery/bot/mining/proc/startToolAction()
	actions.start(new/datum/action/bar/icon/digbotdig(src, target), src)

/obj/machinery/bot/mining/proc/startDiggingEffects()
	src.visible_message(SPAN_ALERT("[src] starts digging!"))
	if (src.diglevel > 2) playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
	else playsound(src.loc, 'sound/impact_sounds/Stone_Cut_1.ogg', 100, 1)
	src.digging = 1
	src.anchored = ANCHORED
	setEffectOverlays()

/obj/machinery/bot/mining/proc/stopDiggingEffects()
	src.digging = 0
	src.anchored = UNANCHORED
	setEffectOverlays()


//////////////////////////////////////
//////Digbot Drill Variant/////////////
//////////////////////////////////////

/obj/machinery/bot/mining/drill
	name = "Digbot Mk2"
	desc = "A little robot with a drill. Looks like he means business!"
	icon_state = "digbot-drill"
	diglevel = 4
	hardthreshold = 4

/obj/machinery/bot/mining/drill/setupOverlayVars()
	..()
	src.display_tool_idle = image('icons/obj/bots/aibots.dmi', "digbot powerdrill")
	src.display_tool_animated = src.display_tool_idle

/obj/machinery/bot/mining/drill/startToolAction()
	//Do not call parent!
	actions.start(new/datum/action/bar/icon/digbotdig/drill(src, target), src)


//////////////////////////////////////
////// Digbot Actionbar /////////////
//////////////////////////////////////

/datum/action/bar/icon/digbotdig
	duration = 3 SECONDS //This varies, see below
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "" //intentionaly blank
	//The pick-variant has a mining animation, but the drill variant does not - and overrides icon_state
	var/obj/machinery/bot/mining/bot
	var/turf/simulated/wall/auto/asteroid/target

	New(var/obj/machinery/bot/mining/bot, var/turf/simulated/wall/auto/asteroid/target)
		..()
		src.bot = bot
		src.target = target
		if(!checkStillValid()) return

		var/minedifference = target.hardness - bot.diglevel
		if (minedifference <= -2)
			duration -= 2 SECONDS
		else if (minedifference == -1)
			duration -= 1 SECOND
		else if (minedifference == 1)
			duration += 1 SECOND

	onStart()
		..()
		if(!checkStillValid()) return
		bot.startDiggingEffects()

	onUpdate()
		..()
		if(!checkStillValid()) return

	onEnd()
		if(checkStillValid())
			target.damage_asteroid(bot.diglevel)
			if(!istype(target, /turf/simulated/wall/auto/asteroid/))
				bot.target = null
		if(bot != null)
			bot.stopDiggingEffects()
		..()

	onDelete()
		..()
		if(bot != null)
			bot.stopDiggingEffects()

	proc/checkStillValid()
		if(bot == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		if(!bot.on || !istype(target, /turf/simulated/wall/auto/asteroid/))
			bot.target = null
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE

/datum/action/bar/icon/digbotdig/drill
	icon_state = "lasdrill-old"


//////////////////////////////////////
//////  Digbot UI  ///////////////////
//////////////////////////////////////

/datum/digbot_ui
	var/obj/machinery/bot/mining/bot = null

/datum/digbot_ui/New(obj/machinery/bot/mining/bot)
	..()
	src.bot = bot

/datum/digbot_ui/proc/validate_user(mob/user as mob)
	return !(user.stat || user.restrained())

/datum/digbot_ui/Topic(href, href_list)
	if(!validate_user(usr))
		return
	if(href_list["ui_target"] == "digbot_ui")
		switch(href_list["ui_action"])
			if("toggle_power")
				bot.togglePowerSwitch()
			if("toggle_suspicious")
				bot.digsuspicious = !bot.digsuspicious
			if("hardness")
				bot.hardthreshold = input(usr, "Maximum hardness level this bot will dig up to?", "Hardness Threshold", "") as num
	show_ui(usr)

/datum/digbot_ui/proc/show_ui(mob/user)
	if (user.client?.tooltipHolder)
		user.client.tooltipHolder.showClickTip(bot, list("title" = "Digbot Controls", "content" = render()))

/datum/digbot_ui/proc/render()
	return {"
<span>[bot.on ? "Active" : "Inactive"] - </span><a href="byond://?src=\ref[src]&ui_target=digbot_ui&ui_action=toggle_power">Toggle Power</a><br />
<span>Settings:<br />
<a href="byond://?src=\ref[src]&ui_target=digbot_ui&ui_action=toggle_suspicious">[bot.digsuspicious ? "Digging" : "Avoiding"] suspicious rocks</a><br />
<a href="byond://?src=\ref[src]&ui_target=digbot_ui&ui_action=hardness">Targeting rock hardness [bot.hardthreshold] and lower</a>
"}


//////////////////////////////////////
//////Digbot Construction/////////////
//////////////////////////////////////

/obj/item/digbotassembly
	name = "hard hat/sensor assembly"
	desc = "You need to add a robot arm next."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "digbot assembly 1"
	w_class = W_CLASS_NORMAL
	var/build_step = 0

	attackby(var/obj/item/T, mob/user as mob)
		if (istype(T, /obj/item/parts/robot_parts/arm/))
			if (src.build_step == 0)
				if (user.r_hand == T) user.u_equip(T)
				else user.u_equip(T)
				qdel(T)
				src.build_step = 1
				src.name = "hard hat/sensor/robot arm assembly"
				src.icon_state = "digbot assembly 2"
				boutput(user, "You add the robot arm to the assembly. Now you need to add a mining tool.")
			else
				boutput(user,  "You already added that part!")
				return
		else if (istype(T, /obj/item/mining_tool/powered/drill))
			if (src.build_step == 1)
				if (user.r_hand == T) user.u_equip(T)
				else user.u_equip(T)
				boutput(user,  "You add [T.name]. Now you have a finished mining bot! Hooray!")
				qdel(T)
				new /obj/machinery/bot/mining/drill(user.loc)
				qdel(src)
			else
				boutput(user,  "It's not ready for that part yet.")
				return
		else if (istype(T, /obj/item/mining_tool/))
			if (src.build_step == 1)
				if (user.r_hand == T) user.u_equip(T)
				else user.u_equip(T)
				boutput(user,  "You add [T.name]. Now you have a finished mining bot! Hooray!")
				qdel(T)
				new /obj/machinery/bot/mining(get_turf(src))
				qdel(src)
			else
				boutput(user,  "It's not ready for that part yet.")
				return
		else
			..()
