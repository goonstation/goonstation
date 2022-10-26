
/* ================================================= */
/* -------------------- Bottles -------------------- */
/* ================================================= */

/obj/item/reagent_containers/glass/bottle
	name = "bottle"
	desc = "A small bottle."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	item_state = "atoxinbottle"
	initial_volume = 30
	var/image/fluid_image
	var/bottle_style = null
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	amount_per_transfer_from_this = 10
	flags = FPRINT | TABLEPASS | OPENCONTAINER | SUPPRESSATTACK
	object_flags = NO_GHOSTCRITTER

	New()
		if (!src.bottle_style)
			src.bottle_style = "[rand(1,4)]"
		src.UpdateIcon()
		..()

	on_reagent_change()
		..()
		src.UpdateIcon()

	update_icon()
		..()
		if (!(findtext(src.icon_state, "bottle", 1, length("bottle") + 1)))
			return
		src.underlays = null
		if (reagents?.total_volume)
			var/datum/color/average = reagents.get_average_color()
			var/fluid_state = round(clamp((((src.reagents.total_volume / src.reagents.maximum_volume) * 4) + 1), 1, 4))
			src.fluid_image = image('icons/obj/chemical.dmi', "fluid-bottle[bottle_style]-[fluid_state]", -1)
			src.icon_state = "bottle[bottle_style]-[fluid_state]"
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
		else
			src.icon_state = "bottle[bottle_style]"
		signal_event("icon_updated")

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */
/obj/item/reagent_containers/glass/bottle/plastic
	name = "plastic bottle"
	desc = "A small 3D-printed bottle."
	can_recycle = FALSE

	New()
		. = ..()
		AddComponent(/datum/component/biodegradable)


/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "bottle (epinephrine)"
	desc = "A small bottle. Contains epinephrine, also known as adrenaline. Used for stabilizing critical patients and as an antihistamine in severe allergic reactions."
	bottle_style = "1"
	amount_per_transfer_from_this = 10
	initial_reagents = "epinephrine"

/obj/item/reagent_containers/glass/bottle/toxin
	name = "toxin bottle"
	desc = "A small bottle containing toxic compounds."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "toxin"

/obj/item/reagent_containers/glass/bottle/atropine
	name = "bottle (atropine)"
	desc = "A small bottle containing atropine, used for cardiac emergencies and as a stabilizer in extreme medical cases.  It has a warning label on it about dizziness and minor toxicity."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "atropine"

/obj/item/reagent_containers/glass/bottle/saline
	name = "bottle (saline-glucose)"
	desc = "A small bottle containing saline-glucose solution, used for treating blood loss and shock. It also speeds up recovery from small injuries."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "saline"

/obj/item/reagent_containers/glass/bottle/aspirin
	name = "bottle (salicylic acid)"
	desc = "A small bottle containing salicyclic acid, used as a painkiller and for treating moderate injuries."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "salicylic_acid"

/obj/item/reagent_containers/glass/bottle/insulin
	name = "bottle (insulin)"
	desc = "A small bottle of insulin, for treating hyperglycaemic shock."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "insulin"

/obj/item/reagent_containers/glass/bottle/heparin
	name = "bottle (heparin)"
	desc = "A small bottle of anticoagulant, for helping with blood clots and heart disease. It has a warning label on it about hypotension."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "heparin"

/obj/item/reagent_containers/glass/bottle/proconvertin
	name = "bottle (proconvertin)"
	desc = "A small bottle of coagulant, for reducing blood loss and increasing blood pressure. It has a warning label on it about hypertension."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "proconvertin"

/obj/item/reagent_containers/glass/bottle/filgrastim
	name = "bottle (filgrastim)"
	desc = "A small bottle of filgrastim, for stimulating blood production in cases with heavy blood loss. It has a warning label on it about hypertension."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "filgrastim"

/obj/item/reagent_containers/glass/bottle/calomel
	name = "bottle (calomel)"
	desc = "A small bottle of calomel, for flushing chemicals from the blood stream in cases with severe poisoning. It has a warning label on it about toxicity."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "calomel"

/obj/item/reagent_containers/glass/bottle/spaceacillin
	name = "bottle (spaceacillin)"
	desc = "A small bottle of spaceacillin, for curing minor diseases."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "spaceacillin"

/obj/item/reagent_containers/glass/bottle/morphine
	name = "bottle (morphine)"
	desc = "A small bottle of morphine, a powerful painkiller and sedative. It has a warning label on it about addiction and minor toxicity."
	bottle_style = "4"
	amount_per_transfer_from_this = 5
	initial_reagents = "morphine"

/obj/item/reagent_containers/glass/bottle/coldmedicine
	name = "bottle (robustissin)"
	desc = "A small bottle containing robustissin, for treating common ailments.  It has a warning label on it about dizziness and minor toxicity."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "cold_medicine"

/// cogwerks - adding some new bottles for traitor medics
// haine - I added beedril/royal beedril to these, and my heart-related disease reagents. yolo (remove these if they're a dumb idea, idk)
/obj/item/reagent_containers/glass/bottle/poison
	name = "chemical bottle"
	desc = "A reagent storage bottle. The label seems to have been torn off."
	initial_volume = 40
	amount_per_transfer_from_this = 5

	New()
		var/poison = pick_string("chemistry_tools.txt", "traitor_poison_bottle")
		src.initial_reagents = poison
		logTheThing(LOG_CHEMISTRY, src, null, "poison bottle spawned from string [poison], contains: [log_reagents(src)]")
		..()

// gannets - large poison bottles for nuke op medics.
/obj/item/reagent_containers/glass/bottle/syringe_canister
	name = "poison canister"
	desc = "A large fluid-filled canister designed to fill a syringe gun."
	icon_state = "syringe_canister"
	initial_volume = 90

	curare
		initial_reagents = "curare"

	neurotoxin
		initial_reagents = "neurotoxin"


//the good medicines

/obj/item/reagent_containers/glass/bottle/pfd
	name = "perfluorodecalin bottle"
	desc = "A small bottle of perfluorodecalin, an experimental liquid-breathing medicine."
	bottle_style = "4"
	amount_per_transfer_from_this = 5
	initial_reagents = "perfluorodecalin"

/obj/item/reagent_containers/glass/bottle/omnizine
	name = "omnizine bottle"
	desc = "A small bottle of an experimental and expensive herbal compound."
	bottle_style = "4"
	amount_per_transfer_from_this = 5
	initial_reagents = "omnizine"

/obj/item/reagent_containers/glass/bottle/ether
	name = "ether bottle"
	desc = "A small bottle of an ether, a strong but highly addictive anesthetic and sedative."
	amount_per_transfer_from_this = 5
	initial_reagents = "ether"

/obj/item/reagent_containers/glass/bottle/haloperidol
	name = "haloperidol bottle"
	desc = "A small bottle of haloperidol, a powerful anti-psychotic."
	amount_per_transfer_from_this = 5
	initial_reagents = "haloperidol"

/obj/item/reagent_containers/glass/bottle/pentetic
	name = "pentetic acid bottle"
	desc = "A small bottle of pentetic acid, an experimental and aggressive chelation agent."
	bottle_style = "4"
	amount_per_transfer_from_this = 5
	initial_reagents = "penteticacid"

//////

/obj/item/reagent_containers/glass/bottle/sulfonal
	name = "sulfonal bottle"
	desc = "A small bottle of sulfonal, an extreme muscle relaxant. It has a warning label on it about impaired breathing and drowsiness."
	bottle_style = "4"
	amount_per_transfer_from_this = 5
	initial_reagents = "sulfonal"

/obj/item/reagent_containers/glass/bottle/synaptizine
	name = "bottle (synaptizine)"
	desc = "A small bottle of synaptizine, a non-addictive stimulant whose side effects can cause regeneration of brain tissue."
	bottle_style = "3"
	amount_per_transfer_from_this = 5
	initial_reagents = "synaptizine"

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "pancuronium bottle"
	desc = "A small bottle of pancuronium, an extreme muscle relaxant. It has a warning label on it about impaired breathing and unconciousness."
	bottle_style = "1"
	amount_per_transfer_from_this = 5
	initial_reagents = "pancuronium"

/obj/item/reagent_containers/glass/bottle/antitoxin
	name = "bottle (charcoal)"
	desc = "A small bottle of charcoal, a general purpose antitoxin."
	bottle_style = "3"
	amount_per_transfer_from_this = 5
	initial_reagents = "charcoal"

/obj/item/reagent_containers/glass/bottle/antihistamine
	name = "bottle (diphenhydramine)"
	desc = "A small bottle of dyphenhidramine, useful for reducing the severity of allergic reactions."
	bottle_style = "1"
	amount_per_transfer_from_this = 5
	initial_reagents = "antihistamine"

/obj/item/reagent_containers/glass/bottle/eyedrops
	name = "bottle (oculine)"
	desc = "A small bottle of combined eye and ear medication. A label on it reads: \"For ease of usage, apply topically.\""
	bottle_style = "1"
	amount_per_transfer_from_this = 5
	initial_reagents = "oculine"

/obj/item/reagent_containers/glass/bottle/antirad
	name = "bottle (potassium iodide)"
	desc = "A small bottle of potassium iodide, a weak antitoxin that serves mainly to treat or reduce the effects of radiation poisoning."
	bottle_style = "3"
	amount_per_transfer_from_this = 5
	initial_reagents = "anti_rad"

/obj/item/reagent_containers/glass/bottle/pacid
	name = "fluorosulfuric acid bottle"
	desc = "A small bottle of fluorosulfuric acid, a potent acid."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "pacid"

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "cyanide bottle"
	desc = "A small bottle of cyanide, a potent poison that prevents the production of ATP, causing cellular suffocation."
	bottle_style = "2"
	amount_per_transfer_from_this = 5
	initial_reagents = "cyanide"

/obj/item/reagent_containers/glass/bottle/fluorosurfactant
	name = "fluorosurfactant bottle"
	desc = "A small bottle of fluorosurfactant, a chemical that foams rapidly when mixed with water."
	bottle_style = "1"
	amount_per_transfer_from_this = 5
	initial_reagents = "fluorosurfactant"

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "rubbing alcohol"
	desc = "Isopropriate, or rubbing alcohol. Please don't drink it."
	icon_state = "plasticbottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "ethanol"

/obj/item/reagent_containers/glass/bottle/mercury
	name = "mercury bottle"
	desc = "A small bottle with a 'Do Not Drink' label on it."
	bottle_style = "1"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "mercury"

/* ========================================================= */
/* -------------------- Chem Precursors -------------------- */
/* ========================================================= */

/obj/item/reagent_containers/glass/bottle/chemical
	name = "chemical bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5

/obj/item/reagent_containers/glass/bottle/chemical/plastic
	name = "plastic chemical bottle"
	desc = "A 3D-printed reagent storage bottle."
	can_recycle = FALSE

	New()
		. = ..()
		AddComponent(/datum/component/biodegradable)

/obj/item/reagent_containers/glass/bottle/oil
	name = "oil bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "oil"

/obj/item/reagent_containers/glass/bottle/phenol
	name = "phenol bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "phenol"

/obj/item/reagent_containers/glass/bottle/acetone
	name = "acetone bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "acetone"

	large
		desc = "A large bottle."
		initial_volume = 100
		icon_state = "largebottle"

	janitors
		desc = "A generic unbranded metallic container for acetone."
		initial_volume = 100
		icon_state = "acetone"

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "ammonia bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "ammonia"

	large
		desc = "A large bottle."
		initial_volume = 100
		icon_state = "largebottle"

	janitors
		desc = "A generic unbranded bottle of ammonia."
		initial_volume = 100
		icon_state = "bleach" // heh

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "diethylamine bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "diethylamine"

/obj/item/reagent_containers/glass/bottle/acid
	name = "acid bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "acid"

	large
		desc = "A large bottle."
		initial_volume = 100
		icon_state = "largebottle"

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "embalming fluid bottle"
	desc = "A reagent storage bottle."
	icon_state = "reagent_bottle"
	initial_volume = 50
	amount_per_transfer_from_this = 5
	initial_reagents = "formaldehyde"

/* ============================================== */
/* -------------------- Misc -------------------- */
/* ============================================== */

/obj/item/reagent_containers/glass/bottle/bubblebath
	name = "Cap'n Bubs(TM) Extra-Manly Bubble Bath"
	desc = "Industrial strength bubblebath with a fat and sassy mascot on the bottle. Neat."
	icon = 'icons/obj/foodNdrink/drinks.dmi'
	icon_state = "moonshine"
	initial_volume = 50
	initial_reagents = list("fluorosurfactant"=30,"pepperoni"=10,"bourbon"=10)
	amount_per_transfer_from_this = 5
	rc_flags = RC_FULLNESS

/obj/item/reagent_containers/glass/bottle/holywater
	name = "Holy Water"
	desc = "A small bottle filled with blessed water."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "holy_water"
	initial_reagents = "water_holy"
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/glass/bottle/cleaner
	name = "cleaner bottle"
	desc = "A bottle filled with cleaning fluid."
	icon_state = "largebottle-labeled"
	initial_volume = 100
	initial_reagents = "cleaner"
	amount_per_transfer_from_this = 10
