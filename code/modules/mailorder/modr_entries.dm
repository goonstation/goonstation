//information for catalogue sale entries
ABSTRACT_TYPE(/datum/mail_order)
/datum/mail_order
	var/name = "Juicer Schweet's Spaghetti Western"
	var/cleanname = null //sanitary version of name created for references
	var/desc = "Be like the three-second elephant with heated value in space-bark."
	var/list/order_items = list() // should not exceed 7 items, as mail order is sent in a box item
	var/cost = PAY_UNTRAINED
	var/list/order_perm = list() // optional access requirement to order a given item

	New()
		..()
		src.cleanname = ckey(src.name)

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

	laptop
		name = "Personal Laptop"
		desc = "The latest in micro-computing, right at your fingertips."
		order_items = list(/obj/item/luggable_computer/personal)
		cost = PAY_EXECUTIVE * 2

	floppy
		name = "Blank Computer Data Disk"
		desc = "Removable data storage, often used in ThinkDOS computers."
		order_items = list(/obj/item/disk/data/floppy)
		cost = PAY_TRADESMAN / 3

	photocam
		name = "Handheld Photo Camera"
		desc = "Captures high-fidelity images with insta-develop film."
		order_items = list(/obj/item/camera)
		cost = PAY_TRADESMAN * 1.2

	photofilm
		name = "Photo Film Cartridge"
		desc = "A replacement film cartridge for handheld photo cameras."
		order_items = list(/obj/item/camera_film)
		cost = PAY_TRADESMAN

	stickynotes
		name = "Sticky Notes"
		desc = "A pack of sticky notes with reclosable flap."
		order_items = list(/obj/item/item_box/postit)
		cost = PAY_TRADESMAN / 5

	typewriter
		name = "Portable Typewriter"
		desc = "Built to our exacting standards for the finest typography."
		order_items = list(/obj/item/portable_typewriter)
		cost = PAY_EXECUTIVE

	writebundle
		name = "Notetaking Bundle"
		desc = "Contains a clipboard, a pen, and two sheets of paper."
		order_items = list(/obj/item/clipboard,/obj/item/pen,/obj/item/paper,/obj/item/paper)
		cost = PAY_TRADESMAN / 5

	paper
		name = "Blank Paper"
		desc = "Three sheets of standard-size unmarked white paper."
		order_items = list(/obj/item/paper,/obj/item/paper,/obj/item/paper)
		cost = PAY_UNTRAINED / 5


//Henry's Recreation: activity supplies - sports, instruments, pool
ABSTRACT_TYPE(/datum/mail_order/recreation)
/datum/mail_order/recreation

	gifting
		name = "Gift-Wrapping Bundle"
		desc = "Wrap to impress! Includes wrapping paper and scissors."
		order_items = list(/obj/item/wrapping_paper,/obj/item/scissors)
		cost = PAY_TRADESMAN / 4

	swimsuit
		name = "Swim Suit"
		desc = "One-size-fits-all swimsuit. Comes in a random color."
		order_items = list(/obj/item/clothing/under/swimsuit/random)
		cost = PAY_UNTRAINED / 2

	flippers
		name = "Flippers"
		desc = "Elastic-fit flippers suitable for most foot sizes."
		order_items = list(/obj/item/clothing/shoes/flippers)
		cost = PAY_UNTRAINED

	poolfloats
		name = "Pool Float Set"
		desc = "A great choice for novice swimmers - water wings and our choice of inner tube."
		order_items = list(/obj/item/inner_tube/random,/obj/item/clothing/gloves/water_wings)
		cost = PAY_UNTRAINED / 2

	towel
		name = "Towel"
		desc = "Want to be the hoopiest frood in town? You gotta know where your towel is."
		order_items = list(/obj/item/clothing/under/towel)
		cost = PAY_TRADESMAN / 3

	bball
		name = "Basketball"
		desc = "A regulation basketball, pre-inflated and ready for play."
		order_items = list(/obj/item/basketball)
		cost = PAY_TRADESMAN / 2

	bball_hoops
		name = "Basketball Hoop Set"
		desc = "Two collapsible basketball hoops, ready for installation."
		order_items = list(/obj/item/bballbasket,/obj/item/bballbasket)
		cost = PAY_TRADESMAN

	bball_jersey
		name = "Basketball Jersey"
		desc = "One-size-fits-all jersey. Comes in a random color."
		order_items = list(/obj/item/clothing/under/jersey/random)
		cost = PAY_UNTRAINED / 2

	football
		name = "Football"
		desc = "A regulation football, pre-inflated and ready for play."
		order_items = list(/obj/item/football)
		cost = PAY_TRADESMAN / 2

	bagpipes
		name = "Bagpipes"
		desc = "Genuine handmade bagpipes imported from Space Scotland."
		order_items = list(/obj/item/instrument/bagpipe)
		cost = PAY_DOCTORATE

	guitar
		name = "Guitar"
		desc = "Our signature hand-strung guitar in genuine space wood."
		order_items = list(/obj/item/instrument/guitar)
		cost = PAY_TRADESMAN

	harmonica
		name = "Harmonica"
		desc = "Our cheapest instrument - great for hobby playing."
		order_items = list(/obj/item/instrument/harmonica)
		cost = PAY_TRADESMAN / 4

	saxophone
		name = "Saxophone"
		desc = "The smoothest hunk of brass this side of the galaxy."
		order_items = list(/obj/item/instrument/saxophone)
		cost = PAY_DOCTORATE


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

	oatmeal
		name = "Oatmeal Bowl"
		desc = "Prepared with one of our signature flavors - try them all!"
		order_items = list(/obj/item/reagent_containers/food/snacks/soup/oatmeal)
		cost = PAY_TRADESMAN / 5

	carrot
		name = "Carrot"
		desc = "Jam-packed with nutritious crunch - great for soup or snacking."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/carrot)
		cost = PAY_TRADESMAN / 4

	coconut
		name = "Coconut"
		desc = "Delicious and versatile, bringing you a burst of coco-fun."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/coconut)
		cost = PAY_TRADESMAN / 3

	cucumber
		name = "Cucumber"
		desc = "A delicate vegetable hand-picked for minimum bitterness."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/cucumber)
		cost = PAY_TRADESMAN / 4

	pineapple
		name = "Pineapple"
		desc = "Rich tropical flavor in a spiky package, express-delivered."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/pineapple)
		cost = PAY_TRADESMAN / 3

	pumpkin
		name = "Pumpkin"
		desc = "Shipped whole and intact - perfect for autumnal classics."
		order_items = list(/obj/item/reagent_containers/food/snacks/plant/pumpkin)
		cost = PAY_TRADESMAN / 4

	catnip
		name = "Catnip Sprig"
		desc = "Pure nepeta cataria, perfect for your feline pals."
		order_items = list(/obj/item/plant/herb/catnip)
		cost = PAY_TRADESMAN / 5

	mint
		name = "Mint Sprig"
		desc = "Effervescent mint, carefully preserved for peak flavor."
		order_items = list(/obj/item/plant/herb/mint)
		cost = PAY_TRADESMAN / 5

	sassafras
		name = "Sassafras Root"
		desc = "A classic aromatic, popular in gumbo and brewing."
		order_items = list(/obj/item/plant/herb/sassafras)
		cost = PAY_TRADESMAN / 5

	cereal_pope
		name = "Pope Crunch Cereal"
		desc = "Made with only the highest-quality iron supplements."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box)
		cost = PAY_UNTRAINED / 3

	cereal_wonks
		name = "Honey Wonks Cereal"
		desc = "Your sticky-sweet sugar rush, at a super special price."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/honey)
		cost = PAY_UNTRAINED / 3

	cereal_monki
		name = "Tanh-O-Nys Cereal"
		desc = "Does it taste like banana? Who knows! Buy some and find out."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/tanhony)
		cost = PAY_UNTRAINED / 3

	cereal_roach
		name = "Roach Puffs Cereal"
		desc = "Everybody's favorite chocolate-themed roach-themed treat."
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box/roach)
		cost = PAY_UNTRAINED / 3

	cereal_bundle
		name = "Munch 'Em All Bundle"
		desc = "Can't decide on a cereal? Buy them all and save!"
		order_items = list(/obj/item/reagent_containers/food/snacks/cereal_box,
		/obj/item/reagent_containers/food/snacks/cereal_box/honey,
		/obj/item/reagent_containers/food/snacks/cereal_box/tanhony,
		/obj/item/reagent_containers/food/snacks/cereal_box/roach)
		cost = PAY_UNTRAINED


//Survival Mart: primarily medical, but not exclusively
ABSTRACT_TYPE(/datum/mail_order/survmart)
/datum/mail_order/survmart
/* //alternate non-pressurized tank to be added at later point
	oxytank
		name = "Emergency Oxygen Tank"
		desc = "An easy-to-use compact gas tank pre-loaded with pure oxygen."
		order_items = list(/obj/item/tank/emergency_oxygen)
		cost = PAY_TRADESMAN
*/
	wintercoat
		name = "Winterized Overcoat"
		desc = "Beat the cold of space with your very own cozy coat."
		order_items = list(/obj/item/clothing/suit/wintercoat)
		cost = PAY_TRADESMAN / 2

	cleangear
		name = "Medical Wear Bundle"
		desc = "Contains latex gloves and sterile mask."
		order_items = list(/obj/item/clothing/gloves/latex,/obj/item/clothing/mask/surgical)
		cost = PAY_UNTRAINED / 2

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

	auto_diphen
		name = "Diphenhydramine Auto-Injector"
		desc = "Fast-acting antihistamine commonly used for allergic reactions."
		order_items = list(/obj/item/reagent_containers/emergency_injector/antihistamine)
		cost = PAY_DOCTORATE / 4

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

	auto_saline
		name = "Saline Auto-Injector"
		desc = "Preformulated saline-glucose mixture to stabilize fluid levels."
		order_items = list(/obj/item/reagent_containers/emergency_injector/saline)
		cost = PAY_TRADESMAN / 3

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


//Chems-R-Us: chemicals and chemistry accessories
ABSTRACT_TYPE(/datum/mail_order/chem)
/datum/mail_order/chem

	reagentscanner
		name = "Reagent Scanner"
		desc = "Handheld device capable of real-time reagent analysis."
		order_items = list(/obj/item/device/reagentscanner)
		cost = PAY_DOCTORATE / 3

	spectrogoggles
		name = "Spectroscopic Goggles"
		desc = "The latest in optically-mounted Raman spectroscopy tech."
		order_items = list(/obj/item/clothing/glasses/spectro)
		cost = PAY_IMPORTANT
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
		order_perm = list(access_chemistry,access_janitor,access_medical)

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

	oil
		name = "Oil, 50u Bottle"
		desc = "Lubrication-friendly formulation of hydrocarbon oil."
		order_items = list(/obj/item/reagent_containers/glass/bottle/oil)
		cost = PAY_DOCTORATE / 3
		order_perm = list(access_chemistry,access_engineering,access_medical)

	phenol
		name = "Phenol, 50u Bottle"
		desc = "Acidic reagent prevalent in organic chemistry."
		order_items = list(/obj/item/reagent_containers/glass/bottle/phenol)
		cost = PAY_DOCTORATE / 3
		order_perm = list(access_chemistry,access_medical)
