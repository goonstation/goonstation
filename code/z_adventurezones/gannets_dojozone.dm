/**
Gannets Space Dojo Zone
Contents:
	Areas:
		Sakura Trees
		Main Dojo
	Mobs:
		Ronin
	Objs:
		Dojo Hmamer
		Unfinished Katana Decal & Sword
		Torii Gate
		Sakura Trees
		Kanji Symbols
		Dojo House
		Lotus Flowers
		Birdhouse Shrines
		Plant Pots
		Stone Lamps
		Railing & Walls
		Furnace
		Anvil & Bellows
		Sword Rack
		Fake Katana
		Lanterns
		Hibachi & Teapot
		Wall Scrolls
		Books:
			Sword Scroll
			5 Lore Scrolls
			Uguu Scroll
	Turfs:
		Sengoku Walls
		False & Tall Sengoku Walls
		Paper Walls
		Tatami Floor
		Water Floors
		Bridge Floors
		Stone Stairs
		Sand Floors
**/

/*
* ('u']])> Welcome to Gannets' Space Dojo! <[['u')
* There's a whole buncha new items and sprites in here for this little adventure zone.
* I'm keeping them all together in this file for now,
* but I'll note which existing files they map to.
*/

/*
* TO-DO:
* Make a song that isn't ripping off aphex twin so hard.
* Add dojoambi to sound cache.
* blacksmith hammer has no inhands
* special sword with mbc item special attack
* npc guy still gets a random name, bluh. Switch out for armor?
*/

/*
* LIST OF NEW + CHANGED FILES:
* gannets_dojozone.dm (you're here!!)
* sengoku.dmm (can be removed when added to z2)
* 160x128.dmi
* 96x96.dmi
* 32x64.dmi
* walls_sengoku.dmi
* walls_paper.dmi
* icons/turf/dojo.dmi <-- floor icons
* icons/obj/dojo.dmi <-- object icons
* radiotelescope.dm
* browserassets/images/radioTelescope
* icons/effects/224x160.dmi
* weapons.dmi
* hand_weapons.dmi
* sound/ambience/dojo/dojoambi.ogg (in new dojo folder)
*/

// Areas

/area/dojo/sakura
	name = "sakura"
	icon_state = "red"
	filler_turf = "/turf/unsimulated/dirt"
	sound_environment = 15
	skip_sims = 1
	sims_score = 0

	New()
		..()

		overlays += image(icon = 'icons/obj/dojo.dmi', icon_state = "sakura_overlay", layer = EFFECTS_LAYER_BASE)

/area/dojo
	name = "dojo"
	icon_state = "blue"
	filler_turf = "/turf/unsimulated/dirt"
	sound_environment = 21
	skip_sims = 1
	sims_score = 15
	sound_group = "dojo"
	sound_loop = 'sound/ambience/dojo/dojoambi.ogg'
	sound_loop_vol = 50

/area/dojo/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/dojo/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/dojo/area_process()
	if(prob(15)) // originally 12-22s
		src.sound_fx_2 = pick('sound/ambience/nature/Biodome_Birds1.ogg',\
			'sound/ambience/nature/Biodome_Birds2.ogg',\
			'sound/ambience/nature/Biodome_Bugs.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 30)

// Mobs

/mob/living/carbon/human/npc/samurai
	name = "Ronin"
	real_name = "Ronin"
	ai_aggressive = 1
	unobservable = 1

	New()
		..()
		SPAWN(0)
			JobEquipSpawned("Samurai")
			return

/datum/job/special/samurai
	name = "Samurai"
	limit = 0
	wages = 0
//	slot_belt = /obj/item/swords_sheaths/katana
	slot_jump = list(/obj/item/clothing/under/gimmick/hakama/random)
	slot_head = list(/obj/item/clothing/head/bandana/random_color)
	slot_foot = list(/obj/item/clothing/shoes/sandal/wizard)
	slot_rhan = null
	slot_lhan = list(/obj/item/dojohammer)
	slot_belt = list(/obj/item/swords_sheaths/katana/reverse)
	slot_back = list(/obj/item/storage/backpack/randoseru)
	slot_card = null
	slot_ears = null

	special_setup(mob/M, no_special_spawn)
		. = ..()


// Objects

/obj/item/dojohammer
	name = "blacksmithing hammer"
	desc = "An unusal looking hammer with an extended head used for pounding sword blades."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "dojo_hammer"
	item_state = "dojo_hammer"
	hit_type = DAMAGE_BLUNT
	force = 8
	throwforce = 5
	stamina_damage = 24
	stamina_cost = 45
	stamina_crit_chance = 10

/obj/decal/fakeobjects/unfinished_katana

/obj/item/unfinished_katana
	name = "unfinished blade"
	desc = "A blade that still requires some work before it'll be an effective weapon."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "katana_un"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rods"

	force = 8
	throwforce = 12
	throw_speed = 5
	throw_range = 10
	stamina_damage = 20
	stamina_cost = 16
	stamina_crit_chance = 25

	var/strikes = 0
	var/temperature = T20C
	var/strikes_to_complete = 400

	New()
		..()

	attackby(obj/item/H, mob/user)
		if (istype(H, /obj/item/dojohammer))
			var/obj/table/anvil/A = locate() in get_turf(src)
			if(A)
				actions.start(new/datum/action/bar/icon/forge_katana(user, H, src, A), user)

	proc/can_forge()
		. = src.temperature >= (500 + T0C)

	// black body radiation color temperature
	proc/set_real_color()
		var/input = temperature / 100

		var/red
		if (input <= 66)
			red = 255
		else
			red = input - 60
			red = 329.698727446 * (red ** -0.1332047592)
		red = clamp(red, 0, 255)

		var/green
		if (input <= 66)
			green = max(0.001, input)
			green = 99.4708025861 * log(green) - 161.1195681661
		else
			green = input - 60
			green = 288.1221695283 * (green ** -0.0755148492)
		green = clamp(green, 0, 255)

		var/blue
		if (input >= 66)
			blue = 255
		else
			if (input <= 19)
				blue = 0
			else
				blue = input - 10
				blue = 138.5177312231 * log(blue) - 305.0447927307
		blue = clamp(blue, 0, 255)

		color = rgb(red, green, blue)

	afterattack(var/atom/target, var/mob/user)
		var/obj/item/reagent_containers/RC = target
		var/can_quench = istype(RC) && RC.is_open_container()  && RC.reagents.total_volume >= 120
		if(!QDELETED(src) && can_quench && (src.strikes > (src.strikes_to_complete * 0.25)) && (src.temperature > T0C+1000))
			if( src.strikes > src.strikes_to_complete )
				if(RC.reagents.has_reagent("reversium",1))
					new /obj/item/swords/katana/reverse(get_turf(target))
				else
					new /obj/item/swords/katana/crafted(get_turf(target))
				RC.reagents.smoke_start(RC.reagents.total_volume)
				user.u_equip(src)
				qdel(src)
			else
				RC.reagents.smoke_start(RC.reagents.total_volume)
				var/obj/item/swords/fragile_sword/sword = new(get_turf(target))

				// scale sword based on % complete
				sword.maximum_force = max(30 * (src.strikes / src.strikes_to_complete),10)
				sword.force = sword.maximum_force
				sword.throwforce = 10
				user.u_equip(src)
				qdel(src)


/datum/action/bar/icon/forge_katana
	duration = 1.5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION
	id = "forge_katana"

	var/mob/living/user
	var/obj/item/dojohammer/H
	var/obj/item/unfinished_katana/target
	var/obj/table/anvil/A
	var/looped = 0
	var/flashing = FALSE
	var/outline

	New(usermob, tool, targetmob, anvil, loopcount = 0)
		user = usermob
		H = tool
		target = targetmob
		A = anvil
		looped = loopcount
		icon = target.icon
		icon_state = target.icon_state
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(user, target) > 0 || GET_DIST(A, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		target.temperature -= 5
		target.set_real_color()
		icon_image.color =  target.color
		if(outline)
			outline:color = target.color
		border.UpdateOverlays(icon_image, "action_icon")
		if(!target.can_forge())
			interrupt(INTERRUPT_ALWAYS)
			boutput(user,"[target] has cooled to a point where it can no longer be forged by [H].")
			src.resumable = FALSE
			return

		if(target.strikes > target.strikes_to_complete)
			if(prob(2))
				boutput(user,"[target] appears ready to be quenched.")

	onStart()
		..()
		if(!target.can_forge())
			interrupt(INTERRUPT_ALWAYS)
			boutput(user,"[target] is too cold to be forged.")
			src.resumable = FALSE
			return
		target.set_real_color()
		if(!outline && length(icon_image.filters))
			outline = icon_image.filters[length(icon_image.filters)]
			outline:color = target.color
		icon_image.color =  target.color
		border.UpdateOverlays(icon_image, "action_icon")
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()
		return

	onEnd()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null || !user.find_in_hand(H))
			..()
			interrupt(INTERRUPT_ALWAYS)
			return
		playsound(target,'sound/impact_sounds/Metal_Clang_3.ogg', 60, pitch=1-(rand()*0.2))

		if(target.can_forge())
			target.strikes++
			looped++

		src.onRestart()


// -Decoration

/obj/decal/fakeobjects/arch
	name = "torii"
	desc = "A great gate marking sacred grounds."
	icon = 'icons/obj/large/160x128.dmi'
	icon_state = "arch"

/obj/tree/sakura_tree
	name = "cherry tree"
	desc = "A pretty japanese cherry tree. You don't find a lot of these away from earth."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "sakuratree"

/obj/tree/sakura_tree/tree_2
	icon_state = "sakuratree2"

/*
* Kanji notes via Keelin:
* Apparently the first symbol means fat. The second means penis in chinese.
* Together they are Taiyo, meaning sun, hopefully. Which is really what we were aiming for here.
* Rather than fat penis.
* It's a pretty horrible mistranslation, so I'm 100% keeping it.
*/

/obj/decal/fakeobjects/kanji_1
	plane = PLANE_FLOOR
	name = "symbol"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "kanji_1"
	anchored = ANCHORED_ALWAYS

/obj/decal/fakeobjects/kanji_2
	plane = PLANE_FLOOR
	name = "symbol"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "kanji_2"
	anchored = ANCHORED_ALWAYS

/obj/decal/fakeobjects/dojohouse
	icon = 'icons/effects/224x160.dmi'
	icon_state = "dojohouse"

/obj/decal/fakeobjects/lotus
	name = "lotus"
	desc = "A pretty water garden flower."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "lotus_1"

/obj/decal/fakeobjects/birdhouse // i literally cannot find the correct name for this.
	name = "small shrine"
	density = 1
	anchored = ANCHORED
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/obj/dojo.dmi'
	icon_state = "birdhouse"

	light
	desc = "It's been lit."

	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(0.7)
		light.set_color(1, 0.6, 0)
		light.set_height(0.75)
		light.attach(src)
		light.enable()

/obj/decal/fakeobjects/plantpot
	name = "plant pot"
	density = 1
	anchored = ANCHORED
	opacity = 0
	layer = EFFECTS_LAYER_UNDER_3
	icon = 'icons/obj/dojo.dmi'
	icon_state = "plantpot"

/obj/decal/stone_lamp
	name = "toro"
	desc = "A stone lamp. It doesn't appear to be lit."
	density = 1
	anchored = ANCHORED
	opacity = 0
	layer = 5
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "lamp1"

/obj/decal/fakeobjects/bridge_rail
	name = "railing"
	icon = 'icons/obj/dojo_rail.dmi'
	layer = EFFECTS_LAYER_BASE

/obj/decal/stage_edge/dojo
	name = "stone wall"
	icon = 'icons/obj/dojo.dmi'
	icon_state = "stone_edge"

/obj/machinery/dojo_tatara
	name = "tatara"
	desc = "A large, traditional, swordsmithing furnace. It is lit and the flame is roaring."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "furnace"
	density = 1
	anchored = ANCHORED_ALWAYS
	var/obj/effects/tatara/effect

	var/temperature = T0C + 870

	New()
		..()
		effect = new /obj/effects/tatara(src)
		vis_contents += effect

	attackby(obj/item/W, mob/user as mob)
		if(istype(W, /obj/item/unfinished_katana) || istype(W, /obj/item/rods))
			user.u_equip(W)
			W.set_loc(src)
			src.visible_message("[user] places [W] in \the [src].")

	attack_hand(mob/user)
		. = ..()
		if(length(src.contents))
			var/obj/item/unfinished_katana/K
			K = pick(src.contents)
			if(istype(K))
				K.set_real_color()
			user.put_in_hand_or_eject(K)

	process(mult)
		for(var/obj/O in contents)
			if(istype(O,/obj/item/unfinished_katana))
				var/obj/item/unfinished_katana/K = O
				K.temperature = lerp(K.temperature, src.temperature, 0.3)
				if(K.temperature >= src.temperature * 0.9)
					effect.spark_up()
			if(istype(O,/obj/item/rods))
				var/obj/item/rods/R = O
				if(prob(1*mult))
					if((R.material?.material_flags & MATERIAL_METAL) && R.material.getProperty("density") >= 3 && R.material.getProperty("hard") >= 2)
						if (R.amount > 1)
							R.change_stack_amount(-1)
						else
							qdel(O)
						new /obj/item/unfinished_katana(src)
						effect.spark_up()

		temperature = max(src.temperature-25, initial(src.temperature))

/obj/table/anvil
	name = "anvil"
	desc = "A mighty iron anvil. It appears well worn."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "anvil"
	density = 1
	anchored = ANCHORED_ALWAYS
	parts_type = null
	hulk_immune = TRUE

	attackby(obj/item/W, mob/user, params)
		if (istype(W) && src.place_on(W, user, params))
			return
		else
			return ..()

/obj/dojo_bellows
	name = "bellows"
	desc = "An old bellows. Used to keep a flame alight."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "bellows"
	density = 1
	anchored = ANCHORED_ALWAYS

	attack_hand(mob/user)
		. = ..()
		if(ON_COOLDOWN(src,"bellows", 2 SECOND))
			boutput(user,"The bellows are still working...")
		else
			playsound(src, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40)
			for(var/obj/machinery/dojo_tatara/T in orange(2))
				src.visible_message("\The [src] breathe life into \the [T] causing it errupt in flames.", blind_message="A loud roar of air causes a fire to errupt.")
				T.temperature = clamp(T.temperature + 150, initial(T.temperature)-150, T0C+2500)

/obj/decal/fakeobjects/swordrack
	name = "katana rack"
	desc = "A wooden rack of swords."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "sword_wall_rack"
	density = 1
	anchored = ANCHORED_ALWAYS

/obj/decal/fakeobjects/rake
	name = "zen garden rake"
	desc = "A little wooden tool for raking sand in to patterns."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "rake"

/obj/decal/fakeobjects/sealed_door
	name = "laboratory door"
	desc = "It appears to be sealed."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "sealed_door"
	density = 1
	anchored = ANCHORED_ALWAYS
	opacity = 1

/obj/decal/fakeobjects/katana_fake
	name = "katana sheath"
	desc = "It can clean a bloodied katana, and also allows for easier storage of a katana"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "katana_sheathed"

/obj/lantern // bad copypaste code from candle_light
	icon = 'icons/obj/dojo.dmi'
	icon_state = "lantern"
	name = "paper lantern"
	desc = "A brightly lit paper lantern."
	density = 0
	anchored = ANCHORED_ALWAYS
	opacity = 0

	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(0.7)
		light.set_color(1, 0.6, 0)
		light.set_height(0.75)
		light.attach(src)
		light.enable()

	white // lantern that emulates station lighting. Don't think about it too hard.

		var/datum/light/point/light2

		New()
			..()
			light = new
			light.set_brightness(1.6)
			light.set_color(0.95, 0.95, 1)
			light.set_height(2.4)
			light.radius = 7
			light.attach(src)
			light.enable()

/obj/table/hibachi // is there a better way to make it so you put items on an item when you click it? I bet.
	icon = 'icons/obj/dojo.dmi'
	icon_state = "hibachi"
	name = "hibachi"
	desc = "A small, wooden hibachi heater for boiling tea."

/obj/item/reagent_containers/food/drinks/teapot
	name = "tetsubin"
	desc = "A metal tetsubin teapot, for brewing multiple servings of tea."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "tetsubin"
	item_state = "tetsubin"
	rc_flags = RC_SPECTRO

/obj/decal/wallscroll
 name = "wall scroll"
 desc = "A hanging paper wall scroll."
 icon = 'icons/obj/dojo.dmi'
 icon_state = "wallscroll_1"

	scroll2
		icon_state = "wallscroll_2"

	scroll3
		icon_state = "wallscroll_3"

	scrollfancy
		icon_state = "wallscroll_fancy"

//-Books

/obj/item/paper/book/scroll_sword
	name = "sealed scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"<p>"A SWORD IS A SYMBOL AND USELESS OTHERWISE.<br>
	A spear? That has use. An axe? That has use. The mace? Plenty of use against armoured foes.<br>
	The Sword? Too short, cannot penetrate proper armour, only useful against those wearing cloth.<br>
	The sword is a tool to kill the defenseless - it serves no other purpose.<br>
	That the light should honour it so is fitting in this regard."</p>"}

/obj/item/paper/book/scroll_1
	name = "scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"<p>My work begins, I don't know for how long I am to be left here in solitude,<br>
	but my keepers have built me a gilded cage of my designs.<br>
	I cannot help but revel in its beauty, its accuracy</p>"}

/obj/item/paper/book/scroll_2
	name = "scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"<p>The company which hosts me have promised me great fortune in exchange for me returning to this work.<br>
	I am loathed to capitulate to such men, for I know their designs and they intend to use me to do great harm.</p>"}

/obj/item/paper/book/scroll_3
	name = "scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"<p>A smith such as myself knows intimately the shape and character of a blade, this is what they value of me.<br>
	I am to construct a new weapon, sharper than any alloy before, light enough for any warrior to wield, deadly enough to be effective without a lifetime of study in swordfighting.<br>
	I do not know the form it will take.</p>"}

/obj/item/paper/book/scroll_4
	name = "scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"<p>My captors interupt my work once again, no blade I present to them will suffice.<br>
	I commit my soul and spirit to the forging and tempering of this steel, but it is not keen enough.<br>
	They tell me they will bring me a greater medium to work in, with unlimited potential.</p>"}

/obj/item/paper/book/scroll_5
	name = "scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"<p>I cannot continue. From my adopted home my hosts have driven me deep underground, surrounded by noise and sparks, to apply my craft to new technology and scientific  method.<br>
	The blade we have forged together is unlike any before it, hidden from sight but drawn in an instant, near weightless but brutishly powerful, it strikes with the heat of the sun.<br>
	Such a weapon is unfit for a warrior concerned with loyalty or honour.<br>
	"When honor's lost, 'tis a relief to die; Death's but a sure retreat from infamy,"</p>"}

/obj/item/paper/book/scroll_shame
	name = "scrawled scroll"
	desc = "An ancient scroll."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "scroll"
	info = {"None can know of my shame."}

// Turfs

// -Walls
TYPEINFO(/turf/unsimulated/wall/auto/sengoku)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/sengoku)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto/sengoku)
/turf/unsimulated/wall/auto/sengoku
	icon = 'icons/turf/walls_sengoku.dmi'


TYPEINFO(/turf/unsimulated/wall/auto/paper)
TYPEINFO_NEW(/turf/unsimulated/wall/auto/paper)
	. = ..()
	connects_to = typecacheof(/turf/unsimulated/wall/auto/paper)
/turf/unsimulated/wall/auto/paper
	icon = 'icons/turf/walls_paper.dmi'


/turf/unsimulated/wall/sengoku_tall
	icon = 'icons/turf/walls_sengoku.dmi'
	icon_state= "tall"
	opacity = 0

/turf/simulated/wall/false_wall/sengoku
	desc = "There seems to be markings on one of the edges, huh."
	icon = 'icons/turf/walls_paper.dmi'
	icon_state = "2"
	can_be_auto = 0


// -Floors

/turf/unsimulated/floor/tatami //split up in the fancy new zewaka non-instanced floors way, i hope.
	icon = 'icons/turf/dojo.dmi'
	icon_state = "tatami"

/turf/unsimulated/floor/tatami/north
	icon = 'icons/turf/dojo.dmi'
	icon_state = "north"

/turf/unsimulated/floor/tatami/south
	icon = 'icons/turf/dojo.dmi'
	icon_state = "south"

/turf/unsimulated/floor/tatami/east
	icon = 'icons/turf/dojo.dmi'
	icon_state = "east"

/turf/unsimulated/floor/tatami/west
	icon = 'icons/turf/dojo.dmi'
	icon_state = "west"

/turf/unsimulated/wall/water // yeah uh, it needs to be dense. but i'm pretty dense myself so here's this.
	name = "water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	density = 1
	opacity = 0

/turf/unsimulated/wall/water/border
	icon = 'icons/turf/dojo.dmi'
	icon_state = "water_border"

/turf/unsimulated/floor/dojo/bridge/vertical
	name = "bridge"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "bridge_v"

/turf/unsimulated/floor/dojo/bridge/horizontal
	name = "bridge"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "bridge_h"

/turf/unsimulated/floor/dojo/bridge
	name = "bridge"
	icon = 'icons/turf/dojo.dmi'

/turf/unsimulated/floor/dojo/stone
	name = "stone"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "stone"

/turf/unsimulated/floor/dojo/stonestair
	name = "stone stairs"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "stonestair"

/turf/unsimulated/floor/dojo/stonestair/left
	icon_state = "stonestair_L"

/turf/unsimulated/floor/dojo/stonestair/middle
	icon_state = "stonestair_M"

/turf/unsimulated/floor/dojo/stonestair/right
	icon_state = "stonestair_R"

/turf/unsimulated/floor/dojo/sand
	name = "zen garden"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "sand"

/turf/unsimulated/floor/dojo/sand/horizontal
	icon_state = "sand_horiz"

/turf/unsimulated/floor/dojo/sand/vertical
	icon_state = "sand_vert"

/turf/unsimulated/floor/dojo/sand/circle
	icon_state = "sand_circ"

// Simulated variants of turfs

/turf/simulated/floor/dojo/sand
	name = "zen garden"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "sand"

	horizontal
		icon_state = "sand_horiz"

	vertical
		icon_state = "sand_vert"

	circle
		icon_state = "sand_circ"

/turf/simulated/floor/dojo/stone
	name = "stone"
	icon = 'icons/turf/dojo.dmi'
	icon_state = "stone"
