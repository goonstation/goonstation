/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "disk_pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/atom/target = null
	var/target_criteria = null
	var/active = 0
	var/icon_type = "disk"
	mats = 4
	desc = "An extremely advanced scanning device used to locate things. It displays this with an extremely technicalogically advanced arrow."
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1

	attack_self()
		if(!active)
			if (!src.target_criteria)
				usr.show_text("No target criteria specified, cannot activate the pinpointer.", "red")
				return
			active = 1
			work()
			boutput(usr, "<span class='notice'>You activate the pinpointer</span>")
		else
			active = 0
			icon_state = "[src.icon_type]_pinoff"
			boutput(usr, "<span class='notice'>You deactivate the pinpointer</span>")

	proc/work()
		if(!active) return
		if(!target)
			if (target_criteria)
				target = locate(target_criteria)
			if(!target || target.qdeled)
				active = 0
				icon_state = "[src.icon_type]_pinonnull"
				return
		src.set_dir(get_dir(src,target))
		switch(get_dist(src,target))
			if(0)
				icon_state = "[src.icon_type]_pinondirect"
			if(1 to 8)
				icon_state = "[src.icon_type]_pinonclose"
			if(9 to 16)
				icon_state = "[src.icon_type]_pinonmedium"
			if(16 to INFINITY)
				icon_state = "[src.icon_type]_pinonfar"
		SPAWN_DBG(0.5 SECONDS) .()

/obj/item/pinpointer/nuke
	name = "pinpointer (nuclear bomb)"
	desc = "Points in the direction of the nuclear bomb."
	icon_state = "nuke_pinoff"
	icon_type = "nuke"
	target_criteria = /obj/machinery/nuclearbomb

/obj/item/pinpointer/disk
	name = "pinpointer (authentication disk)"
	desc = "Points in the direction of the authentication disk."
	icon_state = "disk_pinoff"
	icon_type = "disk"
	target_criteria = /obj/item/disk/data/floppy/read_only/authentication

/obj/item/idtracker
	name = "ID tracker"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "id_pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/active = 0
	var/mob/owner = null
	var/list/targets = list()
	var/target = null
	is_syndicate = 1
	mats = 4
	desc = "This little bad-boy has been pre-programmed to display the general direction of any assassination target you choose."
	contraband = 3

	attack_self()
		if(!active)
			if (!src.owner || !src.owner.mind)
				boutput(usr, "<span class='alert'>The target locator emits a sorrowful ping!</span>")
				return
			active = 1
			for_by_tcl(I, /obj/item/card/id)
				if(!I)
					continue // the ID can get deleted in the lagcheck
				for(var/datum/objective/regular/assassinate/A in src.owner.mind.objectives)
					if(I.registered == null) continue
					if(ckey(I.registered) == ckey(A.targetname))
						targets[I] = I
				LAGCHECK(LAG_LOW)
			target = null
			target = input(usr, "Which ID do you wish to track?", "Target Locator", null) in targets
			work()
			if(!target)
				boutput(usr, "<span class='notice'>You activate the target locator. No available targets!</span>")
				active = 0
			else
				boutput(usr, "<span class='notice'>You activate the target locator. Tracking [target]</span>")
		else
			active = 0
			icon_state = "id_pinoff"
			boutput(usr, "<span class='notice'>You deactivate the target locator</span>")
			target = null

	proc/work()
		if(!active) return
		if(!target)
			icon_state = "id_pinonnull"
			return
		src.set_dir(get_dir(src,target))
		switch(get_dist(src,target))
			if(0)
				icon_state = "id_pinondirect"
			if(1 to 8)
				icon_state = "id_pinonclose"
			if(9 to 16)
				icon_state = "id_pinonmedium"
			if(16 to INFINITY)
				icon_state = "id_pinonfar"
		SPAWN_DBG(0.5 SECONDS) .()

/obj/item/idtracker/spy
	attack_hand(mob/user as mob)
		..(user)
		if (!user.mind || user.mind.special_role != "spy_thief")
			boutput(usr, "<span class='alert'>The target locator emits a sorrowful ping!</span>")

			//B LARGHHHHJHH
			active = 0
			icon_state = "id_pinoff"
			target = null
			return

	attack_self()
		if(!active)
			if (!src.owner || !src.owner.mind || src.owner.mind.special_role != "spy_thief")
				boutput(usr, "<span class='alert'>The target locator emits a sorrowful ping!</span>")
				return
			active = 1

			for_by_tcl(I, /obj/item/card/id)
				if(I.registered == null) continue
				for (var/datum/mind/M in ticker.mode.traitors)
					if (src.owner.mind == M)
						continue
					if (ckey(I.registered) == ckey(M.current.real_name))
						targets[I] = I

			target = null
			target = input(usr, "Which ID do you wish to track?", "Target Locator", null) in targets
			work()
			if(!target)
				boutput(usr, "<span class='notice'>You activate the target locator. No available targets!</span>")
				active = 0
			else
				boutput(usr, "<span class='notice'>You activate the target locator. Tracking [target]</span>")
		else
			active = 0
			icon_state = "id_pinoff"
			boutput(usr, "<span class='notice'>You deactivate the target locator</span>")
			target = null

/obj/item/bloodtracker
	name = "BloodTrak"
	icon = 'icons/obj/items/bloodtrak.dmi'
	icon_state = "blood_pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/active = 0
	var/target = null
	mats = 4
	desc = "Tracks down people from their blood puddles!"
	var/blood_timer = 0

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if(!active && istype(A, /obj/decal/cleanable/blood))
			var/obj/decal/cleanable/blood/B = A
			if(B.dry > 0) //Fresh blood is -1
				boutput(usr, "<span class='alert'>Targeted blood is too dry to be useful!</span>")
				return
			for(var/mob/living/carbon/human/H in mobs)
				if(B.blood_DNA == H.bioHolder.Uid)
					target = H
					blood_timer = TIME + (B.dry==-1?8 MINUTES:4 MINUTES)
					break
			active = 1
			work()
			user.visible_message("<span class='notice'><b>[user]</b> scans [A] with [src]!</span>",\
			"<span class='notice'>You scan [A] with [src]!</span>")

	proc/work(var/turf/T)
		if(!active) return
		if(!T)
			T = get_turf(src)
		if(TIME > blood_timer)
			icon_state = "blood_pinoff"
			active = 0
			boutput(usr, "<span class='alert'>[src] shuts down because the blood in it became too dry!</span>")
			return
		if(!target)
			icon_state = "blood_pinonnull"
			active = 0
			boutput(usr, "<span class='alert'>No target found!</span>")
			return
		src.set_dir(get_dir(src,target))
		switch(get_dist(src,target))
			if(0)
				icon_state = "blood_pinondirect"
			if(1 to 8)
				icon_state = "blood_pinonclose"
			if(9 to 16)
				icon_state = "blood_pinonmedium"
			if(16 to INFINITY)
				icon_state = "blood_pinonfar"
		SPAWN_DBG(0.5 SECONDS)
			.(T)



/obj/item/pinpointer/secweapons
	name = "security weapon pinpointer"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "sec_pinoff"
	icon_type = "sec"
	var/list/itemrefs
	var/list/accepted_types
	mats = null
	desc = "An extremely advanced scanning device used to locate lost security tools. It displays this with an extremely technicalogically advanced arrow."

	proc/track(var/list/L)
		itemrefs = list()
		accepted_types = list()
		for(var/atom/A in L)
			itemrefs += ref(A)
			accepted_types += A.type

	attack_self()
		if(!active)

			var/list/choices = list()
			for (var/x in itemrefs)
				var/atom/A = locate(x)
				if (A && (A.type in accepted_types) && !A.qdeled && !A.pooled)
					choices += A

			if (!length(choices))
				usr.show_text("No track targets exist - possibly destroyed. Cannot activate pinpointer", "red")
				return

			target = input("Select a card to deal.", "Choose Card") as null|anything in choices

			if (!target)
				usr.show_text("No target specified. Cannot activate pinpointer.", "red")
				return

			active = 1
			work()
			boutput(usr, "<span class='notice'>You activate the pinpointer</span>")
		else
			active = 0
			icon_state = "[src.icon_type]_pinoff"
			boutput(usr, "<span class='notice'>You deactivate the pinpointer</span>")
