#define BORG_REPROGRAM_DURATION 10 SECONDS

TYPEINFO(/obj/item/device/borg_linker)
	mats = list("crystal" = 1,
				"conductive_high" = 1)
/obj/item/device/borg_linker
	name = "cyborg law linker"
	icon_state = "cyborg_linker"
	flags = TABLEPASS | CONDUCT | SUPPRESSATTACK
	c_flags = ONBELT
	force = 5
	w_class = W_CLASS_SMALL
	throwforce = 5
	throw_range = 15
	throw_speed = 3
	desc = "A device for connecting silicon beings to a law rack, setting restrictions on their behaviour."
	m_amt = 50
	g_amt = 20
	var/obj/machinery/lawrack/linked_rack = null

	New()
		..()
		if(ticker.ai_law_rack_manager.default_ai_rack)
			src.linked_rack = ticker.ai_law_rack_manager.default_ai_rack

	get_desc(dist, mob/user)
		if(src.linked_rack)
			var/area/rack_area = get_area(src.linked_rack)
			. += " It is linked to a law rack at [rack_area.name]"

	attack_self(mob/user)
		if(src.linked_rack)
			var/area/A = get_area(src.linked_rack.loc)
			var/raw = tgui_alert(user,"Do you want to clear the linked rack at [A.name]?", "Linker", list("Yes", "No"))
			if (raw == "Yes")
				src.linked_rack = null
		else
			boutput(user, "No law rack connected.")

	afterattack(var/atom/A, mob/user)
		if(!A || !user)
			return
		if(issilicon(A))
			src.reprogram_silicon(A, user)
		else if (istype(A,/obj/machinery/lawrack) && !issilicon(user))
			if(A == src.linked_rack)
				boutput(user, SPAN_ALERT("[src] is already connected to [A]!"))
				return
			src.linked_rack = A
			var/area/location = get_area(A)
			boutput(user, SPAN_NOTICE("You link [src] to the rack at [location.name]"))
			return

	proc/reprogram_silicon(var/mob/living/silicon/sillycon, mob/user)
		if(!istype(sillycon) || !user)
			return
		if(!ishuman(user))
			boutput(user, SPAN_ALERT("You don't know how to use [src]!"))
			return
		if(!src.linked_rack || QDELETED(src.linked_rack) || !(src.linked_rack in ticker.ai_law_rack_manager.registered_racks))
			src.linked_rack = null
			boutput(user, SPAN_ALERT("[src] has no linked rack!"))
			return
		if(sillycon.shell || sillycon.dependent)
			boutput(user, SPAN_ALERT("You need to reprogram the AI's mainframe!"))
			return
		if(sillycon.law_rack_connection == src.linked_rack)
			boutput(user, SPAN_ALERT("[sillycon] is already connected to the linked rack!"))
			return
		if(sillycon.syndicate || sillycon.emagged)
			boutput(user, SPAN_ALERT("The link port sparks violently! It didn't work!"))
			logTheThing(LOG_STATION, sillycon, "[constructName(user)] tried to connect [sillycon] to the rack [constructName(src.linked_rack)] but they are [sillycon.emagged ? "emagged" : "syndicate"], so it failed.")
			elecflash(user,power=2)
			return
		if(istype(sillycon, /mob/living/silicon/robot) || istype(sillycon, /mob/living/silicon/ai))
			var/description = "Target is [sillycon.law_rack_connection ? "connected to rack at [get_area(sillycon.law_rack_connection)]" : "not connected to a rack"]. "
			description += "Reconnect to rack at [get_area(src.linked_rack)]?"
			var/raw = tgui_alert(user, description, "Linker", list("Yes", "No"))
			if (raw == "Yes")
				src.start_linking(sillycon, user)
		else
			boutput(user, SPAN_ALERT("[src] cannot reprogram [sillycon]."))

	proc/start_linking(var/mob/living/silicon/sillycon, mob/user)
		if(!sillycon || !istype(sillycon))
			return
		playsound(src.loc, 'sound/items/ocular_implanter_start.ogg', 50, 1)
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> begins reprogramming [sillycon.name]."))
		var/datum/action/bar/icon/callback/law_linking/try_link = new(user, src, BORG_REPROGRAM_DURATION, PROC_REF(link_to_rack), list(sillycon, user), src.icon, src.icon_state, SPAN_ALERT("<b>[user.name]</b> finishes reprogramming [sillycon.name]."), null)
		actions.start(try_link, user)

	proc/link_to_rack(var/mob/living/silicon/sillycon, mob/user)
		if(!sillycon || !istype(sillycon))
			return
		sillycon.set_law_rack(src.linked_rack, user)

/datum/action/bar/icon/callback/law_linking
	var/mob/living/silicon/sillycon
	var/obj/item/device/borg_linker/linker

	New(owner, target, duration, proc_path, proc_args, icon, icon_state, end_message, interrupt_flags, call_proc_on)
		if (!istype(target, /obj/item/device/borg_linker))
			CRASH("Called action on something that isn't a law linker")
		if (!issilicon(proc_args[1]))
			CRASH("Tried to connect non-silicon to new law rack")
		. = ..()

		src.linker = target
		src.sillycon = proc_args[1]

	canRunCheck(in_start)
		..()
		if (!src.owner || !src.linker || !src.sillycon)
			src.interrupt(INTERRUPT_ALWAYS)
		if (BOUNDS_DIST(src.owner, src.sillycon) > 0)
			src.interrupt(INTERRUPT_ALWAYS)
		if (isdead(src.sillycon))
			src.interrupt(INTERRUPT_ALWAYS)
		if(ismob(owner))
			var/mob/mob_owner = owner
			if(isdead(mob_owner))
				src.interrupt(INTERRUPT_ALWAYS)
		if (src.linker.loc != src.owner)
			src.interrupt(INTERRUPT_ALWAYS)

#undef BORG_REPROGRAM_DURATION
