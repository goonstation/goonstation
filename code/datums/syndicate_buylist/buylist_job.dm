// Categories of jobs that can be put into the list of jobs that can buy the thing. For use when several jobs should be considered the same job
// for the purposes of buylist entries. E.g. All clowns should get clown traitor items in their list
#define ALL_COMMAND "Captain", "Head of Personnel", "Head of Security", "Research Director", "Medical Director", "Chief Engineer"
#define ALL_RESEARCH "Research Director", "Scientist", "Research Trainee"
#define ALL_DOCTORS "Medical Director", "Medical Doctor", "Medical Trainee"
#define ALL_ENGINEERS "Chief Engineer", "Engineer", "Technical Trainee"
#define ALL_CHEFS "Chef", "Sous-Chef"
#define ALL_CLOWNS "Clown", "Blue Clown"

//////////////////////////////////////////////// Job-specific items  ////////////////////////////////////////////////////

/datum/syndicate_buylist/traitor/clowncar
	name = "Clown Car"
	items = list(/obj/vehicle/clowncar/surplus)
	cost = 5
	vr_allowed = FALSE
	desc = "A funny-looking car designed for circus events. Seats 30, very roomy! Can be loaded with banana peels. Comes with an extra set of clown clothes."
	job = list(ALL_CLOWNS)
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/boomboots
	name = "Boom Boots"
	items = list(/obj/item/clothing/shoes/cowboy/boom)
	cost = 12
	vr_allowed = FALSE
	desc = "These big red boots have an explosive step sound. The entire station is sure to want to show you their appreciation."
	job = list(ALL_CLOWNS)
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/clown_mask
	name = "Clown Mask"
	items = list(/obj/item/clothing/mask/gas/syndie_clown)
	cost = 5
	vr_allowed = FALSE
	desc = "A clown mask haunted by the souls of those who honked before. Only true clowns should attempt to wear this. It also functions like a gas mask."
	job = list(ALL_CLOWNS)
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/clown_announcement_computer
	name = "Portable Clown Announcement Computer"
	items = list(/obj/machinery/computer/announcement/clown/foldable)
	cost = 5
	vr_allowed = FALSE
	desc = "A heavily illegal and portable version of the NanoTrasen announcement computer modified to be as annoying as possible. Not lined with explosives."
	job = list(ALL_CLOWNS)
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/fake_revolver
	name = "Funny-looking Revolver"
	items = list(/obj/item/storage/box/fakerevolver)
	cost = 1
	desc = "A revolver with a twist. It will always fire backwards! Watch some vigilante try to get you NOW!"
	job = list(ALL_CLOWNS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/chambomb
	name = "Chameleon Bomb Case"
	items = list(/obj/item/storage/box/chameleonbomb)
	cost = 3
	vr_allowed = FALSE
	desc = "2 questionable mixtures of a chameleon projector and a bomb. Scan an object to take on its appearance, arm the bomb, and then explode the face(s) of whoever tries to touch it."
	br_allowed = TRUE
	job = list(ALL_CLOWNS, "Mail Courier")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/sinjector
	name = "Speed Injector"
	items = list(/obj/item/speed_injector)
	cost = 3
	desc = "Disguised as a screwdriver, this stealthy device can be loaded with dna injectors which will be injected into the target instantly and stealthily. The dna injector will be altered when inserted so that there will be a ten second delay before the gene manifests in the victim."
	job = list("Geneticist")
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

/datum/syndicate_buylist/traitor/minibible
	name = "Miniature Bible"
	items = list(/obj/item/bible/mini)
	cost = 1
	desc = "We understand it can be difficult to carry out some of our missions. Here is some spiritual counsel in a small package."
	job = list("Staff Assistant", "Chaplain", ALL_CLOWNS)
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/contract
	name = "Faustian Bargain Kit"
	items = list(/obj/item/storage/briefcase/satan)
	cost = 8
	desc = "Comes complete with three soul binding contracts, three extra-pointy pens, and one suit provided by Lucifer himself."
	job = list("Chaplain", "Lawyer")
	not_in_crates = TRUE
	vr_allowed = FALSE
	can_buy = UPLINK_TRAITOR | UPLINK_SPY

	run_on_spawn(var/obj/item/storage/briefcase/satan/Q,var/mob/living/owner, in_surplus_crate)
		if (istype(Q) && owner)
			owner.make_merchant() //give them the power to summon more contracts
			Q.set_merchant(owner)
			owner.mind.diabolical = 1 //can't sell souls to ourselves now can we?
		..()

/datum/syndicate_buylist/traitor/mailsuit
	name = "Mail Courier Suit"
	items = list(/obj/item/clothing/under/misc/mail/syndicate)
	cost = 1
	desc = "A mail courier's uniform that allows the wearer to use mail chutes as a means of transportation."
	br_allowed = TRUE
	job = list("Mail Courier")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/chargehacker
	name = "Mining Charge Hacker"
	items = list(/obj/item/device/chargehacker)
	cost = 4
	desc = "A tool designed to hack mining charges so that they will attach to any surface, disguised as a geological scanner."
	not_in_crates = TRUE
	job = list("Miner")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/kudzuseed
	name = "Kudzu Seed"
	items = list(/obj/item/kudzuseed)
	cost = 4
	desc = "Syndikudzu. Interesting. Plant on the floor to grow."
	vr_allowed = FALSE
	job = list("Botanist", "Staff Assistant")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/maneater
	name = "Maneater Seed"
	items = list(/obj/item/seed/maneater)
	cost = 1
	desc = "A boon for the green-thumbed agent! Simply plant and nurture to raise your own faithful guard-plant! Feed me, Seymour!"
	not_in_crates = TRUE
	job = list("Botanist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/saw
	name = "Chainsaw"
	items = list(/obj/item/saw/syndie)
	cost = 7
	desc = "This old earth beauty is made by hand with strict attention to detail. Unlike today's competing botanical chainsaw, it actually cuts things!"
	not_in_crates = TRUE
	job = list("Botanist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/hotbox_lighter
	name = "Hotbox Lighter"
	items = list(/obj/item/device/light/zippo/syndicate)
	cost = 1
	desc = "The unique fuel mixture both burns five times hotter than a normal flame and produces a much thicker smoke than normal when burning herbs!"
	job = list("Botanist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/waspgrenade
	name = "Wasp Grenades"
	items = list(/obj/item/storage/wasp_grenade_pouch)
	cost = 3
	desc = "These wasp grenades contain genetically modified extra double large hornets that will surely inspire awe in all your non-botanical friends."
	vr_allowed = FALSE
	job = list("Botanist", "Apiculturist")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

	run_on_spawn(obj/item/our_item, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/implanter/wasp(our_item.loc)
			return
		..()

/datum/syndicate_buylist/traitor/wasp_crossbow
	name = "Wasp Crossbow"
	items = list(/obj/item/gun/energy/wasp)
	cost = 6
	desc = "Become the member of the Space Cobra Unit you always wanted to be! Spread pain and fear far and wide using this scattershot wasp egg launcher! Through the power of sheer wasp-y fury, this crossbow will slowly recharge between shots and is guaranteed to light up your day with maniacal joy and to bring your enemies no end of sorrow."
	vr_allowed = FALSE
	job = list("Botanist", "Apiculturist")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(obj/item/our_item, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/implanter/wasp(our_item.loc)
			return
		..()

/datum/syndicate_buylist/traitor/fakegrenade
	name = "Fake Cleaner Grenades"
	items = list(/obj/item/storage/box/f_grenade_kit)
	cost = 2
	desc = "This cleaning grenade features over 500% of the legal level of active agent. Cleans dirt off of floors and flesh off of bone! Also contains space lube to create a dazzling shine!"
	br_allowed = TRUE
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/compactor
	name = "Trash Compactor Cart"
	items = list(/obj/storage/cart/trash/syndicate)
	cost = 4
	desc = "Identical in appearance to an ordinary trash cart, this beauty is capable of compacting (1) laying person placed inside at a time. It was originally supposed to only compact nonliving things, but a serendipitous design mistake resulted in 1500 units with a reversed safety unit."
	not_in_crates = TRUE
	vr_allowed = FALSE
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/storage/cart/trash/syndicate/cart,var/mob/living/owner)
		if (owner)
			cart.owner_ckey = owner.ckey
		..()

/datum/syndicate_buylist/traitor/slip_and_sign
	name = "Slip and Sign"
	items = list(/obj/item/caution/traitor)
	cost = 2
	desc = "This Wet Floor Sign spits out organic superlubricant under everyone nearby unless they are wearing galoshes. That'll teach them to ignore the signs. If you are wearing the long janitor gloves you can click with a bucket (or beaker or drinking glass etc.) to replace the payload."
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY | UPLINK_HEAD_REV

	run_on_spawn(obj/item/caution/traitor/sign, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/clothing/shoes/galoshes(sign.loc)
			new /obj/item/clothing/gloves/long(sign.loc)
			return
		..()

/datum/syndicate_buylist/traitor/overcharged_vacuum
	name = "Overcharged Vacuum Cleaner"
	items = list(/obj/item/handheld_vacuum/overcharged)
	cost = 5
	desc = "This vacuum cleaner's special attack is way more powerful than the regular thing."
	br_allowed = TRUE
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF | UPLINK_SPY | UPLINK_HEAD_REV

/datum/syndicate_buylist/traitor/syndanalyser
	name = "Syndicate Device Analyzer"
	items = list(/obj/item/electronics/scanner/syndicate)
	cost = 4
	vr_allowed = FALSE
	desc = "A standard Nanotrasen mechanic's analyzer with jailbroken internals. This baby doesn't give a damn about DRM, patents, or \"safety\"!"
	job = list(ALL_ENGINEERS)
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/stimulants
	name = "Stimulants"
	items = list(/obj/item/storage/box/stimulants)
	cost = 6
	desc = "When top agents need energy, they turn to our new line of X-Cite 500 stimulants. This 3-pack of all-natural* and worry-free** blend accelerates perception, endurance, and reaction time to superhuman levels! Shrug off even the cruelest of blows without a scratch! <br><br><font size=-1>*Contains less than 0.5 grams unnatural material per 0.49 gram serving.<br>**May cause dizziness, blurred vision, heart failure, renal compaction, adenoid calcification, or death. Users are recommended to take only a single dose at a time, and let withdrawal symptoms play out naturally.</font>"
	job = list(ALL_DOCTORS, ALL_RESEARCH, "Geneticist", "Pathologist")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/syringegun
	name = "Syringe Gun"
	items = list(/obj/item/gun/reagent/syringe)
	cost = 3
	desc = "This stainless-steel, revolving wonder fires needles. Perfect for today's safari-loving Syndicate doctor! Loaded by transferring reagents to the gun's internal reservoir."
	job = list(ALL_DOCTORS, ALL_RESEARCH, "Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/powergloves
	name = "Power Gloves"
	items = list(/obj/item/clothing/gloves/powergloves)
	cost = 6
	desc = "These marvels of modern technology employ nanites and space science to draw energy from nearby cables to zap things. BZZZZT!"
	not_in_crates = TRUE
	job = list(ALL_ENGINEERS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/zappy_implant
	name = "Flyzapper Implant"
	items = list(/obj/item/implanter/zappy)
	cost = 1
	desc = "This implant turns you into a living (or dying) generator, zapping those around you with a volume of electricity that scales with the number of implants upon your demise."
	job = list(ALL_ENGINEERS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/poisonbottle
	name = "Poison Bottle"
	items = list(/obj/item/reagent_containers/glass/bottle/poison)
	cost = 1
	vr_allowed = FALSE //rat poison
	desc = "A bottle of poison. Which poison? Who knows."
	job = list(ALL_DOCTORS, ALL_RESEARCH, "Bartender", ALL_CHEFS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/poisonbundle
	name = "Poison Bottle Bundle"
	items = list(/obj/item/storage/box/poison)
	cost = 7
	vr_allowed = FALSE //rat poison
	desc = "A box filled with seven random poison bottles."
	job = list(ALL_DOCTORS, ALL_RESEARCH, "Bartender", ALL_CHEFS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/chemicompiler
	name = "Chemicompiler"
	items = list(/obj/item/device/chemicompiler)
	cost = 5
	not_in_crates = TRUE
	desc = "A handheld version of the Chemicompiler machine in Chemistry."
	job = list(ALL_RESEARCH)
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/robosuit
	name = "Syndicate Robot Frame"
	items = list(/obj/item/parts/robot_parts/robot_frame/syndicate)
	cost = 2
	desc = "A cyborg shell crafted from the finest recycled steel and reverse-engineered microelectronics. A cyborg crafted from this will see only Syndicate operatives (Such as yourself!) as human. Cyborg also comes preloaded with popular game \"Angry About the Bird\" and is compatible with most headphones."
	not_in_crates = TRUE
	vr_allowed = FALSE
	job = list("Roboticist")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/conversion_chamber
	name = "Conversion Chamber"
	items = list(/obj/machinery/recharge_station/syndicate, /obj/item/wrench) // clarify that we need to wrench it down before use
	cost = 8
	vr_allowed = FALSE
	desc = "A modified standard-issue cyborg recharging station that will automatically convert any human placed inside into a cyborg. Cyborgs created this way will follow a syndicate lawset making them loyal to you."
	job = list("Roboticist")
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/safari
	name = "Safari Kit"
	items = list(/obj/item/storage/box/costume/safari)
	cost = 7
	desc = "Almost everything you need to hunt the most dangerous game. Tranquilizer rifle not included."
	br_allowed = TRUE
	job = list("Medical Director")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(obj/item, mob/living/owner, in_surplus_crate)
		if(in_surplus_crate)
			new /obj/item/gun/kinetic/dart_rifle(item.loc)
			new /obj/item/ammo/bullets/tranq_darts(item.loc)
			return
		..()

/datum/syndicate_buylist/traitor/pizza_sharpener
	name = "Pizza Sharpener"
	items = list(/obj/item/kitchen/utensil/knife/pizza_cutter/traitor)
	cost = 5
	desc = "Have you ever been making a pizza and thought \"this pizza would be better if I could fatally injure someone by throwing it at them\"? Well think no longer! Because you're sharpening pizzas now. You weirdo."
	br_allowed = TRUE
	job = list(ALL_CHEFS)

/datum/syndicate_buylist/traitor/syndiesauce
	name = "Syndicate Sauce"
	items = list(/obj/item/reagent_containers/food/snacks/condiment/syndisauce)
	cost = 1
	desc = "Our patented secret blend of herbs and spices! Guaranteed to knock even the harshest food critic right off their feet! And into the grave. Because this is poison."
	job = list(ALL_CHEFS, "Bartender")

/datum/syndicate_buylist/traitor/donkpockets
	name = "Syndicate Donk Pockets"
	items = list(/obj/item/storage/box/donkpocket_w_kit)
	cost = 2
	desc = "Ready to eat, no microwave required! The pocket-sandwich station personnel crave, now with added medical agents to heal you up in a pinch! Zero grams trans-fat per serving*!<br><br><font size=1>*Made with partially-hydrogenated wizard blood.</font>"
	job = list(ALL_CHEFS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/butcherknife
	name = "Butcher's Knife"
	items = list(/obj/item/knife/butcher)
	cost = 7
	desc = "An extremely sharp knife with a weighted handle for accurate throwing. Caution: May cause extreme bleeding if the cutting edge comes into contact with human flesh."
	not_in_crates = TRUE
	job = list(ALL_CHEFS)
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/hotdog_cart
	name = "Syndicate Hot Dog Cart"
	items = list(/obj/storage/cart/hotdog/syndicate)
	cost = 4
	desc = "A sinister hotdog cart which traps people inside and squishes them into, you guessed it, hot dogs."
	not_in_crates = TRUE
	vr_allowed = FALSE //i don't know why this is here but it's on the trash compactor cart so w/e
	job = list(ALL_CHEFS, "Waiter")
	can_buy = UPLINK_TRAITOR

	run_on_spawn(var/obj/storage/cart/hotdog/syndicate/cart, var/mob/living/owner)
		if (owner)
			cart.owner_ckey = owner.ckey
		..()

/datum/syndicate_buylist/traitor/moonshine
	name = "Jug of Moonshine"
	items = list(/obj/item/reagent_containers/food/drinks/moonshine)
	cost = 2
	desc = "A jug full of incredibly potent alcohol. Not recommended for human consumption."
	job = list("Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/shotglass
	name = "Extra Large Shot Glasses"
	items = list(/obj/item/storage/box/glassbox/syndie)
	cost = 2
	desc = "A box of shot glasses that hold WAAAY more that normal. Cheat at drinking games! Those glasses also force humans they are thrown at to take a partial sip before the glass shatters!"
	job = list("Bartender")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/vuvuzelagun
	name = "Vuvuzela Gun"
	items = list(/obj/item/gun/energy/vuvuzela_gun)
	cost = 3
	desc = "<b>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ</b>"
	job = list("Staff Assistant", ALL_CLOWNS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/moustache_grenade
	name = "Moustache Grenade"
	items = list(/obj/item/old_grenade/moustache)
	cost = 1
	desc = "A disturbingly hairy grenade."
	job = list("Staff Assistant", ALL_CLOWNS)

/datum/syndicate_buylist/traitor/hotdog_bomb
	name = "Hotdog Bomb"
	items = list(/obj/item/gimmickbomb/hotdog)
	cost = 1
	desc = "Turn your worst enemies into hotdogs."
	br_allowed = TRUE
	job = list(ALL_CHEFS, "Waiter", ALL_CLOWNS)

/datum/syndicate_buylist/traitor/chemgrenades
	name = "Chem Grenade Starter Pouch"
	items = list(/obj/item/storage/custom_chem_grenade_pouch)
	cost = 2
	desc = "Tired of destroying your own face with acid reactions? Want to make the janitor feel incompetent? This pouch gets you started with five grenades. Just add beakers and screw!"
	job = list(ALL_RESEARCH)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/traitorthermalscanner
	name = "Advanced Optical Thermal Scanner"
	items = list(/obj/item/clothing/glasses/thermal/traitor)
	cost = 3
	desc = "An advanced optical thermal scanner capable of seeing living entities through walls and smoke."
	br_allowed = TRUE
	job = list("Detective")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/cargo_transporter
	name = "Syndicate Cargo Transporter"
	items = list(/obj/item/cargotele/traitor)
	cost = 3
	vr_allowed = FALSE
	desc = "A modified cargo transporter which welds containers shut and sells their contents directly to the black market, swipe your ID to set the account. Any hapless crewmembers sold will be teleported to a random point in space and will reward cash bonuses based on their job."
	job = list("Quartermaster", "Miner", ALL_ENGINEERS)
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/telegun
	name = "Teleport Gun"
	items = list(/obj/item/gun/energy/teleport)
	cost = 7
	vr_allowed = FALSE
	desc = "An experimental hybrid between a hand teleporter and a directed-energy weapon. Probably a very bad idea. Note -- Only works in conjunction with a stationary teleporter."
	job = list("Research Director")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/portapuke
	name = "Port-a-Puke"
	items = list(/obj/machinery/portapuke)
	cost = 7
	not_in_crates = TRUE
	desc = "An experimental torture chamber that will make any human placed inside puke until they die!"
	job = list("Janitor")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/monkey_barrel
	name = "Barrel-O-Monkeys"
	items = list(/obj/monkey_barrel)
	cost = 6
	vr_allowed = FALSE
	desc = "A barrel of bloodthirsty apes. Careful!"
	job = list("Staff Assistant","Test Subject","Geneticist","Pathologist")

/datum/syndicate_buylist/traitor/mindhack_module
	name = "Mindhack Cloning Module"
	items = list(/obj/item/cloneModule/mindhack_module)
	cost = 6
	vr_allowed = FALSE
	desc = "An add on to the genetics cloning pod that make anyone cloned loyal to whoever installed it. Disclaimer: the appearance of the altered cloning pod may cause alarm and probing questions from those who are not yet loyal."
	job = list("Geneticist", ALL_DOCTORS)

/datum/syndicate_buylist/traitor/deluxe_mindhack_module
	name = "Deluxe Mindhack Cloning Module Kit"
	items = list(/obj/item/storage/box/mindhack_module_kit)
	cost = 10 //  Always leave them 1tc so they can buy the moustache. Style is key.
	vr_allowed = FALSE
	desc = "A Deluxe Mindhack Cloning Kit. Contains a mindhack cloning module and a cloning lab in a box!"
	job = list("Geneticist", ALL_DOCTORS)

/datum/syndicate_buylist/traitor/buddy_ammofab
	name = "Guardbuddy Ammo Replicator"
	items = list(/obj/item/device/guardbot_module/ammofab)
	cost = 1
	vr_allowed = FALSE
	desc = "A device that allows PR-6S Guardbuddy units to use their internal charge to replenish kinetic ammunition."
	job = list("Research Director")

/datum/syndicate_buylist/traitor/scuttlebot
	name = "Controlled Syndicate Scuttlebot"
	items = list(/obj/item/clothing/head/det_hat/folded_scuttlebot)
	cost = 4
	vr_allowed = FALSE
	desc = "A sneaky robot armed with a camera disguised as a hat, used to spy on people. Comes with it's own remote controlling glasses. Can lift small items and has a disabling flash."
	job = list("Detective")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

/datum/syndicate_buylist/traitor/rose
	name = "Poison rose"
	items = list(/obj/item/clothing/head/flower/rose/poisoned)
	cost = 4
	desc = "A regular looking rose hiding a poison capable of muting and briefly incapacitating anyone who smells it."
	job = list("Mime")

/datum/syndicate_buylist/traitor/record_player
	name = "Portable Record player"
	items = list(/obj/submachine/record_player/portable)
	cost = 2
	vr_allowed = FALSE
	not_in_crates = TRUE
	desc = "A portable record player, so you can play tunes while committing crimes!"
	job = list("Radio Show Host")
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/chicken_grenade
	name = "Chicken Grenade"
	items = list(/obj/item/old_grenade/chicken)
	cost = 1
	vr_allowed = FALSE
	desc = "A grenade that holds up to 5 chicken eggs. Uses syndicate brainwashing to turn the chickens into hardened warriors immediately on detonation. Normally passive chickens will become aggressive. Use a wrench to unload it."
	job = list("Rancher")
	not_in_crates = TRUE
	can_buy = UPLINK_TRAITOR
	max_buy = 3

/datum/syndicate_buylist/traitor/fishing_rod
	name = "Barbed Fishing Rod"
	items = list(/obj/item/syndie_fishing_rod)
	cost = 6
	desc = "A tactical fishing rod designed to reel in and filet the biggest catch- enemies of the Syndicate. Bait the hologram lure by hitting it with an item, then maim foes with a barbed hook that causes more damage the longer they fight back."
	job = list("Rancher", "Angler")
	can_buy = UPLINK_TRAITOR
	br_allowed = TRUE

/datum/syndicate_buylist/traitor/ai_laser
	name = "AI Camera Laser Module"
	items = list(/obj/item/aiModule/ability_expansion/laser)
	cost = 6
	vr_allowed = FALSE
	not_in_crates = TRUE
	desc = "An AI module that upgrades any AI connected to the installed law rack access to the lasers installed in the cameras."
	job = list(ALL_COMMAND)
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/megaphone
	name = "Black Market Megaphone"
	desc = "An illegal megaphone with the limiter taken off, and a loudener added. Not for the subtle."
	items = list(/obj/item/megaphone/syndicate)
	cost = 5
	vr_allowed = FALSE // no
	not_in_crates = TRUE
	job = list("Captain", "VIP", "Inspector", "Head of Personnel")

/datum/syndicate_buylist/traitor/ai_disguised_module
	name = "Disguised AI Law Module"
	items = list(/obj/item/aiModule/freeform/disguised)
	cost = 2
	vr_allowed = FALSE
	not_in_crates = TRUE
	desc = "An AI law module that at a glance looks completely normal, but could tell the AI to do anything."
	job = list(ALL_COMMAND)
	can_buy = UPLINK_TRAITOR

/datum/syndicate_buylist/traitor/barberang
	name = "Barberang"
	items = list(/obj/item/razor_blade/barberang)
	cost = 5
	desc = "An aerodynamic, extra-sharp hand razor designed to be thrown, knocking down and shearing the hair off of anyone it hits. The razor will then return, allowing for stolen hair to be easily retrieved. Notice: hitting a bald target will disrupt the razor's aerodynamic properties and void the warranty."
	job = list("Barber")
	can_buy = UPLINK_TRAITOR | UPLINK_SPY_THIEF

#undef ALL_COMMAND
#undef ALL_RESEARCH
#undef ALL_DOCTORS
#undef ALL_ENGINEERS
#undef ALL_CHEFS
#undef ALL_CLOWNS
