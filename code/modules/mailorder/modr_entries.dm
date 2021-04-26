ABSTRACT_TYPE(/datum/mail_order)
/datum/mail_order
	var/name = "Juicer Schweet's Spaghetti Western"
	var/desc = "Be like the three-second elephant with heated value in space-bark."
	var/list/order_items = list() // should not exceed 7 items, as mail order is sent in a box item
	var/cost = PAY_UNTRAINED
	var/list/order_perm = list() // optional access requirement to order a given item


//Tanhony & Sons: journalistic equipment
ABSTRACT_TYPE(/datum/mail_order/audiovideo)
/datum/mail_order/audiovideo

	audiolog
		name = "Audio Log"
		desc = "A must-have for catching that crucial conversation."
		order_items = list(/obj/item/device/audio_log)
		cost = PAY_TRADESMAN

	audiotape
		name = "Audio Tape"
		desc = "Audio storage tape for use in suitable audio devices."
		order_items = list(/obj/item/audio_tape)
		cost = PAY_TRADESMAN / 3


//Farmer Melons' Market Cart: wildly expensive produce a la carte
ABSTRACT_TYPE(/datum/mail_order/produce)
/datum/mail_order/produce

	apple
		name = "Apple"
		desc = "A delicious fresh apple suitable for eating or baking."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/apple)
		cost = PAY_TRADESMAN / 4

	banana
		name = "Banana"
		desc = "The renowned apple of paradise, delivered just to you!"
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/banana)
		cost = PAY_TRADESMAN / 3

	grapes
		name = "Grapes"
		desc = "Our finest table grapes, still on the vine."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/grape)
		cost = PAY_TRADESMAN / 3

	tomato
		name = "Tomato"
		desc = "A top-quality tomato, certified free of blemishes and rot."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/tomato)
		cost = PAY_TRADESMAN / 3


//Survival Mart: primarily medical, but not exclusively
ABSTRACT_TYPE(/datum/mail_order/survmart)
/datum/mail_order/survmart

	oxytank
		name = "Emergency Oxygen Tank"
		desc = "An easy-to-use compact gas tank pre-loaded with pure oxygen."
		order_items = list(/obj/item/tank/emergency_oxygen)
		cost = PAY_TRADESMAN

	wintercoat
		name = "Winterized Overcoat"
		desc = "Beat the cold of space with your very own cozy coat."
		order_items = list(/obj/item/clothing/suit/wintercoat)
		cost = PAY_TRADESMAN / 2

	medbelt
		name = "Medical Belt"
		desc = "Top-quality belt for rapid medical equipment access."
		order_items = list(/obj/item/storage/belt/medical)
		cost = PAY_DOCTORATE
		order_perm = list(access_medical)

	analyze_kit
		name = "Analyzer Triage Bundle"
		desc = "Order a health analyzer, and we'll throw in a bandage for free!"
		order_items = list(/obj/item/device/analyzer/healthanalyzer,/obj/item/bandage)
		cost = PAY_TRADESMAN / 4

	analyze_up
		name = "Analyzer Deluxe Upgrades"
		desc = "Top-of-the-line enhancements for any standard health analyzer."
		order_items = list(/obj/item/device/analyzer/healthanalyzer_upgrade,/obj/item/device/analyzer/healthanalyzer_organ_upgrade)
		cost = PAY_DOCTORATE / 3

	auto_char
		name = "Charcoal Auto-Injector"
		desc = "Rapidly flushes toxins out of your system - a must for biohazards."
		order_items = list(/obj/item/reagent_containers/emergency_injector/charcoal)
		cost = PAY_DOCTORATE / 3

	auto_epi
		name = "Epinephrine Auto-Injector"
		desc = "Stabilizes critical patients - the gold standard for crisis care."
		order_items = list(/obj/item/reagent_containers/emergency_injector/epinephrine)
		cost = PAY_DOCTORATE / 2

	auto_salb
		name = "Salbutamol Auto-Injector"
		desc = "Mitigates the effect of hypoxia. Useful in case of hull breach."
		order_items = list(/obj/item/reagent_containers/emergency_injector/salbutamol)
		cost = PAY_DOCTORATE / 4

	patch_brute
		name = "Healing Mini-Patch"
		desc = "A robust medical patch effective at treating brute-force injury."
		order_items = list(/obj/item/reagent_containers/patch/mini/bruise)
		cost = PAY_TRADESMAN / 4

	patch_burn
		name = "Burn Mini-Patch"
		desc = "A soothing medical patch effective at treating burn injury."
		order_items = list(/obj/item/reagent_containers/patch/mini/burn)
		cost = PAY_TRADESMAN / 4

	cleangear
		name = "Medical Wear Bundle"
		desc = "Contains latex gloves and sterile mask."
		order_items = list(/obj/item/clothing/gloves/latex,/obj/item/clothing/mask/surgical)
		cost = PAY_UNTRAINED / 2


//Chems-R-Us: pre-packaged chemicals
ABSTRACT_TYPE(/datum/mail_order/chem)
/datum/mail_order/chem
	order_perm = list(access_chemistry)

	acetone
		name = "Acetone, 50u Bottle"
		desc = "Strong solvent useful as intermediary reagent or sticker remover."
		order_items = list(/obj/item/reagent_containers/glass/bottle/acetone)
		cost = PAY_DOCTORATE / 3

	ammonia
		name = "Ammonia, 50u Bottle"
		desc = "Suitable for hydroponic fertilization or chemical synthesis."
		order_items = list(/obj/item/reagent_containers/glass/bottle/ammonia)
		cost = PAY_TRADESMAN / 3
		order_perm = list(access_chemistry,access_hydro,access_janitor)

	formaldehyde
		name = "Formaldehyde, 50u Bottle"
		desc = "Hazardous reagent frequently used in embalming."
		order_items = list(/obj/item/reagent_containers/glass/bottle/formaldehyde)
		cost = PAY_DOCTORATE / 2
		order_perm = list(access_chemistry,access_medical)

	phenol
		name = "Phenol, 50u Bottle"
		desc = "Acidic reagent  in organic chemistry."
		order_items = list(/obj/item/reagent_containers/glass/bottle/phenol)
		cost = PAY_DOCTORATE / 3
