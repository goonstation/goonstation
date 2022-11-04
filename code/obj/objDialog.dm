//hey, so later on you can convert most of the procs within this file to be #defines (or wait until lummox adds proc inlining)
//keeping them procs for now so we can profile etc


var/global/list/objects_using_dialogs
/obj/var/list/clients_operating

/obj/proc/add_dialog(mob/user)
	if (!user.client) return

	if (!objects_using_dialogs)
		objects_using_dialogs = list(src)
	else
		if (!clients_operating || clients_operating.len <= 0)
			objects_using_dialogs += src

	if (!clients_operating)
		clients_operating = list(user.client)
	else
		if (!(user.client in clients_operating))
			clients_operating += user.client

/obj/proc/remove_dialog(mob/user)
	if (!user.client) return

	if (!clients_operating)
		clients_operating = list()
	else
		clients_operating -= user.client

	if (!objects_using_dialogs)
		objects_using_dialogs = list()
	else
		if (clients_operating.len <= 0)
			objects_using_dialogs -= src

/obj/proc/remove_dialogs()
	clients_operating = null
	if (objects_using_dialogs)
		objects_using_dialogs -= src

/mob/proc/remove_dialogs() //try to avoid using this, it wipes stuff that you might want
	for (var/obj/O in objects_using_dialogs)
		if (src.using_dialog_of(O))
			O.remove_dialog(src)

/mob/proc/using_dialog_of(var/obj/O)
	.= (src.client && (src.client in O.clients_operating))

/mob/proc/using_dialog_of_type(var/type)
	.= 0
	for (var/obj/O in objects_using_dialogs)
		if (src.using_dialog_of(O) && istype(O,type))
			.= O

/obj/proc/updateUsrDialog()
	if (length(clients_operating))
		var/client/C = null
		for(var/x in clients_operating)
			C = x
			if (C?.mob)
				if (BOUNDS_DIST(C.mob, src) == 0)
					src.Attackhand(C.mob)
				else
					if (C.mob.mob_flags & USR_DIALOG_UPDATES_RANGE)
						src.attack_ai(C.mob)
					else
						src.remove_dialog(C.mob)

/obj/proc/updateDialog()
	if (length(clients_operating))
		var/client/C = null
		for(var/x in clients_operating)
			C = x
			if (C?.mob)
				if (BOUNDS_DIST(C.mob, src) == 0)
					src.Attackhand(C.mob)
				else
					src.remove_dialog(C.mob)

		AutoUpdateAI(src)

/obj/item/proc/updateSelfDialogFromTurf()	//It's weird, yes. only used for spy stickers as of now
	if (length(clients_operating))
		for(var/client/C in clients_operating)
			if (C.mob && BOUNDS_DIST(C.mob, src) == 0)
				src.attack_self(C.mob)

		for_by_tcl(M, /mob/living/silicon/ai)
			var/mob/AI = M
			if (M.deployed_to_eyecam)
				AI = M.eyecam
			if (AI.client && (AI.client in clients_operating))
				src.attack_self(AI)

/obj/item/proc/updateSelfDialog()
	if (length(clients_operating))
		var/mob/M = src.loc
		if(istype(M))
			if (isAI(M)) //Eyecam handling
				var/mob/living/silicon/ai/AI = M
				if (AI.deployed_to_eyecam)
					M = AI.eyecam
			if(M.client && (M.client in clients_operating))
				src.attack_self(M)


/proc/AutoUpdateAI(obj/subject)
	if (!subject)
		return
	for_by_tcl(M, /mob/living/silicon/ai)
		var/mob/AI = M
		if (M.deployed_to_eyecam)
			AI = M.eyecam

		if (AI?.using_dialog_of(subject))
			subject.attack_ai(AI)


//mob dialog stuff (show inventory)

/mob/proc/add_dialog(mob/user)

/mob/proc/remove_dialog(mob/user)

//object stuyffs




/obj/machinery/power/apc/updateUsrDialog()
	if (length(clients_operating))
		for(var/client/C in clients_operating)
			if (C.mob)
				if (BOUNDS_DIST(C.mob, src) == 0)
					src.interacted(C.mob)
				else if (issilicon(C.mob) || isAI(C.mob))
					src.interacted(C.mob)
				else
					src.remove_dialog(C.mob)

/obj/machinery/power/apc/updateDialog()
	if (length(clients_operating))
		for(var/client/C in clients_operating)
			if (C.mob)
				if (BOUNDS_DIST(C.mob, src) == 0)
					src.interacted(C.mob)
				else
					src.remove_dialog(C.mob)
		AutoUpdateAI(src)



/obj/npc/trader/updateUsrDialog()
	if (length(clients_operating))
		for(var/client/C in clients_operating)
			if (C.mob)
				if (BOUNDS_DIST(C.mob, src) == 0)
					src.openTrade(C.mob)
				else if (issilicon(C.mob) || isAI(C.mob))
					src.openTrade(C.mob)
				else
					src.remove_dialog(C.mob)
