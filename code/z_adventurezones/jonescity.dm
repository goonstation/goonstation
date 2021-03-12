/* -----------------------------------------------------------------------------*\
CONTENTS:
JONES CITY AREAS
DOUBLE EMAGGED JONES - see pets_small_animals.dm
WAD OF PAPER WITH CAT FLOOR TILE LOCATION
CAT FLOOR TILE
CAT RADIO BEACON
CAT PERSISTENT SIGNAL LOCATOR
CRIME JONES
SECRET WALL LEADING TO THE ALLEYWAYS
HAIRBALLS, HAIRBALL DYNASSEMBLY, HAIRBALL KEY, AND HAIRBALL DOOR
JONES CITY TURFS
\*----------------------------------------------------------------------------- */

/area/jones
	name = "Catmandu"
	icon_state = "red"
	sound_environment = 16
	skip_sims = 1
	sims_score = 30
	ambient_light = rgb(0.75 * 255, 0.75 * 255, 0.75 * 255)
	filler_turf = "/turf/unsimulated/floor"
	sound_group = "jonescity"

	litterbox
		name = "The Litterbox"
		icon_state = "yellow"

		Entered(atom/movable/O)
			..()
			if (isliving(O))
				boutput(O, "<span class='alert'> Wow, it stinks in here! </span>")

	complex
		name = "Meowment Complex"
		icon_state = "blue"

	bar
		name = "The Grizzly Parr"
		icon_state = "orange"

	council
		name = "Council Chambers"
		icon_state = "green"

	alley
		name = "Catmandu Alleyways"
		icon_state = "purple"

	ruins
		name = "Catmandu North Sector"
		icon_state = "pink"
		ambient_light = rgb(0.4 * 255, 0.4 * 255, 0.4 * 255)
		irradiated = 0.2

	radiation
		name = "Catmandu North Sector"
		icon_state = "orange"
		ambient_light = rgb(0.4 * 255, 0.4 * 255, 0.4 * 255)
		irradiated = 0.6

/turf/unsimulated/floor/concrete/cat //Ruined concrete floor
	name = "concrete floor"
	icon = 'icons/misc/jonescity.dmi'
	icon_state = "floor"

	New()
		..()
		src.set_dir(pick(cardinal))

/obj/item/paper/jones_note //When the lord plays, nothing is fair.
	name = "slimy wad of paper"
	desc = "It seems to have some interesting scribblings."
	icon_state = "paper_caution_crumple"

	sizex = 400
	sizey = 600

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body style='margin:0px'><img src='[resource("images/jones_note.png")]'></body></html>"

	examine()
		return ..()

	attackby()
		return

/turf/unsimulated/floor/key_floor/jones
	icon_state = "panelscorched"

	attack_hand(var/mob/user)
		if(!found_thing)
			found_thing = 1
			user.show_text("Huh, one of these tiles is a bit loose.  Underneath it is... a locator?", "red")
			new /obj/item/locator/jones(src)
		else
			user.show_text("Nothing out of the ordinary.", "blue")

///////////////////////////////////For the two below, see teleportation.dm
/obj/item/device/radio/beacon/jones
	desc = "A small beacon that is tracked by a signal locator, allowing things to be sent to its general location. Smells like cat hair."

/obj/item/locator/jones
	desc = "This persistent signal locator seems to be covered in cat hair."

////////////////////////////Cat alley stuff
/obj/critter/cat/crimejones
	name = "Crime Jones"
	desc = "Something is just not right about this Jones. They seem angry."
	icon_state = "cat1"
	health = 30
	randomize_cat = 0
	generic = 0
	var/givenfish = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/pill/catdrugs))
			if (src.givenfish == 0)
				qdel(W)
				givenfish++
				boutput(user, "<span class='alert'>You feed \the [W] to the [src]</span>")
				playsound(src.loc, "sound/voice/animal/cat_hiss.ogg", 50, 1)
				src.visible_message("<span class='combat'><b>[src]</b> hisses!</span>")
				SPAWN_DBG(12 SECONDS)
					src.visible_message("<span class='combat'>[src] starts coughing wildly!</span>")
					animate_shake(src,5,rand(3,8),rand(3,8))
					sleep(9 SECONDS)
					src.visible_message("<span class='combat'>[src] coughs out a old fish!</span>")
					new /obj/item/fish/mahimahi(src.loc)


/obj/item/fish/mahimahi
		name = "Mahi-mahi"
		desc = "Also known as a dolphinfish, this tropical fish is prized for its quality and size. When first taken out of the water, they change colors."
		icon_state = "mahimahi"
		fillet_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/white

/turf/unsimulated/wall/auto/gannets/cat
	name = "wall"
	//desc = "Something about this wall is fishy."
	can_replace_with_stuff = 1
	connects_to = list(/turf/unsimulated/wall/auto/gannets/cat)
	var/special = 0 //Does fish remove it? Bit of a dumb workaround.

	attackby(obj/item/W as obj, mob/user as mob)
		if (special)
			if (istype(W, /obj/item/fish/mahimahi))
				boutput(user, "You slap the [src] with the [W]!")
				src.visible_message("<span class='notice'><b>[src] crumbles into dust!</b></span>")
				src.ReplaceWithSpace()

////////////////////////////////////////////hairball key parts

/obj/item/hairball
	name = "mystery hairball"
	desc = "An absolutely disgusting ball of hair."
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "hairball1"
	item_state = "pen"

	one
		name = "fuzzy hairball"
		icon_state = "hairball1"
	two
		name = "clumpy hairball"
		icon_state = "hairball2"
	three
		name = "stringy hairball"
		icon_state = "hairball3"
	inert
		name = "hairball"

/obj/item/hairball/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/hairball) && !istype(W, /obj/item/hairball/inert)) //in case we have a decorative hairball??
		boutput(user, "<span class='notice'>You begin adding \the [W.name] to \the [src.name].</span>")
		if (!do_after(user, 3 SECONDS))
			boutput(user, "<span class='alert'>You were interrupted!</span>")
			return ..()
		else
			if (!user) return
			user.visible_message("<span class='notice'><b>[user.name]</b> drops the objects in their hands to create an assembly.</span>")
			user.u_equip(W)
			user.u_equip(src)
			var/obj/item/dynassembly/hairball/A = new /obj/item/dynassembly/hairball(get_turf(src))
			A.newpart(src,W,1)
	else
		return ..()


/obj/item/dynassembly/hairball
	name = "hair"
	icon = 'icons/misc/aprilfools.dmi'
	validparts = list(/obj/item/hairball/)
	var/one
	var/two
	var/three

	checkifdone()
		for (var/obj/item/i in src.contents)
			if (istype(i, /obj/item/hairball/one))
				one++
			if (istype(i, /obj/item/hairball/two))
				two++
			if (istype(i, /obj/item/hairball/three))
				three++
		if (one && two && three)
			src.product = 1
			src.desc += "<BR><span class='notice'>It looks like this assembly can be secured with a screwdriver.</span>"

	createproduct(mob/user)
		if (product == 1)
			var/obj/item/device/key/hairball/N = new /obj/item/device/key/hairball(get_turf(src))
			boutput(user, "You secure the hair into a disgusting matted [N]!")
		return

/obj/hairball_door //the door that the hairball key fits in
	name = "gunked-up airlock"
	desc = "The airlocks seems all gunked up with cat hair. Grody."
	icon = 'icons/obj/doors/Doorclassic.dmi'
	icon_state = "door_locked"
	opacity = 1
	density = 1
	anchored = 1

	attackby(var/obj/item/I, var/mob/user)
		if (istype(I, /obj/item/device/key/hairball))
			boutput(user, "<span class='notice'>You insert the [I.name] into the door and turn it. The door emits a loud click.</span>")
			user.drop_item()
			qdel(I)
			playsound(src.loc, "sound/machines/door_open.ogg", 50, 1)
			icon_state = "door_open"
			set_density(0)
			opacity = 0

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/decal/garland/cat
	name = "garland"
	desc = "It's all old and fuzzy."
	icon = 'icons/misc/xmas.dmi'
	icon_state = "garland"
	anchored = 1
	var/given = 0

	attackby(var/obj/item/I, var/mob/user)
		if (issnippingtool(I) && !given)
			boutput(user, "<span class='notice'>You trim the [src] with the [I]. A wad of hair tumbles out.</span>")
			icon_state = "garland-snipped"
			new /obj/item/hairball/three(src.loc)
			given++

////////////////////////////////////

/obj/item/device/audio_log/jonesevent
	audiolog_messages = list("*harsh static*",
"Looks like we got the equipment all dialed in. It should be ready for the Test.",
"Sure, sure. Just don't mess up like last time. That was a near-failure.",
"It's fine, this shielding is made of a new material. It should keep the Zetas out just fine.",
"Alright, let's get this over with.",
"*tapping on a keyboard*",
"I'm getting some strange readings from the counter, you seeing this?!",
"ALERT. SYSTEM OVERHEATING. EVACUATE.",
"Run.",
"*frantic footsteps*")
	audiolog_speakers = list("???",
"Unknown Man",
"Other Man",
"Unknown Man",
"Other Man",
"???",
"Other Man",
"Synthesized Voice",
"Unknown Man",
"???")

/obj/item/paper/jones_manual
	name = "paper- 'Z-38 Emitter Operating Procedure'"
	info = {"<center><h3>Z-38 Emitter Operating Procedure</h3></center><hr>
<h4>Activation Procedure</h4>
<ol>
<li>Calibrate the Emitter so the dials match the ambient Z levels.</li>
<li>Confirm that the Emitter is free of obstructions and sealed within the shielded casing.</li>
<li>If any readings are abnormal, shut down the machine and bring it in for servicing.</li>
<li>Else, record results, etc.</li>
<li>Deactivate the device by turning the red dial to the left.</li>
</ol>"}
