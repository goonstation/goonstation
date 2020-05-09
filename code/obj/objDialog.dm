
var/global/list/objects_using_dialogs
/obj/var/list/clients_operating

/obj/proc/add_dialog(mob/user)
	if (!user.client) return

	if (!objects_using_dialogs)
		objects_using_dialogs = list(src)
	else
		objects_using_dialogs += src

	if (!clients_operating)
		clients_operating = list(user.client)
	else
		clients_operating += user.client

/obj/proc/remove_dialog(mob/user)
	if (!user.client) return

	if (!objects_using_dialogs)
		objects_using_dialogs = list()
	else
		objects_using_dialogs -= src

	if (!clients_operating)
		clients_operating = list()
	else
		clients_operating -= user.client

/mob/proc/remove_dialogs() //try to avoid using this, it wipes stuff that you might want
	for (var/obj/O in objects_using_dialogs)
		if (src.using_dialog_of(O))
			O.remove_dialog(src)

/mob/proc/using_dialog_of(var/obj/O)
	.= src.client && src.client in O.clients_operating

/mob/proc/using_dialog_of_type(var/type)
	.= 0
	for (var/obj/O in objects_using_dialogs)
		if (src.using_dialog_of(O) && istype(O,type))
			.= O

/obj/proc/updateUsrDialog()
	for(var/client/C in clients_operating)
		if (C.mob)
			if (get_dist(C.mob,src) <= 1)
				src.attack_hand(C.mob)
			else
				if (issilicon(C.mob))
					src.attack_ai(usr)
				else if (isAIeye(C.mob))
					var/mob/dead/aieye/E = C.mob
					src.attack_ai(E)

/obj/proc/updateDialog()
	for(var/client/C in clients_operating)
		if (C.mob && get_dist(C.mob,src) <= 1)
			src.attack_hand(C.mob)
	AutoUpdateAI(src)

/obj/item/proc/updateSelfDialogFromTurf()	//It's weird, yes. only used for spy stickers as of now

	for(var/client/C in clients_operating)
		if (C.mob && get_dist(C.mob,src) <= 1)
			src.attack_self(C.mob)

	for(var/mob/living/silicon/ai/M in AIs)
		var/mob/AI = M
		if (M.deployed_to_eyecam)
			AI = M.eyecam
		if ((AI.client && AI.client in clients_operating))
			src.attack_self(AI)

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M))
		if (isAI(M)) //Eyecam handling
			var/mob/living/silicon/ai/AI = M
			if (AI.deployed_to_eyecam)
				M = AI.eyecam
		if(M.client && M.client in clients_operating)
			src.attack_self(M)


/proc/AutoUpdateAI(obj/subject)
	if (!subject)
		return
	for(var/mob/living/silicon/ai/M in AIs)
		var/mob/AI = M
		if (M.deployed_to_eyecam)
			AI = M.eyecam

		if (AI && AI.using_dialog_of(subject))
			subject.attack_ai(AI)





/obj/machinery/power/apc/updateUsrDialog()
	var/list/nearby = viewers(1, src)
	if (!(status & BROKEN)) // unbroken
		for(var/mob/M in nearby)
			if (usr.using_dialog_of(src))
				src.interacted(M)
	if (issilicon(usr) || isAI(usr))
		if (!(usr in nearby))
			if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				src.interacted(usr)

/obj/machinery/power/apc/updateDialog()
	if(!(status & BROKEN)) // unbroken
		for(var/client/C)
			if (C.mob?.machine == src && get_dist(C.mob,src) <= 1)
				src.interacted(C.mob)
	AutoUpdateAI(src)
