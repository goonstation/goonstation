ABSTRACT_TYPE(/datum/mail_order)
/datum/mail_order
	var/name = "Juicer Schweet's Spaghetti Western"
	var/desc = "Be like the three-second elephant with heated value in space-bark."
	var/list/order_items = list() // should not exceed 7 items, as mail order is sent in a box item
	var/cost = PAY_UNTRAINED
	var/list/order_perm = list() // optional access requirement to order a given item


//Tanhony & Sons: journalistic equipment, primarily AV
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


//Henry's Recreation: activity supplies - sports, instruments, pool
ABSTRACT_TYPE(/datum/mail_order/recreation)
/datum/mail_order/recreation

	guitar
		name = "Guitar"
		desc = "Our signature hand-strung guitar in genuine space wood."
		order_items = list(/obj/item/instrument/guitar)
		cost = PAY_TRADESMAN

	saxophone
		name = "Saxophone"
		desc = "The smoothest hunk of brass this side of the galaxy."
		order_items = list(/obj/item/instrument/saxophone)
		cost = PAY_TRADESMAN


//Farmer Melons' Market Cart: wildly expensive food, a la carte
ABSTRACT_TYPE(/datum/mail_order/produce)
/datum/mail_order/produce

	salad
		name = "Pre-Packaged Salad"
		desc = "Our convenient ready-to-eat salads arrive only slightly wilted!"
		order_items = list(/obj/item/reagent_containers/food/snacks/salad)
		cost = PAY_TRADESMAN / 3

	guac
		name = "Deluxe Guacamole"
		desc = "Made from the finest avocadoes and laser-sterilized for quality."
		order_items = list(/obj/item/reagent_containers/food/snacks/soup/guacamole)
		cost = PAY_DOCTORATE

	apple
		name = "Apple"
		desc = "A delicious fresh apple suitable for eating or baking."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/apple)
		cost = PAY_TRADESMAN / 4

	banana
		name = "Banana"
		desc = "The renowned apple of paradise, delivered just to you!"
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/banana)
		cost = PAY_TRADESMAN / 4

	grapes
		name = "Grapes"
		desc = "Our finest table grapes, still on the vine."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/grape)
		cost = PAY_TRADESMAN / 4

	peach
		name = "Peach"
		desc = "Genuine clingstone, chemically preserved at peak ripeness."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/peach/)
		cost = PAY_TRADESMAN / 3

	tomato
		name = "Tomato"
		desc = "A top-quality tomato, certified free of blemishes and rot."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/tomato)
		cost = PAY_TRADESMAN / 4

	cereal_wonks
		name = "Honey Wonks Cereal"
		desc = "Your sticky-sweet sugar rush, at a super special price."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/honey)
		cost = PAY_TRADESMAN / 5

	cereal_monki
		name = "Tanh-O-Nys Cereal"
		desc = "Does it taste like banana? Who knows! Buy some and find out."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/tanhony)
		cost = PAY_TRADESMAN / 5

	cereal_roach
		name = "Roach Puffs Cereal"
		desc = "Everybody's favorite chocolate-themed roach-themed treat."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/roach)
		cost = PAY_TRADESMAN / 5

	cereal_bundle
		name = "Munch 'Em All Bundle"
		desc = "Can't decide on a cereal? Buy them all and save!"
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/roach)
		cost = PAY_TRADESMAN / 2


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
	reagentscanner
		name = "Reagent Scanner"
		desc = "Handheld device capable of real-time reagent analysis."
		order_items = list(/obj/item/device/reagentscanner)
		cost = PAY_DOCTORATE / 3

	spectrogoggles
		name = "Spectroscopic Goggles"
		desc = "The latest in optically-mounted Raman spectroscopy technology."
		order_items = list(/obj/item/clothing/glasses/spectro)
		cost = PAY_IMPORTANT / 2
		order_perm = list(access_bar,access_chemistry,access_medical)

	beaker
		name = "Space-Borosilicate Beaker"
		desc = "High-quality beaker for volatile chemistry. Holds 100 units."
		order_items = list(/obj/item/reagent_containers/glass/beaker/large)
		cost = PAY_DOCTORATE / 2
		order_perm = list(access_bar,access_chemistry,access_medical)

	acetone
		name = "Acetone, 50u Bottle"
		desc = "Strong solvent useful as intermediary reagent or sticker remover."
		order_items = list(/obj/item/reagent_containers/glass/bottle/acetone)
		cost = PAY_DOCTORATE / 3
		order_perm = list(access_chemistry,access_medical)

	ammonia
		name = "Ammonia, 50u Bottle"
		desc = "Suitable for hydroponic fertilization or chemical synthesis."
		order_items = list(/obj/item/reagent_containers/glass/bottle/ammonia)
		cost = PAY_TRADESMAN / 3
		order_perm = list(access_chemistry,access_hydro,access_janitor,access_medical)

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
		order_perm = list(access_chemistry,access_medical)
