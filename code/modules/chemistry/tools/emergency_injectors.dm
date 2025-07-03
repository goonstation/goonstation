
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
	flags = TABLEPASS
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/image/fluid_image
	var/empty = 0
	var/label = "orange" // colors available as of the moment: orange, red, blue, green, yellow, purple, black, white, big red
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	var/manipulated_injection = FALSE //! is this injector being tampered with and being unuseable for injecting people?

	New()
		..()
		src.item_state = "emerg_inj-[src.label]"
		src.fluid_image = image(src.icon, "emerg_inj-fluid")
		src.fluid_image.color = src.reagents.get_average_color().to_rgba()
		src.UpdateIcon()
		// auto-injector + cutting tool  -> sabotaged auto-injector
		src.AddComponent(/datum/component/assembly, TOOL_CUTTING, PROC_REF(knife_manipulation), FALSE)

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		if (src.reagents.total_volume)
			src.icon_state = "emerg_inj-[src.label]"
		else
			src.icon_state = "emerg_inj-[src.label]0"
			src.fluid_image = image(src.fluid_image, "emerg_inj-fluid-flick")
			FLICK("emerg_inj-[src.label]-flick", src)
		UpdateOverlays(src.fluid_image, "fluid")

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		src.try_injection(user, target)
		return

	attack_self(mob/user)
		src.try_injection(user, user)
		return


	get_help_message(dist, mob/user)
		if(!src.manipulated_injection && !src.empty)
			. += " You can use a <b>knife</b> to sabotage the injector."

	proc/try_injection(mob/user, mob/target)
		if (src.empty || !src.reagents)
			boutput(user, SPAN_ALERT("There's nothing to inject, [src] has already been expended!"))
			return
		if (iscarbon(target) || ismobcritter(target) || target.reagents)
			if (src.manipulated_injection)
				logTheThing(LOG_COMBAT, user, "tries to inject [target == user ? himself_or_herself(user) : constructTarget(target,"combat")] with a sabotaged [src] [log_reagents(src)]")
				user.visible_message(SPAN_ALERT("[user] tries to use [src] on [target == user ? himself_or_herself(user) : target], but [src] fails and sprays its contents on the ground!"),\
				SPAN_ALERT("You try to use [src] on [target == user ? "yourself" : target], but [src] jams prematurely and all its contents spray onto the ground!"))
				var/turf/target_turf = get_turf(user)
				var/datum/reagents/temp_holder = new
				src.reagents.trans_to_direct(temp_holder, src.amount_per_transfer_from_this)
				target_turf.fluid_react(temp_holder, temp_holder.total_volume)
				temp_holder.reaction(target_turf, TOUCH)
				playsound(user, 'sound/impact_sounds/Generic_Snap_1.ogg', 30, FALSE)
			else
				logTheThing(LOG_COMBAT, user, "injects [target == user ? himself_or_herself(user) : constructTarget(target,"combat")] with [src] [log_reagents(src)]")
				src.reagents.trans_to(target, src.amount_per_transfer_from_this)
				user.visible_message(SPAN_ALERT("[user] injects [target == user ? himself_or_herself(user) : target] with [src]!"),\
				SPAN_ALERT("You inject [target == user ? "yourself" : target] with [src]!"))
				playsound(target, 'sound/items/hypo.ogg', 40, FALSE)
			if(!src.reagents.total_volume)
				src.empty = 1
				src.name += " (expended)"
		else
			boutput(user, SPAN_ALERT("You can only use [src] on people!"))

/// autoinjector manipulation procs
	proc/knife_manipulation(var/atom/to_combine_atom, var/mob/user)
		if (src.empty || !src.reagents)
			boutput(user, SPAN_ALERT("There's no reason to sabotage this, [src] has already been expended!"))
		else
			boutput(user, SPAN_NOTICE("You cut into the spring mechanism, making it unusable for medical use."))
			src.manipulated_injection = TRUE
			src.desc += " You can see a deep cut on its side."
			//Since we sucessfully manipulated the injector, remove all the assembly components
			src.RemoveComponentsOfType(/datum/component/assembly)
			return TRUE

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/emergency_injector/epinephrine
	name = "emergency auto-injector (epinephrine)"
	initial_reagents = "epinephrine"
	desc = "An auto-injector containing epinephrine, also known as adrenaline. Used for stabilizing critical patients and as an antihistamine in severe allergic reactions."

/obj/item/reagent_containers/emergency_injector/atropine
	name = "emergency auto-injector (atropine)"
	initial_reagents = "atropine"
	label = "red"
	desc = "An auto-injector containing atropine, used for cardiac emergencies and as a stabilizer in extreme medical cases."

/obj/item/reagent_containers/emergency_injector/charcoal
	name = "emergency auto-injector (charcoal)"
	initial_reagents = "charcoal"
	label = "green"
	desc = "An auto-injector containing charcoal, a general purpose antitoxin."

/obj/item/reagent_containers/emergency_injector/saline
	name = "emergency auto-injector (saline-glucose)"
	initial_reagents = "saline"
	label = "blue"
	desc = "An auto-injector containing saline-glucose solution, used for treating blood loss and shock. It also speeds up recovery from small injuries."

/obj/item/reagent_containers/emergency_injector/anti_rad
	name = "emergency auto-injector (potassium iodide)"
	initial_reagents = "anti_rad"
	label = "green"
	desc = "An auto-injector containing potassium iodide, a weak antitoxin that serves mainly to treat or reduce the effects of radiation poisoning."

/obj/item/reagent_containers/emergency_injector/pentetic_acid
	name = "emergency auto-injector (pentetic acid)"
	initial_reagents = list("penteticacid"=5)
	label = "blue"
	desc = "An auto-injector containing pentetic acid, an experimental and aggressive chelation agent."

/obj/item/reagent_containers/emergency_injector/omnizine
	name = "emergency auto-injector (omnizine)"
	initial_reagents = list("omnizine"=5)
	label = "white"
	desc = "An auto-injector containing omnizine, the manufacturer's label is scratched off."

/obj/item/reagent_containers/emergency_injector/insulin
	name = "emergency auto-injector (insulin)"
	initial_reagents = "insulin"
	label = "yellow"
	desc = "An auto-injector containing insulin, for treating hyperglycaemic shock."

/obj/item/reagent_containers/emergency_injector/calomel
	name = "emergency auto-injector (calomel)"
	initial_reagents = list("calomel"=5)
	label = "green"
	desc = "An auto-injector containing calomel, for flushing chemicals from the blood stream in cases with severe poisoning."

/obj/item/reagent_containers/emergency_injector/salicylic_acid
	name = "emergency auto-injector (salicylic acid)"
	initial_reagents = "salicylic_acid"
	label = "purple"
	desc = "An auto-injector containing salicyclic acid, used as a painkiller and for treating moderate injuries."

/obj/item/reagent_containers/emergency_injector/spaceacillin
	name = "emergency auto-injector (spaceacillin)"
	initial_reagents = "spaceacillin"
	label = "yellow"
	desc = "An auto-injector containing spaceacillin, for curing minor diseases."

/obj/item/reagent_containers/emergency_injector/antihistamine
	name = "emergency auto-injector (diphenhydramine)"
	initial_reagents = "antihistamine"
	label = "blue"
	desc = "An auto-injector containing diphenhydramine, useful for reducing the severity of allergic reactions."

/obj/item/reagent_containers/emergency_injector/salbutamol
	name = "emergency auto-injector (salbutamol)"
	initial_reagents = "salbutamol"
	label = "blue"
	desc = "An auto-injector containing salbutamol, for opening the airways and aiding recovery from suffocation."

/obj/item/reagent_containers/emergency_injector/perf
	name = "emergency auto-injector (perfluorodecalin)"
	initial_reagents = "perfluorodecalin"
	label = "blue"
	desc = "An auto-injector containing perfluorodecalin, an experimental liquid-breathing medicine."

/obj/item/reagent_containers/emergency_injector/mannitol
	name = "emergency auto-injector (mannitol)"
	initial_reagents = "mannitol"
	label = "red"
	desc = "An auto-injector containing mannitol, a medicine used to treat severe concussions."

/obj/item/reagent_containers/emergency_injector/mutadone
	name = "emergency auto-injector (mutadone)"
	initial_reagents = "mutadone"
	label = "purple"
	desc = "An auto-injector containing mutadone, an experimental medicine that reverses genetic abnormalities."

/obj/item/reagent_containers/emergency_injector/heparin
	name = "emergency auto-injector (heparin)"
	initial_reagents = "heparin"
	label = "green"
	desc = "An auto-injector containing anticoagulant, for helping with blood clots and heart disease."

/obj/item/reagent_containers/emergency_injector/proconvertin
	name = "emergency auto-injector (proconvertin)"
	initial_reagents = "proconvertin"
	label = "red"
	desc = "An auto-injector containing coagulant, for reducing blood loss and increasing blood pressure."

/obj/item/reagent_containers/emergency_injector/filgrastim
	name = "emergency auto-injector (filgrastim)"
	initial_reagents = "filgrastim"
	label = "purple"
	desc = "An auto-injector containing filgrastim, for stimulating blood production in cases with heavy blood loss."

/obj/item/reagent_containers/emergency_injector/methamphetamine
	name = "emergency auto-injector (methamphetamine)"
	initial_reagents = "methamphetamine"
	label = "white"
	desc = "An auto-injector containing methamphetamine, a powerful, yet addictive stimulant."

/obj/item/reagent_containers/emergency_injector/lexorin
	name = "emergency auto-injector (lexorin)"
	initial_reagents = "lexorin" // was trying to add 15u to the injector but um injectors can only contain up to 10u so ??????
	label = "blue"

/obj/item/reagent_containers/emergency_injector/synaptizine
	name = "emergency auto-injector (synaptizine)"
	initial_reagents = "synaptizine" // same as the lexorin, they both ended up with 10u in the end so I'm just gunna leave it like this idk
	label = "orange"
	desc = "An auto-injector containing synaptizine, a non-addictive stimulant whose side effects can cause regeneration of brain tissue."

/obj/item/reagent_containers/emergency_injector/morphine
	name = "emergency auto-injector (morphine)"
	initial_reagents = "morphine"
	label = "purple"
	desc = "An auto-injector containing morphine, a powerful painkiller and sedative."

/obj/item/reagent_containers/emergency_injector/random
	name = "emergency auto-injector (???)"
	label = "black"
	desc = "An auto-injector containing uhh, well, y'see... Hmm. You're unsure on this one."
	New()
		src.initial_reagents = pick("methamphetamine", "formaldehyde", "lipolicide", "pancuronium", "sulfonal", "morphine", "toxin", "bee", "LSD", "lsd_bee", "space_drugs", "THC", "mucus", "green mucus", "crank", "bathsalts", "krokodil", "catdrugs", "psilocybin", "omnizine")
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
	desc = "A high-capacity auto-injector containing containing epinephrine, also known as adrenaline. Used for stabilizing critical patients and as an antihistamine in severe allergic reactions."

/obj/item/reagent_containers/emergency_injector/high_capacity/salbutamol
	name = "high-capacity auto-injector (salbutamol)"
	initial_reagents = "salbutamol"
	label = "blue"
	desc = "A high-capacity auto-injector containing salbutamol, for opening the airways and aiding recovery from suffocation"

/obj/item/reagent_containers/emergency_injector/high_capacity/salicylic_acid
	name = "high-capacity auto-injector (salicylic acid)"
	initial_reagents = "salicylic_acid"
	label = "purple"
	desc = "A high-capacity auto-injector containing salicyclic acid, used as a painkiller and for treating moderate injuries."

/obj/item/reagent_containers/emergency_injector/high_capacity/saline
	name = "high-capacity auto-injector (saline-glucose)"
	initial_reagents = "saline"
	label = "blue"
	desc = "A high-capacity auto-injector containing saline-glucose solution, used for treating blood loss and shock. It also speeds up recovery from small injuries."

/obj/item/reagent_containers/emergency_injector/high_capacity/atropine
	name = "high-capacity auto-injector (atropine)"
	initial_reagents = "atropine"
	label = "red"
	desc = "A high-capacity auto-injector containing atropine, used for cardiac emergencies and as a stabilizer in extreme medical cases."

/obj/item/reagent_containers/emergency_injector/high_capacity/pentetic
	name = "high-capacity auto-injector (pentetic acid)"
	initial_reagents = "penteticacid"
	label = "purple"
	desc = "A high-capacity auto-injector containing pentetic acid, an experimental and aggressive chelation agent."

/obj/item/reagent_containers/emergency_injector/high_capacity/charcoal
	name = "high-capacity auto-injector (charcoal)"
	initial_reagents = "charcoal"
	label = "green"
	desc = "A high-capacity auto-injector containing charcoal, a reliable anti-tox medicine and poison depletor."

/obj/item/reagent_containers/emergency_injector/high_capacity/mannitol
	name = "high-capacity auto-injector (mannitol)"
	initial_reagents = "mannitol"
	label = "green"
	desc = "A high-capacity auto-injector containing mannitol, a medicine used to treat severe concussions."

/obj/item/reagent_containers/emergency_injector/high_capacity/cardiac
	name = "cardiac combi-injector"
	desc = "A combination medical injector containing saline and epinephrine- useful in near-death situations."
	initial_reagents = list("saline" = 25, "epinephrine" = 25)
	label = "yellow"

/obj/item/reagent_containers/emergency_injector/high_capacity/bloodloss
	name = "bloodloss combi-injector"
	desc = "A combination medical injector containing filgrastim and proconvertin- useful in treating blood loss."
	initial_reagents = list("filgrastim" = 25, "proconvertin" = 25)
	label = "red"

/obj/item/reagent_containers/emergency_injector/high_capacity/lifesupport
	name = "lifesupport combi-injector"
	desc = "A combination medical injector containing salbutamol and mannitol- useful in near-death situations."
	initial_reagents = list("salbutamol" = 25, "mannitol" = 25)
	label = "blue"

/obj/item/reagent_containers/emergency_injector/high_capacity/juggernaut
	name = "Juggernaut injector"
	desc = "A large syringe-like thing that automatically injects its contents into someone. This one contains juggernaut, a potent pain-killing chemical."
	#ifdef SECRETS_ENABLED
	initial_reagents = "juggernaut"
	#endif
	label = "bigred"
	initial_volume = 60
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/emergency_injector/high_capacity/donk_injector
	name = "Donk injector"
	desc = "A large syringe-like thing that automatically injects its contents into someone. This one contains a cocktail of chemicals intended to mimic the effect of eating a warm donk pocket."
	initial_reagents = list("omnizine" = 15, "teporone" = 15, "synaptizine" = 15, "saline" = 15, "salbutamol" = 15, "synd_methamphetamine" = 15)
	label = "bigblue"
	initial_volume = 90
	amount_per_transfer_from_this = 15


///// Speciality Injectors
///// These shouldn't really be seen in a normal round

/obj/item/reagent_containers/emergency_injector/bloodbak
	name = "BLOOD-BAK auto-injector"
	desc = "A two-use auto-injector containing filgrastim, proconvertin and saline-glucose to help regain lost blood and stop bleeding."
	initial_reagents = list("filgrastim" = 10, "proconvertin" = 20, "saline" = 20)
	label = "red"
	initial_volume = 50
	amount_per_transfer_from_this = 25

/obj/item/reagent_containers/emergency_injector/qwikheal
	name = "QWIK-HEAL auto-injector"
	desc = "A two-use auto-injector containing omnizine, salbutamol, and epinephrine to quickly get back into the battle."
	initial_reagents = list("omnizine" = 20, "salbutamol" = 20, "epinephrine" = 20)
	label = "blue"
	initial_volume = 60
	amount_per_transfer_from_this = 30

/obj/item/reagent_containers/emergency_injector/painstop
	name = "PAIN-STOP auto-injector"
	desc = "A two-use auto-injector containing salicylic acid, and synaptizine to help stop pain. WARNING: Two uses in short time span may cause overdose."
	initial_reagents = list("salicylic_acid" = 30, "synaptizine" = 20)
	label = "green"
	initial_volume = 50
	amount_per_transfer_from_this = 25

/obj/item/reagent_containers/emergency_injector/bringbak
	name = "BRING-BAK auto-injector"
	desc = "A single-use auto-injector containing atropine, mannitol, saline, epinephrine, and salbutamol to stabilize a soldier in critical condition. WARNING: Causes disorentation."
	initial_reagents = list("atropine" =10 , "mannitol" =10 , "saline" =10 , "epinephrine" =10 , "salbutamol" =10)
	label = "white"
	initial_volume = 50
	amount_per_transfer_from_this = 50
