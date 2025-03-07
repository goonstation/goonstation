//file for da fishin gear

// rod flags are WIP, nonfunctional yet
#define ROD_WATER (1<<0) //can it fish in water?

/obj/item/fishing_rod
	name = "fishing rod"
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "fishing_rod-inactive"
	c_flags = ONBELT
	/// average time to fish up something, in seconds - will vary on the upper and lower bounds by a maximum of 4 seconds, with a minimum time of 0.5 seconds.
	var/fishing_speed = 8 SECONDS
	/// how long to wait between casts in seconds - mainly so sounds dont overlap
	var/fishing_delay = 2 SECONDS
	/// set to TIME when fished, value is checked when deciding if the rod is currently on cooldown
	var/last_fished = 0
	/// true if the rod is currently "fishing", false if it isnt
	var/is_fishing = FALSE
	/// what tier of rod is this? can be 0, 1 or 2
	var/tier = 0

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(attackby_pre))  // Storage for a single lure item
		src.create_storage(/datum/storage, can_hold = list(/obj/item/reagent_containers/food), max_wclass = W_CLASS_NORMAL, slots = 1)

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE)
		. = ..()

	//get the kind of lure currently being used by the fishing rod
	proc/get_lure()
		if (length(src.storage.stored_items))
			return src.storage.stored_items[1]
		else return null

	//todo: attack particle?? some sort of indicator of where we're fishing
	proc/attackby_pre(source, atom/target, mob/user)
		if (target && user && (src.last_fished < TIME + src.fishing_delay))
			var/datum/fishing_spot/fishing_spot = null
			if (isturf(target))
				var/turf/T = target
				target = T.active_liquid || target
			var/fishing_spot_type = target.type
			while (fishing_spot_type != null)
				fishing_spot = global.fishing_spots[fishing_spot_type]
				if (fishing_spot != null)
					break
				fishing_spot_type = type2parent(fishing_spot_type)
			if (fishing_spot)
				if (fishing_spot.rod_tier_required > src.tier)
					boutput(user, SPAN_ALERT("You need a higher tier rod to fish here!"))
					return TRUE
				actions.start(new /datum/action/fishing(user, src, fishing_spot, target), user)
				return TRUE //cancel the attack because we're fishing now

	update_icon()
		//state for fishing
		if (src.is_fishing)
			src.icon_state = "fishing_rod-active"
			src.item_state = "fishing_rod-active"
		//state for not fishing
		else
			src.icon_state = "fishing_rod-inactive"
			src.item_state = "fishing_rod-inactive"

/// (invisible) action for timing out fishing. this is also what lets the fishing spot know that we fished
/datum/action/fishing
	var/mob/user = null
	/// the target of the action
	var/atom/target = null
	/// what fishing rod triggered this action
	var/obj/item/fishing_rod/rod = null
	/// the fishing spot that the rod is fishing from
	var/datum/fishing_spot/fishing_spot = null
	/// how long the fishing action loop will take in seconds, set on onStart(), varies by 4 seconds in either direction.
	duration = 1 MINUTE
	/// id for fishing action

	New(var/user, var/rod, var/fishing_spot, var/target)
		..()
		src.user = user
		src.rod = rod
		src.fishing_spot = fishing_spot
		src.target = target

	onStart()
		..()
		if (src.rod.tier < fishing_spot.rod_tier_required)
			//user.visible_message(SPAN_ALERT("You need a higher tier rod to fish here!"))
			boutput(user, SPAN_NOTICE("You need a higher tier rod to fish here!."))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (user.bioHolder.HasEffect("clumsy") && prob(10))
			user.visible_message(SPAN_ALERT("<b>[user]</b> fumbles with [src.rod] in [his_or_her(user)] haste and hits [himself_or_herself(user)] in the forehead with it!"))
			user.changeStatus("knockdown", 2 SECONDS)
			playsound(user, 'sound/impact_sounds/tube_bonk.ogg', 50, 1)
			interrupt(INTERRUPT_ALWAYS)
			JOB_XP(user, "Clown", 1)
			return

		src.duration = max(0.5 SECONDS, rod.fishing_speed + (pick(1, -1) * (rand(0,40) / 10) SECONDS)) //translates to rod duration +- (0,4) seconds, minimum of 0.5 seconds
		playsound(src.user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
		//src.user.visible_message("[src.user] starts fishing.")
		boutput(user, SPAN_NOTICE("You start fishing."))
		src.rod.is_fishing = TRUE
		src.rod.UpdateIcon()
		src.user.update_inhands()
		JOB_XP(user, "Angler", 1)

	onUpdate()
		..()
		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			return

	onInterrupt(flag)
		src.rod.is_fishing = FALSE
		src.rod.UpdateIcon()
		src.user.update_inhands()
		. = ..()

	onEnd()
		if (!(BOUNDS_DIST(src.user, src.rod) == 0) || !(BOUNDS_DIST(src.user, src.target) == 0) || !src.user || !src.target || !src.rod || !src.fishing_spot)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			return

		if (src.fishing_spot.try_fish(src.user, src.rod, target)) //if it returns one we successfully fished, otherwise lets restart the loop
			..()
			if (length(src.rod.storage.stored_items))
				var/obj/item/lure = src.rod.storage.stored_items[1]
				boutput(user, SPAN_NOTICE("The [lure] was bit and is no longer stuck to the [src.rod]."))
				qdel(lure)
			src.rod.is_fishing = FALSE
			src.rod.UpdateIcon()
			src.user.update_inhands()
			return

		else //lets restart the action
			src.onRestart()

/obj/item/fishing_rod/basic
	name = "basic fishing rod"
	icon_state = "fishing_rod-inactive"
	item_state = "fishing_rod-inactive"
	tier = 1

	update_icon()
		if (src.is_fishing)
			src.icon_state = "fishing_rod-active"
			src.item_state = "fishing_rod-active"
		else
			src.icon_state = "fishing_rod-inactive"
			src.item_state = "fishing_rod-inactive"

/obj/item/fishing_rod/upgraded
	name = "upgraded fishing rod"
	icon_state = "fishing_rod_2-inactive"
	item_state = "fishing_rod-inactive"
	tier = 2

	update_icon()
		if (src.is_fishing)
			src.icon_state = "fishing_rod_2-active"
			src.item_state = "fishing_rod-active"
		else
			src.icon_state = "fishing_rod_2-inactive"
			src.item_state = "fishing_rod-inactive"

/obj/item/fishing_rod/master
	name = "master fishing rod"
	icon_state = "fishing_rod_3-inactive"
	item_state = "fishing_rod-inactive"
	tier = 3

	update_icon()
		if (src.is_fishing)
			src.icon_state = "fishing_rod_3-active"
			src.item_state = "fishing_rod-active"
		else
			src.icon_state = "fishing_rod_3-inactive"
			src.item_state = "fishing_rod-inactive"

/obj/item/fishing_rod/cybernetic
	name = "cybernetic fishing rod"
	desc = "A Cybernetic Fishing Rod. Use on a fishing rod on the ground to upgrade."
	icon_state = "fishing_rod-inactive"
	item_state = "fishing_rod-inactive"
	tier = 1

	update_icon()
		var/isactive = src.is_fishing ? "active" : "inactive"
		src.icon_state = "fishing_rod[src.tier > 1 ? "_[src.tier]" : ""]-[isactive]"
		src.item_state = "fishing_rod-[isactive]"

	afterattack(atom/target, mob/user, reach, params)
		if (istype(target, /obj/item/fishing_rod/upgraded) && src.tier < 2)
			src.tier = 2
			src.icon = target.icon
			src.icon_state = target.icon_state
			user.visible_message("<span class='notice'>You upgrade your [src.name] with [target].</span>")
			qdel(target)
			return
		if (istype(target, /obj/item/fishing_rod/master) && src.tier < 3)
			src.tier = 3
			src.icon = target.icon
			src.icon_state = target.icon_state
			user.visible_message("<span class='notice'>You upgrade your [src.name] with [target].</span>")
			qdel(target)
			return
		else
			. = ..()

// portable fishing portal currently found in a prefab in space
TYPEINFO(/obj/item/fish_portal)
	mats = 11

/obj/item/fish_portal
	name = "Fishing Portal Generator"
	desc = "A small device that creates a portal you can fish in."
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fish_portal"

	attack_self(mob/user as mob)
		new /obj/machinery/active_fish_portal(get_turf(user))
		playsound(src.loc, 'sound/items/miningtool_on.ogg', 40)
		user.visible_message("[user] flips on the [src].", "You turn on the [src].")
		user.u_equip(src)
		qdel(src)

/obj/machinery/active_fish_portal
	name = "Fishing Portal"
	desc = "A portal you can fish in. It's not big enough to go through."
	anchored = ANCHORED
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fish_portal-active"

	attack_hand(mob/user)
		new /obj/item/fish_portal(get_turf(src))
		playsound(src.loc, 'sound/items/miningtool_off.ogg', 40)
		user.visible_message("[user] flips off the [src].", "You turn off the [src].")
		qdel(src)

/obj/fishing_pool
	name = "Aquatic Research Pool"
	desc = "A small bulky pool that you can fish in. It has a low probability of containing various low-rarity fish."
	density = 1
	anchored = 1
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "fishing_pool"

	ex_act(severity)
		// dynamite fishing! make the research pool throw out fish depending on how big the severity of the explosion was
		var/dynamite_fishing_cooldown = 1 SECOND //! the cooldown of dynamite fishing.
		// First, we need to get our fishing spot datum
		var/datum/fishing_spot/fishing_spot = null
		var/fishing_spot_type = src.type
		// now we search for the corresponding defined fishing spot up the chain of parents
		while (fishing_spot_type != null)
			fishing_spot = global.fishing_spots[fishing_spot_type]
			if (fishing_spot != null)
				break
			fishing_spot_type = type2parent(fishing_spot_type)
		// now we define our fishing sucess and damage on the fish tank based on the severity
		// defined values are for severity 3
		var/explosion_damage = -5 //! how much damage each explosion does
		var/fish_chance = 20 //! how much fish per roll jumps out of the pond
		var/fish_rolls = 2 //! how often the fish chance is rolled
		var/dynamite_fishing_sucessfull = FALSE //! shows if the explosion sucessfully "fished" some fish
		switch(severity)
			if(1)
				//You blew up the whole tank, doofus!
				explosion_damage = -100
				fish_chance = 0
				fish_rolls = 0
			if(2)
				explosion_damage = -20
				fish_chance = 70
				fish_rolls = 5
		if (fishing_spot && fish_rolls && !ON_COOLDOWN(src, "dynamite fishing", dynamite_fishing_cooldown))
			var/turf/target_turf = get_turf(src)
			// now, if we don't blow it up extremly, we can roll for fish
			for (var/fish_try in 1 to fish_rolls)
				if (prob(fish_chance))
					var/atom/movable/fishing_result = fishing_spot.generate_fish(null, null, src)
					if(fishing_result)
						fishing_result.set_loc(target_turf)
						var/target_point = get_turf(pick(orange(4, src)))
						fishing_result.throw_at(target_point, rand(0, 10), rand(3, 9))
						dynamite_fishing_sucessfull = TRUE
			if (dynamite_fishing_sucessfull)
				src.visible_message("<b class='alert'>Fishes jump out of [src]! [pick("Holy shit!", "Holy fuck!", "What the hell!", "What the fuck!")]</b>")
				// lets create a neat water spread effect
				var/datum/effects/system/steam_spread/splash = new /datum/effects/system/steam_spread
				splash.set_up(6, 0, get_turf(src), color="#382ec9", plane=PLANE_NOSHADOW_ABOVE)
				splash.attach(src)
				splash.start()
		//Now we damage the pond. No infinite dynamite fishing
		src.material_trigger_on_explosion(severity)
		src.changeHealth(explosion_damage)

/obj/fishing_pool/basic
	name = "basic pool"

/obj/fishing_pool/upgraded
	name = "upgraded pool"

/obj/fishing_pool/master
	name = "master pool"

/obj/fishing_pool/portable
	anchored = 0

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [src.anchored ? "unanchors" : "anchors"] the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
			src.anchored = !(src.anchored)
			return
		else
			return ..()

// Gannets new fishing gear

/obj/submachine/fishing_upload_terminal
	name = "Aquatic Research Upload Terminal"
	desc = "Insert fish to receive points to spend in the fishing vendor."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "uploadterminal_open"
	anchored = ANCHORED
	density = 1
	layer = MOB_LAYER + 0.1
	var/working = FALSE
	var/allowed = list(/obj/item/reagent_containers/food/fish)

	attack_hand(var/mob/user)
		if (!length(src.contents))
			boutput(user, SPAN_ALERT("There is nothing in the upload terminal!"))
			return
		if (src.working)
			boutput(user, SPAN_ALERT("The terminal is busy!"))
			return
		src.icon_state = "uploadterminal_working"
		src.working = TRUE
		src.visible_message("The [src] begins uploading research data.")
		playsound(src.loc, 'sound/effects/fish_processing_alt.ogg', 100, 1)
		sleep(rand(3 SECONDS, 7 SECONDS))
		var/found_blacklisted_fish = FALSE
		// Dispense processed stuff
		for(var/obj/item/reagent_containers/food/fish/P in src)
			//No botany fish. Be a real angler and use that damn fishing rod
			if (P.fishing_upload_blacklisted)
				found_blacklisted_fish = TRUE
				P.set_loc(get_turf(src))
			else
				switch( P.rarity )
					if (ITEM_RARITY_COMMON)
						new/obj/item/currency/fishing(src.loc)
						JOB_XP(user, "Angler", 1)
						qdel( P )
					if (ITEM_RARITY_UNCOMMON)
						new/obj/item/currency/fishing/uncommon(src.loc)
						JOB_XP(user, "Angler", 2)
						qdel( P )
					if (ITEM_RARITY_RARE)
						new/obj/item/currency/fishing/rare(src.loc)
						JOB_XP(user, "Angler", 3)
						qdel( P )
					if (ITEM_RARITY_EPIC)
						new/obj/item/currency/fishing/epic(src.loc)
						JOB_XP(user, "Angler", 4)
						qdel( P )
					if (ITEM_RARITY_LEGENDARY)
						new/obj/item/currency/fishing/legendary(src.loc)
						JOB_XP(user, "Angler", 5)
						qdel( P )
		if (found_blacklisted_fish)
			src.visible_message(SPAN_ALERT("\The [src] ejects synthetical fish it was unable to do any research on!"))

		// Wind down
		for(var/obj/item/S in src)
			S.set_loc(get_turf(src))
		src.working = FALSE
		src.icon_state = "uploadterminal_open"
		playsound(src.loc, 'sound/effects/fish_processed_alt.ogg', 100, 1)

	attack_ai(var/mob/user as mob)
		return src.Attackhand(user)

	attackby(obj/item/W, mob/user)
		if (src.working)
			boutput(user, SPAN_ALERT("The terminal is busy!"))
			return
		if (istype(W, /obj/item/storage/fish_box))
			var/obj/item/storage/fish_box/S = W
			if (length(S.contents) < 1) boutput(user, SPAN_ALERT("There's no fish in the portable aquarium!"))
			else
				user.visible_message(SPAN_NOTICE("[user] loads [S]'s contents into [src]!"))
				var/amtload = 0
				for (var/obj/item/reagent_containers/food/fish/F in S.contents)
					F.set_loc(src)
					amtload++
				S.UpdateIcon()
				boutput(user, SPAN_NOTICE("[amtload] fish loaded from the portable aquarium!"))
				S.tooltip_rebuild = 1
			return
		else
			var/proceed = FALSE
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = TRUE
					break
			if (!proceed)
				boutput(user, SPAN_ALERT("You can't put that in the upload terminal!"))
				return
			user.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)

/obj/submachine/fishing_upload_terminal/portable
	anchored = 0

	attackby(obj/item/W, mob/user)
		if (istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [src.anchored ? "unanchors" : "anchors"] the [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
			src.anchored = !(src.anchored)
			return
		else
			return ..()

/obj/item/storage/fish_box
	name = 	"portable aquarium"
	desc = "A temporary solution for transporting fish."
	icon = 'icons/obj/items/fishing_gear.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	icon_state = "aquarium"
	item_state = "aquarium"
	slots = 6
	can_hold = list(/obj/item/reagent_containers/food/fish)

/obj/item/storage/fish_box/small
	name = 	"small portable aquarium"
	desc = "A smaller, temporary solution for transporting fish."
	icon = 'icons/obj/items/fishing_gear.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	icon_state = "aquarium"
	item_state = "aquarium"
	slots = 3
	can_hold = list(/obj/item/reagent_containers/food/fish)

TYPEINFO(/obj/item/syndie_fishing_rod)
	mats = list("metal_superdense" = 15,
				"wood" = 5,
				"energy_high" = 5,
				"conductive_high" = 5)
/obj/item/syndie_fishing_rod
	name = "\improper Glaucus fishing rod"
	desc = "A high grade tactical fishing rod, completely impractical for reeling in bass."
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "syndie_fishing_rod-inactive"
	inhand_image_icon = 'icons/mob/inhand/hand_fishing.dmi'
	item_state = "syndie_fishing_rod-inactive"
	hit_type = DAMAGE_STAB
	flags = TABLEPASS | USEDELAY
	w_class = W_CLASS_NORMAL
	force = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	contraband = 4
	is_syndicate = TRUE
	tooltip_flags = REBUILD_DIST
	var/obj/item/syndie_lure/lure = null
	/// delay between tossing or reeling or etc
	var/usage_cooldown = 0.8 SECONDS
	/// time per step to reel/filet a mob
	var/syndie_fishing_speed = 0.7 SECONDS
	/// cooldown after throwing a hooked target around
	var/yank_cooldown = 6 SECONDS
	/// how far you throw when yanking them
	var/yank_range = 4
	/// how far the line can stretch
	var/line_length = 8
	/// true if the rod is currently ""fishing"", false if it isnt
	var/is_fishing = FALSE
	HELP_MESSAGE_OVERRIDE({"The Glaucus starts with 7 damage on a melee reel, but stores up 3 onetime bonus damage on each ranged reel. If this reaches <b>25 damage</b>, or 6 ranged reels before a melee reel, the target will be stunned when damaged."})

	New()
		..()
		src.reset_lure()
		RegisterSignal(src, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(max_range_check))

	get_desc(dist)
		..()
		if (dist < 1 && src.lure) // on our tile or our person and a lure exists
			. += "There is \a [src.lure.name] presented as bait."

	attackby(obj/item/I, mob/user)
		src.reset_lure()
		if (src.lure.loc == src)
			boutput(user, "You scan \the [I.name] onto \the [src.name]'s holographic bait projector.")
			src.lure.real_name = I.name
			src.lure.real_desc = I.desc
			src.lure.appearance = I
			src.lure.set_dir(I.dir)
			src.lure.overlay_refs = I.overlay_refs?.Copy()
			src.lure.plane = initial(src.lure.plane)
			src.lure.layer = initial(src.lure.layer)
			src.lure.tooltip_rebuild = 1
			tooltip_rebuild = 1
		else
			boutput(user, "You can't change the bait while the line is out!")
		return

	attack_self(mob/user)
		. = ..()
		src.reset_lure()
		if (src.lure.loc == src)
			boutput(user, "You clean \the [src.name]'s holographic bait projector.")
			src.lure.clean_forensic()
		else
			if(!src.lure.owner)
				if(BOUNDS_DIST(src.lure,src) == 0)
					src.is_fishing = FALSE
					src.UpdateIcon()
					user.update_inhands()
					src.lure.set_loc(src)
				else
					if (!istype(src.lure.loc, /turf))
						src.lure.set_loc(get_turf(src.lure.loc))
					else
						step_towards(src.lure, src)
			else
				user.visible_message(SPAN_ALERT("<b>[user] yanks the lure out of [src.lure.owner]!</b>"))
				src.lure.set_loc(get_turf(src.lure.loc))
				src.lure.owner = null

	pixelaction(atom/target, params, mob/user, reach)
		..()
		return null

	afterattack(atom/target, mob/user)
		..()
		if (!isturf(user.loc))
			return
		src.reset_lure()
		if (!ON_COOLDOWN(user, "syndie_fishing_delay", src.usage_cooldown))
			if (src.lure.owner && isliving(src.lure.owner))
				logTheThing(LOG_COMBAT, user, "at [log_loc(src)] reels in a Syndicate Fishing Rod hooked in [src.lure.owner]")
				if (!actions.hasAction(user, /datum/action/bar/syndie_fishing))
					actions.start(new /datum/action/bar/syndie_fishing(user, src.lure.owner, src, src.lure), user)
				if (!ON_COOLDOWN(user, "syndie_fishing_yank", src.yank_cooldown))
					src.lure.owner.throw_at(target, yank_range, yank_range / 4)
					user.visible_message(SPAN_ALERT("<b>[user] thrashes [src.lure.owner] by yanking \the [src.name]!</b>"))
			else if (src.lure.loc == src)
				if (target == loc)
					return
				logTheThing(LOG_COMBAT, user, "casts a Syndicate Fishing Rod out at [log_loc(src)]")
				playsound(user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
				src.is_fishing = TRUE
				src.UpdateIcon()
				user.update_inhands()
				src.lure.pixel_x = rand(-12, 12)
				src.lure.pixel_y = rand(-12, 12)
				src.lure.set_loc(get_turf(src.loc))
				src.lure.throw_at(target, src.line_length, 2)
			else
				src.pull_in_lure(user)

	update_icon()
		//state for fishing
		if (src.is_fishing)
			src.icon_state = "syndie_fishing_rod-active"
			src.item_state = "syndie_fishing_rod-active"
		//state for not fishing
		else
			src.icon_state = "syndie_fishing_rod-inactive"
			src.item_state = "syndie_fishing_rod-inactive"

	disposing()
		UnregisterSignal(src, XSIG_MOVABLE_TURF_CHANGED)
		UnregisterSignal(src.lure, XSIG_MOVABLE_TURF_CHANGED)
		qdel(src.lure)
		. = ..()

	proc/reset_lure()
		if (!src.lure)
			src.lure = new (src)
			src.lure.rod = src
			tooltip_rebuild = 1
			RegisterSignal(src.lure, XSIG_MOVABLE_TURF_CHANGED, PROC_REF(max_range_check))
		if (src.lure.owner && src.lure.loc != src.lure.owner)
			src.lure.owner = null

	proc/max_range_check()
		if (GET_DIST(src, src.lure) > src.line_length)
			src.pull_in_lure()

	// reels in, returns whether damage was dealt
	proc/reel_in(mob/target, mob/user, damage_on_reel = 7)
		target.setStatusMin("staggered", 4 SECONDS)
		if(BOUNDS_DIST(target, user) == 0)
			if (issilicon(target))
				user.visible_message(SPAN_ALERT("<b>[user] tears some scrap out of [target] with \the [src.name]!</b>"))
				playsound(target.loc, 'sound/impact_sounds/circsaw.ogg', 40, 1)
				random_burn_damage(target, damage_on_reel)
			else
				user.visible_message(SPAN_ALERT("<b>[user] reels some meat out of [target] with \the [src.name]!</b>"))
				playsound(target.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				take_bleeding_damage(target, user, damage_on_reel, DAMAGE_CUT)
			random_brute_damage(target, damage_on_reel)
			if (damage_on_reel >= 25)
				target.changeStatus("knockdown", sqrt(damage_on_reel) / 3 SECONDS)
				target.force_laydown_standup()
				if (target.bioHolder && target.bioHolder.Uid && target.bioHolder.bloodType)
					gibs(target.loc, blood_DNA=target.bioHolder.Uid, blood_type=target.bioHolder.bloodType, headbits=FALSE, source=target)
				else
					gibs(target.loc, headbits=FALSE, source=target)
			return TRUE
		else
			step_towards(target, user)
			return FALSE

	proc/pull_in_lure(mob/user)
		if(QDELETED(src.lure))
			src.lure = null
			return
		if (src.lure.owner)
			src.lure.owner.visible_message("\The [src.lure] rips out of [src.lure.owner]!", "\The [src.lure] rips out of you!")
			take_bleeding_damage(src.lure.owner, null, 5, DAMAGE_STAB)
		src.lure.set_loc(get_turf(src.lure))
		src.lure.owner = null
		src.lure.throw_at(src, 15, 2)
		SPAWN(0.2 SECONDS)
			if (src.lure)
				if (src.lure.owner)
					src.lure.owner.throw_at(src, 2, 2)
				else
					src.lure.set_loc(src)
					src.is_fishing = FALSE
					src.UpdateIcon()
					if(istype(user))
						user.update_inhands()

/obj/item/syndie_lure
	name = "minnow"
	desc = "One of the most common bait fish, looks like this one got away! Until it caught you."
	icon = 'icons/obj/foodNdrink/food_fish.dmi'
	icon_state = "minnow"
	object_flags = NO_GHOSTCRITTER
	throwforce = 5
	density = 0
	var/obj/item/syndie_fishing_rod/rod = null
	var/mob/owner

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W, mob/user)
		if (src.try_embed(user))
			return
		..()

	attack_hand(mob/user)
		if (src.try_embed(user))
			return
		..()

	pickup(mob/user)
		if (src.try_embed(user))
			return
		..()

	pull(mob/user)
		if (src.try_embed(user))
			return
		..()

	Crossed(atom/movable/AM as mob|obj)
		if (ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.lying)
				src.try_embed(H, FALSE)
		..()

	Uncrossed(atom/movable/AM as mob|obj)
		if (ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.lying)
				src.try_embed(H, FALSE)
		..()

	throw_impact(mob/hit_atom, datum/thrown_thing/thr)
		if (istype(hit_atom))
			src.try_embed(hit_atom, FALSE)
			return
		return ..()

	proc/try_embed(mob/M, do_weaken = TRUE)
		if (istype(M) && isliving(M))
			var/area/AR = get_area(M)
			if (AR?.sanctuary || M.nodamage || (src.rod in M.equipped_list(check_for_magtractor = 0)))
				return TRUE
			if (do_weaken)
				M.changeStatus("knockdown", 5 SECONDS)
				M.TakeDamage(M.hand == LEFT_HAND ? "l_arm": "r_arm", 15, 0, 0, DAMAGE_STAB)
			M.force_laydown_standup()

			src.owner = M
			src.set_loc(M)
			M.visible_message(SPAN_ALERT("<b>[M] gets snagged by a fishing lure!</b>"))
			logTheThing(LOG_COMBAT, M, "is caught by a barbed fishing lure at [log_loc(src)]")
			M.emote("scream")
			take_bleeding_damage(M, null, 10, DAMAGE_STAB)
			M.UpdateDamageIcon()
			return TRUE
		else
			return FALSE

	Eat(mob/M, mob/user, by_matter_eater)
		. = ..()
		M.emote("scream")
		M.TakeDamage("chest", 25, 0, 0, DAMAGE_CUT)
		M.visible_message("\The [src] tears a bunch of gore out of [M.name]!")
		if (M.bioHolder && M.bioHolder.Uid && M.bioHolder.bloodType)
			gibs(M.loc, blood_DNA=M.bioHolder.Uid, blood_type=M.bioHolder.bloodType, headbits=FALSE, source=M)
		else
			gibs(M.loc, headbits=FALSE, source=M)
		var/mob/living/carbon/human/H = M
		if (istype(H))
			if (H.organHolder)
				for(var/organ in list("right_kidney", "left_kidney", "liver", "stomach", "intestines", "spleen", "pancreas"))
					var/obj/item/organ/O = H.drop_organ(organ, M.loc)
					if (istype(O))
						O.throw_at(src.rod.loc, rand(3,6), rand(1,2))
		qdel(src)

	disposing()
		src.rod.lure = null
		. = ..()

//action (with bar) for reeling in a mob with the Glaucus
/datum/action/bar/syndie_fishing
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/mob/user = null
	var/mob/target = null
	/// what fishing rod caught the mob
	var/obj/item/syndie_fishing_rod/rod = null
	/// what lure is snagged in the mob
	var/obj/item/syndie_lure/lure = null
	/// stores current damage per point blank reel and increases by 3 each cycle that target isnt point blank
	/// resets when damage is dealt
	var/damage_on_reel = 7
	/// how long a step of reeling takes, set onStart
	duration = 0
	/// id for fishing action

	New(var/user, var/target, var/rod, var/lure)
		..()
		src.user = user
		src.target = target
		src.rod = rod
		src.lure = lure

	onStart()
		..()

		src.duration = max(0.1 SECONDS, rod.syndie_fishing_speed)
		playsound(src.user, 'sound/items/fishing_rod_cast.ogg', 50, 1)
		APPLY_ATOM_PROPERTY(src.target, PROP_MOB_CANTSPRINT, src)
		APPLY_MOVEMENT_MODIFIER(src.target, /datum/movement_modifier/syndie_fishing, src)
		src.user.visible_message("[src.user] sets the hook!")
		src.rod.is_fishing = TRUE
		src.rod.UpdateIcon()
		src.user.update_inhands()

	onEnd()
		..()
		src.canRunCheck()

		if (src.rod.reel_in(src.target, src.user, src.damage_on_reel))
			src.damage_on_reel = initial(src.damage_on_reel)
		else
			src.damage_on_reel += 3
		src.onRestart()

	onDelete()
		..()
		src.rod.is_fishing = FALSE
		src.rod.UpdateIcon()
		src.user.update_inhands()
		if (src.lure.owner)
			src.lure.set_loc(get_turf(src.lure.loc))
			src.lure.owner = null
		REMOVE_ATOM_PROPERTY(src.target, PROP_MOB_CANTSPRINT, src)
		REMOVE_MOVEMENT_MODIFIER(src.target, /datum/movement_modifier/syndie_fishing, src)

	canRunCheck(in_start)
		..()
		if (!src.user || !src.target || !src.rod || !src.lure || (src.target == src.user) || !(src.lure.loc == src.target) || !(src.user.equipped() == src.rod) || !isturf(src.user.loc))
			interrupt(INTERRUPT_ALWAYS)
			return
