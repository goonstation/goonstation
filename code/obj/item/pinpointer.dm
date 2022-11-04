/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/items/pinpointers.dmi'
	icon_state = "disk_pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/tmp/atom/target = null
	/// target type to search for in world
	var/target_criteria = null
	/// exact target reference
	var/target_ref = null
	var/active = 0
	var/icon_type = "disk"
	mats = 4
	desc = "An extremely advanced scanning device used to locate things. It displays this with an extremely technicalogically advanced arrow."
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	var/image/arrow = null
	var/atom/movable/hudarrow
	var/hudarrow_color = "#67cd22"
	var/max_range = null

	New()
		..()
		START_TRACKING
		arrow = image('icons/obj/items/pinpointers.dmi', icon_state = "")

	disposing()
		STOP_TRACKING
		..()

	attack_self(mob/user)
		if(!active)
			if (!(src.target_criteria || src.target_ref || src.target))
				user.show_text("No target criteria specified, cannot activate \the [src].", "red")
				return
			active = 1
			work()
			boutput(user, "<span class='notice'>You activate \the [src]</span>")
		else
			src.turn_off()
			boutput(user, "<span class='notice'>You deactivate \the [src]</span>")

	pickup(mob/user)
		. = ..()
		if(!hasvar(user, "hud")) // I'm so sorry
			return
		var/datum/hud/hud = user:hud
		if(isnull(hudarrow))
			hudarrow = hud.create_screen("pinpointer", "Pinpointer", 'icons/obj/items/pinpointers.dmi', "hudarrow", "CENTER, CENTER")
			hudarrow.mouse_opacity = 0
			hudarrow.appearance_flags = 0
			hudarrow.alpha = active ? 127 : 0
			hudarrow.color = hudarrow_color
		else
			hud.add_object(hudarrow)

	dropped(mob/user)
		. = ..()
		if(!hasvar(user, "hud") || isnull(hudarrow)) // very sorry once more
			return
		var/datum/hud/hud = user:hud
		hud.remove_object(hudarrow)

	proc/turn_off()
		active = 0
		ClearSpecificOverlays("arrow")
		if(hudarrow)
			animate(hudarrow, alpha=0, time=1 SECOND)

	proc/work_check()
		return // override to interrupt work if conditions are met

	proc/work()
		set waitfor = FALSE
		if(hudarrow)
			animate(hudarrow, alpha=127, time=1 SECOND)
		while(active)
			if(!active)
				break
			if(!target)
				if (target_ref)
					target = locate(target_ref)
				else if (target_criteria)
					target = locate(target_criteria)
				if(!target || target.qdeled)
					src.turn_off()
					return
			work_check()
			var/turf/ST = get_turf(src)
			var/turf/T = get_turf(target)
			if(!ST || !T || ST.z != T.z || !isnull(max_range) && GET_DIST(src,target) > max_range)
				src.turn_off()
				if(ismob(src.loc))
					boutput(src.loc, "<span class='alert'>Pinpointer target out of range.</span>")
				return
			src.set_dir(get_dir(src,target))
			var/dist = GET_DIST(src,target)
			switch(dist)
				if(0)
					arrow.icon_state = "pinondirect"
				if(1 to 8)
					arrow.icon_state = "pinonclose"
				if(9 to 16)
					arrow.icon_state = "pinonmedium"
				if(16 to INFINITY)
					arrow.icon_state = "pinonfar"
			UpdateOverlays(arrow, "arrow")

			if(hudarrow && ismob(src.loc))
				var/ang = get_angle(get_turf(src), get_turf(target))
				var/hudarrow_dist = 16 + 32 / (1 + 3 ** (3 - dist / 10))
				var/matrix/M = matrix()
				var/hudarrow_scale = 0.6 + 0.4 / (1 + 3 ** (3 - dist / 10))
				M = M.Scale(hudarrow_scale, hudarrow_scale)
				M = M.Turn(ang)
				if(dist == 0)
					hudarrow_dist += 9
					M.Turn(180) // point at yourself :)
				M = M.Translate(hudarrow_dist * sin(ang), hudarrow_dist * cos(ang))
				animate(hudarrow, transform=M, time=0.5 SECONDS, flags=ANIMATION_PARALLEL)

			sleep(0.5 SECONDS)

/// tracks something using by_type or by_cat, see types.dm for more info
/obj/item/pinpointer/category
	var/category = null
	var/thing_name = "trackable object"
	var/in_or_on = "in"
	var/z_locked = null // Z-level number if locked to that Z-level
	var/include_area_text = TRUE

	attack_self(mob/user)
		if(!active)
			if(isnull(category))
				user.show_text("No tracking category, cannot activate the pinpointer.", "red")
				return
			var/list/trackable
			if(istext(category))
				trackable = by_cat[category]
			else if(ispath(category))
				trackable = by_type[category]
			var/list/choices = list()
			for(var/atom/A in trackable)
				var/turf/T = get_turf(A)
				if(A.disposed || isnull(T))
					continue
				if(!isnull(z_locked) && z_locked != T.z)
					continue
				var/dist = GET_DIST(A, src)
				if(!isnull(max_range) && dist > max_range)
					continue
				var/in_loc = ""
				if(!isturf(A.loc))
					in_loc = " [in_or_on] [A.loc]"
				var/area_text = include_area_text ? " in [get_area(A)]" : ""
				choices["[A][in_loc][area_text]"] = A
			if(!length(choices))
				user.show_text("No [thing_name]s available, cannot activate the pinpointer.", "red")
				return
			var/choice = tgui_input_list(user, "Pick a [thing_name] to track.", "[src]", choices)
			if(isnull(choice))
				return
			target = choices[choice]
		. = ..()

/obj/item/pinpointer/category/spysticker
	name = "spy sticker pinpointer"
	desc = "Locates spy stickers attached to things."
	category = TR_CAT_SPY_STICKERS_REGULAR
	thing_name = "spy sticker"
	in_or_on = "on"

/obj/item/pinpointer/category/spysticker/det
	category = TR_CAT_SPY_STICKERS_DET

/obj/item/pinpointer/nuke
	name = "pinpointer (nuclear bomb)"
	desc = "Points in the direction of the nuclear bomb."
	icon_state = "nuke_pinoff"
	icon_type = "nuke"
	target_criteria = /obj/machinery/nuclearbomb
	hudarrow_color = "#ad1400"

/obj/item/pinpointer/disk
	name = "pinpointer (authentication disk)"
	desc = "Points in the direction of the authentication disk."
	icon_state = "disk_pinoff"
	icon_type = "disk"
	hudarrow_color = "#14ad00"
	target_criteria = /obj/item/disk/data/floppy/read_only/authentication

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/pinpointer/identificationcomputer
	name = "pinpointer (identification computer)"
	desc = "Points in the direction of the portable identification computer."
	icon_state = "id_pinoff"
	icon_type = "id"
	target_criteria = /obj/machinery/computer/card/portable

/obj/item/pinpointer/teg_semi
	name = "pinpointer (prototype semiconductor)"
	desc = "Points in the direction of the NT Prototype Semiconductor."
	icon_state = "semi_pinoff"
	icon_type = "semi"
	hudarrow_color = "#adad00"
	target_criteria = /obj/item/teg_semiconductor

/obj/item/pinpointer/trench
	name = "pinpointer (sea elevator)"
	desc = "Points in the direction of the sea elevator."
	icon_state = "trench_pinoff"
	icon_type = "trench"
	hudarrow_color = "#3395dd"
	var/target_area = /area/shuttle/sea_elevator/lower

	attack_self(mob/user)
		if (!active)
			var/area/A = locate(target_area)
			var/turf/T = A.find_middle()
			var/turf/ST = get_turf(user)
			if (ST.z != T.z)
				boutput(user, "<span class='notice'>You must be in the trench to use this pinpointer.</span>")
				return
			target_ref = "\ref[A.find_middle()]"
		. = ..()

/obj/item/pinpointer/idtracker
	name = "ID pinpointer"
	icon_state = "id_pinoff"
	var/mob/owner = null
	hudarrow_color = "#ffffff"
	is_syndicate = 1
	desc = "This little bad-boy has been pre-programmed to display the general direction of any assassination target you choose."

	attack_self(mob/user)
		if(!active)
			if (!src.owner || !src.owner.mind)
				boutput(user, "<span class='alert'>\The [src] emits a sorrowful ping!</span>")
				return
			active = 1
			var/list/targets = list()
			for_by_tcl(I, /obj/item/card/id)
				if(!I)
					continue // the ID can get deleted in the lagcheck
				for(var/datum/objective/regular/assassinate/A in src.owner.mind.objectives)
					if(I.registered == null) continue
					if(ckey(I.registered) == ckey(A.targetname))
						targets[I] = I
				LAGCHECK(LAG_LOW)
			target = null
			target = input(user, "Which ID do you wish to track?", "Target Locator", null) in targets
			work()
			if(!target)
				boutput(user, "<span class='notice'>You activate the target locator. No available targets!</span>")
				active = 0
			else
				boutput(user, "<span class='notice'>You activate the target locator. Tracking [target]</span>")
		else
			..()

/obj/item/pinpointer/idtracker/spy
	attack_hand(mob/user)
		..(user)
		if (!user.mind || user.mind.special_role != ROLE_SPY_THIEF)
			boutput(user, "<span class='alert'>The target locator emits a sorrowful ping!</span>")
			src.turn_off()
			target = null

	attack_self(mob/user)
		if(!active)
			if (!src.owner || !src.owner.mind || src.owner.mind.special_role != ROLE_SPY_THIEF)
				boutput(user, "<span class='alert'>The target locator emits a sorrowful ping!</span>")
				return
			active = 1

			var/list/targets = list()
			for_by_tcl(I, /obj/item/card/id)
				if(I.registered == null) continue
				for (var/datum/mind/M in ticker.mode.traitors)
					if (src.owner.mind == M)
						continue
					if (ckey(I.registered) == ckey(M.current.real_name))
						targets[I] = I

			target = null
			target = input(user, "Which ID do you wish to track?", "Target Locator", null) in targets
			work()
			if(!target)
				boutput(user, "<span class='notice'>You activate the target locator. No available targets!</span>")
				active = 0
			else
				boutput(user, "<span class='notice'>You activate the target locator. Tracking [target]</span>")
		else
			..()

/obj/item/pinpointer/bloodtracker
	name = "BloodTrak"
	icon_state = "blood_pinoff"
	desc = "Tracks down people from their blood puddles!"
	hudarrow_color = "#ff0000"
	var/blood_timer = 0

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if(active)
			return
		var/blood_dna = null
		var/timer = TIME + 4 MINUTES
		if(istype(A, /obj/decal/cleanable/blood))
			var/obj/decal/cleanable/blood/B = A
			if(B.dry > 0) //Fresh blood is -1
				boutput(user, "<span class='alert'>Targeted blood is too dry to be useful!</span>")
				return
			if(B.dry == -1)
				timer += 4 MINUTES
			blood_dna = B.blood_DNA
		else if(istype(A, /obj/fluid) || istype(A, /obj/item))
			blood_dna = A.blood_DNA
		if(!blood_dna)
			var/datum/reagents/reagents = A.reagents
			if(istype(A, /obj/fluid))
				var/obj/fluid/fluid = A
				reagents = fluid.group.reagents
			if(!isnull(reagents))
				for(var/reag_id in list("blood", "bloodc"))
					var/datum/reagent/blood/blood = reagents.reagent_list[reag_id]
					var/datum/bioHolder/bioholder = blood?.data
					if(istype(bioholder))
						blood_dna = bioholder.Uid
		if(!blood_dna)
			return
		for(var/mob/living/carbon/human/H in mobs)
			if(blood_dna == H.bioHolder.Uid)
				target = H
				blood_timer = timer
				break
		active = 1
		work()
		user.visible_message("<span class='notice'><b>[user]</b> scans [A] with [src]!</span>",\
			"<span class='notice'>You scan [A] with [src]!</span>")

	work_check()
		if(TIME > blood_timer)
			src.turn_off()
			if(ismob(src.loc))
				boutput(src.loc, "<span class='alert'>[src] shuts down because the blood in it became too dry!</span>")

/obj/item/pinpointer/secweapons
	name = "security weapon pinpointer"
	icon_state = "sec_pinoff"
	icon_type = "sec"
	var/list/itemrefs
	var/list/accepted_types
	hudarrow_color = "#ee4444"
	mats = null
	desc = "An extremely advanced scanning device used to locate lost security tools. It displays this with an extremely technicalogically advanced arrow."

	proc/track(var/list/L)
		itemrefs = list()
		accepted_types = list()
		for(var/atom/A in L)
			itemrefs += ref(A)
			accepted_types += A.type

	attack_self(mob/user)
		if(!active)

			var/list/choices = list()
			for (var/x in itemrefs)
				var/atom/A = locate(x)
				if (A && (A.type in accepted_types) && !A.qdeled && !A.disposed)
					choices[A.name] = A

			if (!length(choices))
				user.show_text("No track targets exist - possibly destroyed. Cannot activate pinpointer", "red")
				return

			target = choices[tgui_input_list(user, "Select a weapon to locate.", "Locate Weapon", choices)]

			if (!target)
				user.show_text("No target specified. Cannot activate pinpointer.", "red")
				return

			active = 1
			work()
			boutput(user, "<span class='notice'>You activate the pinpointer</span>")
		else
			active = 0
			arrow.icon_state = ""
			UpdateOverlays(arrow, "arrow")
			boutput(user, "<span class='notice'>You deactivate the pinpointer</span>")


// gimmick pinpointers because I feel like adding them now that I made the by_cat pinpointer base version

/obj/item/pinpointer/category/pets
	name = "pet pinpointer"
	category = TR_CAT_PETS
	thing_name = "pet"

/obj/item/pinpointer/category/pwpets // pod wars
	name = "pet pinpointer"
	category = TR_CAT_PW_PETS
	thing_name = "pet"

/obj/item/pinpointer/category/critters
	name = "critter pinpointer"
	category = TR_CAT_CRITTERS
	thing_name = "critter"

/obj/item/pinpointer/category/pods
	name = "pod pinpointer"
	category = TR_CAT_PODS_AND_CRUISERS
	thing_name = "pod"

/obj/item/pinpointer/category/teleport_jammers
	name = "teleport jammer pinpointer"
	category = TR_CAT_TELEPORT_JAMMERS
	thing_name = "teleport jammer"

/obj/item/pinpointer/category/radio_jammers
	name = "radio jammer pinpointer"
	category = TR_CAT_RADIO_JAMMERS
	thing_name = "radio jammer"

/obj/item/pinpointer/category/burning_mobs
	name = "burning mob pinpointer"
	category = TR_CAT_BURNING_MOBS
	thing_name = "burning mob"

/obj/item/pinpointer/category/burning_items
	name = "burning item pinpointer"
	category = TR_CAT_BURNING_ITEMS
	thing_name = "burning item"

/obj/item/pinpointer/category/chaplains
	name = "chaplain pinpointer"
	category = TR_CAT_CHAPLAINS
	thing_name = "chaplain"

/obj/item/pinpointer/category/ids
	name = "\improper ID pinpointer"
	category = /obj/item/card/id
	thing_name = "ID"

/obj/item/pinpointer/category/apcs
	name = "\improper APC pinpointer"
	category = /obj/machinery/power/apc
	thing_name = "APC"

/obj/item/pinpointer/category/apcs/station
	name = "\improper APC pinpointer"
	desc = "Locates APC units on the station."
	category = /obj/machinery/power/apc
	thing_name = "APC"
	hudarrow_color = "#aaaa66"
	include_area_text = FALSE
	z_locked = Z_LEVEL_STATION

/obj/item/pinpointer/category/comms_dishes
	name = "comm dish pinpointer"
	category = /obj/machinery/communications_dish
	thing_name = "communications dish"

/obj/item/pinpointer/category/beacons
	name = "tracking beacon pinpointer"
	category = /obj/item/device/radio/beacon
	thing_name = "tracking beacon"

/obj/item/pinpointer/category/mobs
	name = "mob pinpointer"
	category = /mob
	thing_name = "mob"

/obj/item/pinpointer/category/ouija_boards
	name = "ouija board pinpointer"
	category = /obj/item/ghostboard
	thing_name = "ouija board"

/obj/item/pinpointer/category/pod_warp_beacons
	name = "pod warp beacon pinpointer"
	category = /obj/warp_beacon
	thing_name = "pod warp beacon"

/obj/item/pinpointer/category/mopbuckets
	name = "mop bucket pinpointer"
	category = /obj/mopbucket
	thing_name = "mop bucket"

/obj/item/pinpointer/category/mops
	name = "mop pinpointer"
	category = /obj/item/mop
	thing_name = "mop"

/obj/item/pinpointer/category/phones
	name = "phone pinpointer"
	category = /obj/machinery/phone
	thing_name = "phone"

/obj/item/pinpointer/category/living_mobs
	name = "living mob pinpointer"
	category = /mob/living
	thing_name = "living mob"

/obj/item/pinpointer/category/humans
	name = "human pinpointer"
	category = /mob/living/carbon/human
	thing_name = "human"

/obj/item/pinpointer/category/fabricators
	name = "fabricator pinpointer"
	category = /obj/machinery/manufacturer
	thing_name = "fabricator"

/obj/item/pinpointer/category/station_vehicles
	name = "station vehicle pinpointer"
	category = /obj/vehicle
	thing_name = "station vehicle"

/obj/item/pinpointer/category/bibles
	name = "bible pinpointer"
	category = /obj/item/storage/bible
	thing_name = "bible"

/obj/item/pinpointer/category/gps
	name = "\improper GPS unit pinpointer"
	category = /obj/item/device/gps
	thing_name = "GPS unit"

/obj/item/pinpointer/category/toilets
	name = "toilet pinpointer"
	category = /obj/item/storage/toilet
	thing_name = "toilet"

/obj/item/pinpointer/category/turrets
	name = "turret pinpointer"
	category = /obj/machinery/turret
	thing_name = "turret"

/obj/item/pinpointer/category/cryotrons
	name = "cryo storage pinpointer"
	category = /obj/cryotron
	thing_name = "cryo storage"

/obj/item/pinpointer/category/securitrons
	name = "securitron pinpointer"
	category = /obj/machinery/bot/secbot
	thing_name = "securitron"

/obj/item/pinpointer/category/gnomes
	name = "gnome pinpointer"
	category = /obj/item/gnomechompski
	thing_name = "gnome"

/obj/item/pinpointer/category/tracking_implants
	name = "tracking implant pinpointer"
	category = /obj/item/implant/tracking
	thing_name = "tracking implant"

/obj/item/pinpointer/category/monkeys
	name = "monkey pinpointer"
	category = /mob/living/carbon/human/npc/monkey
	thing_name = "monkey"

/obj/item/pinpointer/category/pinpointer // lmao
	name = "pinpointer pinpointer"
	category = /obj/item/pinpointer
	thing_name = "pinpointer"

/obj/item/pinpointer/category/artifacts
	name = "artifact pinpointer"
	category = TR_CAT_ARTIFACTS
	thing_name = "artifact"

/obj/item/pinpointer/category/artifacts/safe
	name = "artifact pinpointer"
	desc = "Locates nearby artifacts in range of 20 meters."
	category = TR_CAT_ARTIFACTS
	thing_name = "artifact"
	hudarrow_color = "#7755ff"
	max_range = 20
