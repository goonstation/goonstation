// ARMOR

/obj/item/clothing/suit/armor
	name = "armor"
	desc = "A suit worn primarily for protection against injury."
	icon = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
	icon_state = "armor"
	item_state = "armor"
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES
	obstructs = C_UNIFORM|C_GLOVES|C_SHOES

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)

	onMaterialChanged()
		return

/obj/item/clothing/suit/armor/vest
	name = "armor vest"
	desc = "An armored vest that protects against some damage. Contains carbon fibres."
	icon_state = "armorvest"
	uses_multiple_icon_states = 1
	item_state = "armorvest"
	body_parts_covered = TORSO
	bloodoverlayimage = SUITBLOOD_ARMOR
	hides_from_examine = 0
	obstructs = C_UNIFORM

	New()
		..()
		src.setMaterial(getMaterial("carbonfibre"), appearance = FALSE, setname = FALSE)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/assembly/anal_ignite))
			var/obj/item/assembly/anal_ignite/AI = W
			if (!AI.status)
				user.show_text("Secure the assembly first.", "red")
				return

			var/obj/item/clothing/suit/armor/suicide_bomb/R = new /obj/item/clothing/suit/armor/suicide_bomb(get_turf(user))
			user.u_equip(src)
			src.set_loc(R)
			R.part_vest = src

			user.u_equip(AI)
			AI.set_loc(R)
			R.part_igniter = AI
			AI.master = R

			src.add_fingerprint(user)
			AI.add_fingerprint(user)
			R.add_fingerprint(user)
			user.put_in_hand_or_drop(R)
		else
			return ..()

	attack_self(mob/user)
		user.show_text("You change the armor vest's style.")
		if (src.icon_state == "armorvest")
			src.icon_state = "armorvest-old"
		else if (src.icon_state == "armorvest-old")
			src.icon_state = "armorvest-light"
		else
			src.icon_state = "armorvest"

/obj/item/clothing/suit/armor/vest/light
	name = "light armor vest"
	desc = "A cheap armored vest that gives a little bit of protection."
	icon_state = "armorvest-old"
	uses_multiple_icon_states = 0
	item_state = "armorvest-old"

	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

	attackby(obj/item/W, mob/user)
		return

	attack_self(mob/user)
		return

// Added support for old-style grenades and pipe bombs. Also a bit of code streamlining (Convair880).
/obj/item/clothing/suit/armor/suicide_bomb
	name = "suicide bomb vest"
	desc = "A makeshift mechanical vest set to trigger a payload when the user dies."
	icon_state = "bombvest0"
	uses_multiple_icon_states = 1
	item_state = "armorvest"
	flags = FPRINT | TABLEPASS | CONDUCT | NOSPLASH
	body_parts_covered = TORSO
	bloodoverlayimage = SUITBLOOD_ARMOR
	hides_from_examine = 0
	obstructs = C_UNIFORM

	var/obj/item/clothing/suit/armor/vest/part_vest = null
	var/obj/item/assembly/anal_ignite/part_igniter = null // Just for show. Doesn't do anything here or in the igniter code.

	var/obj/item/chem_grenade/grenade = null
	var/obj/item/old_grenade/grenade_old = null
	var/obj/item/pipebomb/bomb/pipebomb = null
	var/obj/item/reagent_containers/glass/beaker/beaker = null
	var/payload = ""

	New()
		..()
		if (!src.part_vest)
			src.part_vest = new /obj/item/clothing/suit/armor/vest(src)
		if (!src.part_igniter)
			src.part_igniter = new /obj/item/assembly/anal_ignite(src)

	examine()
		. = ..()
		if (src.payload)
			. += "<span class='alert'>Looks like the payload is a [src.payload].</span>"
		else
			. += "<span class='alert'>There doesn't appear to be a payload attached.</span>"

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)

		if (istype(W, /obj/item/chem_grenade/))
			if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.beaker)
				var/obj/item/chem_grenade/CG = W
				if (CG.stage == 2 && !CG.state)
					user.u_equip(CG)
					CG.set_loc(src)
					src.grenade = CG
					src.payload = CG.name
					src.icon_state = "bombvest1"
					user.show_text("You attach [CG.name]'s detonator to [src].", "blue")
			else
				user.show_text("There's already a payload attached.", "red")
				return

		else if (istype(W, /obj/item/old_grenade/))
			if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.beaker)
				var/obj/item/old_grenade/OG = W
				if (OG.not_in_mousetraps == 0 && !OG.state) // Same principle, okay.
					user.u_equip(OG)
					OG.set_loc(src)
					src.grenade_old = OG
					src.payload = OG.name
					src.icon_state = "bombvest1"
					user.show_text("You attach [OG.name]'s detonator to [src].", "blue")
			else
				user.show_text("There's already a payload attached.", "red")
				return

		else if (istype(W, /obj/item/pipebomb/bomb/))
			if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.beaker)
				var/obj/item/pipebomb/bomb/PB = W
				if (!PB.armed)
					user.u_equip(PB)
					PB.set_loc(src)
					src.pipebomb = PB
					src.payload = PB.name
					src.icon_state = "bombvest1"
					user.show_text("You attach [PB.name]'s detonator to [src].", "blue")
			else
				user.show_text("There's already a payload attached.", "red")
				return

		else if (istype(W, /obj/item/reagent_containers/glass/beaker/))
			if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.beaker)
				if (!W.reagents.total_volume)
					user.show_text("[W] is empty.", "red")
					return
				user.u_equip(W)
				W.set_loc(src)
				src.beaker = W
				src.payload = "beaker" // Keep this "beaker" so the log_reagents() call can fire correctly.
				src.icon_state = "bombvest1"
				user.show_text("You attach [W.name] to [src]'s igniter assembly.", "blue")
			else
				user.show_text("There's already a payload attached.", "red")
				return

		else if (iswrenchingtool(W))
			if (src.grenade)
				user.show_text("You detach [src.grenade].", "blue")
				src.grenade.set_loc(get_turf(src))
				src.grenade = null
				src.payload = ""
				src.icon_state = "bombvest0"

			else if (src.grenade_old)
				user.show_text("You detach [src.grenade_old].", "blue")
				src.grenade_old.set_loc(get_turf(src))
				src.grenade_old = null
				src.payload = ""
				src.icon_state = "bombvest0"

			else if (src.pipebomb)
				user.show_text("You detach [src.pipebomb].", "blue")
				src.pipebomb.set_loc(get_turf(src))
				src.pipebomb = null
				src.payload = ""
				src.icon_state = "bombvest0"

			else if (src.beaker)
				user.show_text("You detach [src.beaker].", "blue")
				src.beaker.set_loc(get_turf(src))
				src.beaker = null
				src.payload = ""
				src.icon_state = "bombvest0"

			else if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.beaker)
				var/turf/T = get_turf(user)
				if (src.part_vest && T)
					src.part_vest.set_loc(T)
					src.part_vest = null
				if (src.part_igniter && T)
					src.part_igniter.set_loc(T)
					src.part_igniter = null

				src.payload = ""
				user.show_text("You disassemble [src].", "blue")
				if (src.loc == user)
					user.u_equip(src)
				qdel(src)

		else
			..()
		return

	proc/trigger(var/mob/wearer)
		if (!src || !wearer || !ismob(wearer) || src.loc != wearer)
			return
		if (!src.grenade && !src.grenade_old && !src.pipebomb && !src.beaker)
			return
		if (!isdead(wearer) || (wearer.suiciding && prob(60))) // Don't abuse suiciding.
			wearer.visible_message("<span class='alert'><b>[wearer]'s suicide bomb vest clicks softly, but nothing happens.</b></span>")
			return

		if (!src.payload)
			src.payload = "*unknown or null*"

		wearer.visible_message("<span class='alert'><b>[wearer]'s suicide bomb vest clicks loudly!</b></span>")
		message_admins("[key_name(wearer)]'s suicide bomb vest triggers (Payload: [src.payload]) at [log_loc(wearer)].")
		logTheThing(LOG_BOMBING, wearer, "'s suicide bomb vest triggers (<b>Payload:</b> [src.payload])[src.payload == "beaker" ? " [log_reagents(src.beaker)]" : ""] at [log_loc(wearer)].")

		if (src.grenade)
			src.grenade.explode()
			src.grenade = null
			src.payload = ""
			src.icon_state = "bombvest0"

		else if (src.grenade_old)
			src.grenade_old.prime()
			src.grenade_old = null
			src.payload = ""
			src.icon_state = "bombvest0"

		else if (src.pipebomb)
			src.pipebomb.do_explode()
			src.pipebomb = null
			src.payload = ""
			src.icon_state = "bombvest0"

		else if (src.beaker)
			var/turf/T = get_turf(wearer)
			if (T)
				T.hotspot_expose(1000,1000)
			src.beaker.reagents.temperature_reagents(4000, 400) // Translates to 15 K each, same as other igniter assemblies.
			src.beaker.reagents.temperature_reagents(4000, 400)
			// Icon_state and payload don't change because the beaker isn't used up.

/obj/item/clothing/suit/armor/makeshift
	name = "makeshift armor"
	desc = "A standard cyborg chest modified to function as uncomfortable, somewhat flimsy improvised armor."
	icon_state = "makeshift"
	item_state = "makeshift"
	body_parts_covered = TORSO
	hides_from_examine = 0
	obstructs = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.8)
		setProperty("movespeed", 0.5)
		setProperty("disorient_resist", 20)

/obj/item/clothing/suit/armor/captain
	name = "captain's armor"
	desc = "A suit of protective formal armor made for the station's captain."
	icon_state = "caparmor"
	item_state = "caparmor"

	setupProperties()
		..()
		setProperty("meleeprot", 7)
		setProperty("rangedprot", 1.5)

/obj/item/clothing/suit/armor/capcoat //old alt armour for the captain
	name = "captain's coat"
	desc = "A luxorious formal coat made for the station's captain. It seems to be made out of some thermally resistant material."
	icon_state = "capcoat"
	item_state = "capcoat"
	hides_from_examine = 0
	obstructs = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("heatprot", 35)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.9)

/obj/item/clothing/suit/armor/hopcoat
	name = "Head of Personnel's naval coat"
	desc = "A rather well armored coat tailored in a traditional naval fashion."
	icon_state = "hopcoat"
	item_state = "hopcoat"
	hides_from_examine = 0
	obstructs = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.5)

/obj/item/clothing/suit/armor/centcomm
	name = "administrator's armor"
	desc = "A suit of protective formal armor. It is made specifically for NanoTrasen commanders."
	icon_state = "centcom"
	item_state = "centcom"
	setupProperties()
		..()
		setProperty("meleeprot", 7)
		setProperty("rangedprot", 1.5)

	red
		icon_state = "centcom-red"
		item_state = "centcom-red"

/obj/item/clothing/suit/armor/centcommcoat //coat version of the centcom armour
	name = "administator's coat"
	desc = "A luxorious formal coat. It is specifically made for Nanotrasen commanders. It seems to be made out of some thermally resistant material."
	icon_state = "centcoat"
	item_state = "centcoat"
	hides_from_examine = 0
	obstructs = C_UNIFORM
	setupProperties()
		..()
		setProperty("coldprot", 35)
		setProperty("heatprot", 35)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.9)

	red //for the red reward
		icon_state = "centcoat-red"
		item_state = "centcoat-red"

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "heavy"
	hides_from_examine = C_UNIFORM
	obstructs = C_UNIFORM
	setupProperties()
		..()
		setProperty("meleeprot", 12)
		setProperty("rangedprot", 3)
		setProperty("pierceprot",25)
		setProperty("disorient_resist", 45)
		setProperty("movespeed", 1.5)

/obj/item/clothing/suit/armor/death_commando
	name = "death commando armor"
	desc = "Armor used by NanoTrasen's top secret purge unit. You're not sure how you know this."
	icon_state = "death"
	item_state = "death"
	c_flags = SPACEWEAR

/obj/item/clothing/suit/armor/tdome
	name = "thunderdome raiment"
	desc = "A set of official Thunderdome armor. It bears no team insignia or colors."
	icon_state = "td"
	item_state = "td"
	body_parts_covered = TORSO|LEGS

/obj/item/clothing/suit/armor/tdome/red
	name = "red skulls raiment"
	desc = "Official Thunderdome armor of the Red Skulls team."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "green stars raiment"
	desc = "Official Thunderdome armor of the Green Stars team."
	icon_state = "tdgreen"
	item_state = "tdgreen"

/obj/item/clothing/suit/armor/tdome/blue
	name = "blue moons raiment"
	desc = "Official Thunderdome armor of the Blue Moons team."
	icon_state = "tdblue"
	item_state = "tdblue"

/obj/item/clothing/suit/armor/tdome/yellow
	name = "yellow thunder raiment"
	desc = "Official Thunderdome armor of the Yellow Thunder team."
	icon_state = "tdyellow"
	item_state = "tdyellow"

/obj/item/clothing/suit/armor/turd
	name = "T.U.R.D.S. Tactical Gear"
	icon_state = "turd"
	item_state = "turd"

/obj/item/clothing/suit/armor/NT
	name = "armored nanotrasen jacket"
	desc = "An armored jacket worn by NanoTrasen security commanders."
	icon_state = "ntarmor"
	item_state = "ntarmor"
	body_parts_covered = TORSO
	hides_from_examine = 0
	obstructs = C_UNIFORM

/obj/item/clothing/suit/armor/NT_alt
	name = "old armored vest"
	desc = "A grungy surplus armored vest. Smelly and not very clean."
	icon_state = "nt2armor"
	item_state = "nt2armor"
	body_parts_covered = TORSO
	hides_from_examine = 0
	obstructs = C_UNIFORM
	setupProperties()
		..()
		setProperty("meleeprot", 6)
		setProperty("rangedprot", 1)

/obj/item/clothing/suit/armor/EOD
	name = "bomb disposal suit"
	desc = "A suit designed to absorb explosive force; very bulky and unwieldy to maneuver in."
	icon_state = "eod"
	item_state = "eod"
	w_class = W_CLASS_NORMAL
	hides_from_examine = C_UNIFORM|C_GLOVES
	obstructs = C_UNIFORM|C_GLOVES
	setupProperties()
		..()
		setProperty("meleeprot", 9)
		setProperty("rangedprot", 2)
		setProperty("disorient_resist", 10)
		setProperty("movespeed", 0.45)
		setProperty("exploprot", 60)

/obj/item/clothing/suit/armor/hoscape
	name = "Head of Security's cape"
	desc = "A lightly-armored and stylish cape, made of heat-resistant materials. It probably won't keep you warm, but it would make a great security blanket!"
	icon_state = "hos-cape"
	item_state = "hos-cape"
	hides_from_examine = 0
	obstructs = 0
	setupProperties()
		..()
		setProperty("meleeprot", 3)
		setProperty("rangedprot", 0.7)
		setProperty("coldprot", 5)
		setProperty("heatprot", 35)
