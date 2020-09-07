
/* =================================================== */
/* -------------------- Injectors -------------------- */
/* =================================================== */

/obj/item/reagent_containers/emergency_injector
	name = "emergency auto-injector"
	desc = "A small syringe-like thing that automatically injects its contents into someone."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "emerg_inj-orange"
	icon_state = "emerg_inj-orange"
	initial_volume = 10
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/image/fluid_image
	var/empty = 0
	var/label = "orange" // colors available as of the moment: orange, red, blue, green, yellow, purple, black, white, big red
	module_research = list("medicine" = 1, "science" = 1)
	module_research_type = /obj/item/reagent_containers/emergency_injector
	hide_attack = 2

	on_reagent_change()
		src.update_icon()

	proc/update_icon()
		src.underlays = null
		if (reagents.total_volume)
			icon_state = "emerg_inj-[label]"
			var/datum/color/average = reagents.get_average_color()
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "emerg_inj-fluid", -1)
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
		else
			icon_state = "emerg_inj-[label]0"
		item_state = "emerg_inj-[label]"

	attack(mob/M as mob, mob/user as mob)
		if (iscarbon(M) || ismobcritter(M))
			if (src.empty || !src.reagents)
				boutput(user, "<span class='alert'>There's nothing to inject, [src] has already been expended!</span>")
				return
			else
				if (!M.reagents)
					return ..()
				logTheThing("combat", user, M, "injects [constructTarget(M,"combat")] with [src] [log_reagents(src)]")
				src.reagents.trans_to(M, amount_per_transfer_from_this)
				user.visible_message("<span class='alert'>[user] injects [M == user ? "[his_or_her(user)]self" : M] with [src]!</span>",\
				"<span class='alert'>You inject [M == user ? "yourself" : M] with [src]!</span>")
				playsound(get_turf(M), "sound/items/hypo.ogg", 40, 0)
				if(!src.reagents.total_volume)
					src.empty = 1
				return
		else
			boutput(user, "<span class='alert'>You can only use [src] on people!</span>")
			return

	attack_self(mob/user)
		if (iscarbon(user) || ismobcritter(user))
			if (src.empty || !src.reagents)
				boutput(user, "<span class='alert'>There's nothing to inject, [src] has already been expended!</span>")
				return
			else
				if (!user.reagents)
					return ..()
				logTheThing("combat", user, null, "injects themself with [src] [log_reagents(src)]")
				src.reagents.trans_to(user, amount_per_transfer_from_this)
				user.visible_message("<span class='alert'>[user] injects [his_or_her(user)]self with [src]!</span>",\
				"<span class='alert'>You inject yourself with [src]!</span>")
				playsound(get_turf(user), "sound/items/hypo.ogg", 40, 0)
				if(!src.reagents.total_volume)
					src.empty = 1
				return
		else
			return

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/emergency_injector/epinephrine
	name = "emergency auto-injector (epinephrine)"
	initial_reagents = "epinephrine"

/obj/item/reagent_containers/emergency_injector/atropine
	name = "emergency auto-injector (atropine)"
	initial_reagents = "atropine"
	label = "red"

/obj/item/reagent_containers/emergency_injector/charcoal
	name = "emergency auto-injector (charcoal)"
	initial_reagents = "charcoal"
	label = "green"

/obj/item/reagent_containers/emergency_injector/saline
	name = "emergency auto-injector (saline-glucose)"
	initial_reagents = "saline"
	label = "blue"

/obj/item/reagent_containers/emergency_injector/anti_rad
	name = "emergency auto-injector (potassium iodide)"
	initial_reagents = "anti_rad"
	label = "green"
	
/obj/item/reagent_containers/emergency_injector/pentetic_acid
	name = "emergency auto-injector (pentetic acid)"
	initial_reagents = list("penteticacid"=5)
	label = "blue"

/obj/item/reagent_containers/emergency_injector/insulin
	name = "emergency auto-injector (insulin)"
	initial_reagents = "insulin"
	label = "yellow"

/obj/item/reagent_containers/emergency_injector/calomel
	name = "emergency auto-injector (calomel)"
	initial_reagents = list("calomel"=5)
	label = "green"

/obj/item/reagent_containers/emergency_injector/salicylic_acid
	name = "emergency auto-injector (salicylic acid)"
	initial_reagents = "salicylic_acid"
	label = "purple"

/obj/item/reagent_containers/emergency_injector/spaceacillin
	name = "emergency auto-injector (spaceacillin)"
	initial_reagents = "spaceacillin"
	label = "yellow"

/obj/item/reagent_containers/emergency_injector/antihistamine
	name = "emergency auto-injector (diphenhydramine)"
	initial_reagents = "antihistamine"
	label = "blue"

/obj/item/reagent_containers/emergency_injector/salbutamol
	name = "emergency auto-injector (salbutamol)"
	initial_reagents = "salbutamol"
	label = "blue"
	
/obj/item/reagent_containers/emergency_injector/perf
	name = "emergency auto-injector (perfluorodecalin)"
	initial_reagents = "perfluorodecalin"
	label = "blue"

/obj/item/reagent_containers/emergency_injector/mannitol
	name = "emergency auto-injector (mannitol)"
	initial_reagents = "mannitol"
	label = "red"

/obj/item/reagent_containers/emergency_injector/mutadone
	name = "emergency auto-injector (mutadone)"
	initial_reagents = "mutadone"
	label = "purple"

/obj/item/reagent_containers/emergency_injector/heparin
	name = "emergency auto-injector (heparin)"
	initial_reagents = "heparin"
	label = "green"

/obj/item/reagent_containers/emergency_injector/proconvertin
	name = "emergency auto-injector (proconvertin)"
	initial_reagents = "proconvertin"
	label = "red"

/obj/item/reagent_containers/emergency_injector/filgrastim
	name = "emergency auto-injector (filgrastim)"
	initial_reagents = "filgrastim"
	label = "purple"

/obj/item/reagent_containers/emergency_injector/methamphetamine
	name = "emergency auto-injector (methamphetamine)"
	initial_reagents = "methamphetamine"
	label = "white"

/obj/item/reagent_containers/emergency_injector/lexorin
	name = "emergency auto-injector (lexorin)"
	initial_reagents = "lexorin" // was trying to add 15u to the injector but um injectors can only contain up to 10u so ??????
	label = "blue"

/obj/item/reagent_containers/emergency_injector/synaptizine
	name = "emergency auto-injector (synaptizine)"
	initial_reagents = "synaptizine" // same as the lexorin, they both ended up with 10u in the end so I'm just gunna leave it like this idk
	label = "orange"

/obj/item/reagent_containers/emergency_injector/morphine
	name = "emergency auto-injector (morphine)"
	initial_reagents = "morphine"
	label = "purple"

/obj/item/reagent_containers/emergency_injector/random
	name = "emergency auto-injector (???)"
	label = "black"
	New()
		src.initial_reagents = pick("methamphetamine", "formaldehyde", "lipolicide", "pancuronium", "sulfonal", "morphine", "toxin", "bee", "LSD", "space_drugs", "THC", "mucus", "green_mucus", "crank", "bathsalts", "krokodil", "catdrugs", "jenkem", "psilocybin", "omnizine")
		..()

/obj/item/reagent_containers/emergency_injector/vr/epinephrine
	name = "emergency auto-injector (epinephrine)"
	initial_reagents = "epinephrine"
	label = "vr"

/obj/item/reagent_containers/emergency_injector/vr/calomel
	name = "emergency auto-injector (calomel)"
	initial_reagents = list("calomel"=5)
	label = "vr2"

/* ======================================================================== */
/* -------------------- Nuke Ops Medic - high-capacity -------------------- */
/* ======================================================================== */

/obj/item/reagent_containers/emergency_injector/high_capacity/
	name = "high-capacity auto-injector"
	initial_volume = 50
	amount_per_transfer_from_this = 5

/obj/item/reagent_containers/emergency_injector/high_capacity/epinephrine
	name = "high-capacity auto-injector (epinephrine)"
	initial_reagents = "epinephrine"
	label = "green"

/obj/item/reagent_containers/emergency_injector/high_capacity/salbutamol
	name = "high-capacity auto-injector (salbutamol)"
	initial_reagents = "salbutamol"
	label = "blue"

/obj/item/reagent_containers/emergency_injector/high_capacity/salicylic_acid
	name = "high-capacity auto-injector (salicylic acid)"
	initial_reagents = "salicylic_acid"
	label = "purple"

/obj/item/reagent_containers/emergency_injector/high_capacity/saline
	name = "high-capacity auto-injector (saline-glucose)"
	initial_reagents = "saline"
	label = "blue"

/obj/item/reagent_containers/emergency_injector/high_capacity/atropine
	name = "high-capacity auto-injector (atropine)"
	initial_reagents = "atropine"
	label = "red"

/obj/item/reagent_containers/emergency_injector/high_capacity/pentetic
	name = "high-capacity auto-injector (pentetic acid)"
	initial_reagents = "penteticacid"
	label = "purple"

/obj/item/reagent_containers/emergency_injector/high_capacity/mannitol
	name = "high-capacity auto-injector (mannitol)"
	initial_reagents = "mannitol"
	label = "green"

/obj/item/reagent_containers/emergency_injector/high_capacity/juggernaut
	name = "Juggernaut injector"
	desc = "A large syringe-like thing that automatically injects its contents into someone. This one contains juggernaut, a potent pain-killing chemical."
	initial_reagents = "juggernaut"
	label = "bigred"
	initial_volume = 60
	amount_per_transfer_from_this = 20
