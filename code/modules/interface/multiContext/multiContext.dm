
/mob/var/list/contextButtons = list()
/mob/contextLayout = new/datum/contextLayout/flexdefault()

/mob/proc/checkContextActions(atom/target)
	. = list()
	if(length(target?.contextActions))
		for(var/datum/contextAction/C as anything in target.contextActions)
			var/action = C.checkRequirements(target, src)
			if(action)
				. += C

	var/obj/item/W = src.equipped()
	if(W && W != target && length(W.contextActions))
		for(var/datum/contextAction/C as anything in W.contextActions)
			var/action = C.checkRequirements(target, src)
			if(action)
				. += C

	if(src != target && length(src.contextActions))
		for(var/datum/contextAction/C as anything in src.contextActions)
			var/action = C.checkRequirements(target, src)
			if(action)
				. += C

/mob/proc/showContextActions(list/datum/contextAction/applicable, atom/target, datum/contextLayout/customContextLayout)
	if(length(contextButtons))
		closeContextActions()

	var/list/buttons = list()
	for(var/datum/contextAction/C as anything in applicable)
		var/atom/movable/screen/contextButton/B = unpool(/atom/movable/screen/contextButton)
		B.setup(C, src, target)
		B.alpha = 0
		buttons.Add(B)

	if (customContextLayout)
		customContextLayout.showButtons(buttons,target)
	else if(target.contextLayout)
		target.contextLayout.showButtons(buttons,target)
	else
		contextLayout.showButtons(buttons,target)

	contextButtons = buttons

/mob/proc/closeContextActions()
	for(var/atom/movable/screen/contextButton/C as anything in contextButtons) //todo: stop typechecking our mob every iter
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			H.hud.remove_screen(C)

		else if(ismobcritter(src))
			var/mob/living/critter/R = src
			R.hud.remove_screen(C)

		else if(iswraith(src))
			var/mob/wraith/W = src
			W.hud.remove_screen(C)

		else if(istype(src, /mob/dead/observer))
			var/mob/dead/observer/GO = usr
			GO.hud.remove_screen(C)

		else if (isrobot(src))
			var/mob/living/silicon/robot/robot = src
			robot.hud.remove_screen(C)

		else if (isghostdrone(src))
			var/mob/living/silicon/ghostdrone/drone = src
			drone.hud.remove_screen(C)

		else if (isAI(src))
			var/mob/living/silicon/ai/A = src
			if (isAIeye(src))
				var/mob/dead/aieye/AE = src
				A = AE.mainframe
			A.hud.remove_screen(C)

		else if (ishivebot(src))
			var/mob/living/silicon/hivebot/hivebot = src
			hivebot.hud.remove_screen(C)

		contextButtons.Remove(C)
		if(C.overlays)
			C.overlays = list()
		pool(C)

/atom/New()
	if(contextActions != null)
		if(isnull(globalContextActions))
			buildContextActions()

		var/list/newList = list()
		for(var/A in contextActions) //List of typepaths gets turned into references to instance at runtime.
			if(ispath(A))
				if(globalContextActions && globalContextActions[A])
					if(!(globalContextActions[A] in newList))
						newList.Add(globalContextActions[A])
		contextActions = newList
	..()

/atom/proc/addContextAction(var/contextType)
	if(!ispath(contextType)) return
	if(globalContextActions && globalContextActions[contextType])
		if(!(globalContextActions[contextType] in contextActions))
			contextActions.Add(globalContextActions[contextType])

/atom/proc/removeContextAction(var/contextType)
	if(!ispath(contextType)) return
	for(var/datum/contextAction/C as anything in contextActions)
		if(C.type == contextType)
			contextActions.Remove(C)

/proc/buildContextActions()
	globalContextActions = list()
	for(var/datum/contextAction/A as anything in childrentypesof(/datum/contextAction))
		globalContextActions[A] = new A()

/atom/movable/screen/contextButton
	name = ""
	icon = 'icons/ui/context16x16.dmi'
	icon_state = ""
	var/datum/contextAction/action = null
	var/image/background = null
	var/mob/user = null
	var/atom/target = null

	proc/setup(datum/contextAction/A, mob/U, atom/T)
		if(!A || !U || !T)
			CRASH("Context Button setup called without valid instances [A],[U],[T]")
		action = A
		user = U
		target = T
		icon = action.getIcon(target,user)
		icon_state = action.getIconState(target, user)
		name = action.getName(target, user)

		var/matrix/trans = unpool(/matrix)
		trans = trans.Reset()
		trans.Translate(8, 16)
		transform = trans

		background = null
		src.underlays.Cut()

		var/possible_bg = action.buildBackgroundIcon(target,user)
		if (possible_bg)
			background = possible_bg
			src.underlays += background

		if(background == null)
			background = image('icons/ui/context16x16.dmi', src, "[action.getBackground(target, user)]0")
			background.appearance_flags = RESET_COLOR
			src.underlays += background

	MouseEntered(location,control,params)
		if (usr != user)
			return
		src.underlays.Cut()
		background.icon_state = "[action.getBackground(target, user)]1"
		src.underlays += background
		if (usr.client.tooltipHolder && (action != null) && action.use_tooltip)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = action.getName(target, user),
				"content" = action.getDesc(target, user),
				"theme" = "stamina",
				"flags" = action.getTooltipFlags()
			))

	MouseExited(location,control,params)
		if (usr != user)
			return
		src.underlays.Cut()
		background.icon_state = "[action.getBackground(target, user)]0"
		src.underlays += background
		if (usr.client.tooltipHolder && action.use_tooltip)
			usr.client.tooltipHolder.hideHover()

	clicked(list/params)
		if(action.checkRequirements(target, user)) // Let's just check again, just in case.
			SPAWN_DBG(0)
				action.execute(target, user)
			if (action.flick_on_click)
				flick(action.flick_on_click, src)
			if (action.close_clicked)
				user.closeContextActions()

	disposing()
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.remove_screen(src)

		else if(ismobcritter(user))
			var/mob/living/critter/mcrit = user
			mcrit.hud.remove_screen(src)

		else if(iswraith(user))
			var/mob/wraith/wraith = user
			wraith.hud.remove_screen(src)

		else if (isrobot(user))
			var/mob/living/silicon/robot/robot = user
			robot.hud.remove_screen(src)

		else if (isghostdrone(user))
			var/mob/living/silicon/ghostdrone/drone = user
			drone.hud.remove_screen(src)

		else if (ishivebot(user))
			var/mob/living/silicon/hivebot/hivebot = user
			hivebot.hud.remove_screen(src)

		..()
