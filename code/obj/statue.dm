/obj/statue
	anchored = UNANCHORED
	density = 1
	layer = MOB_LAYER
	_max_health = 10
	var/custom_desc
	// The material that the statue consists of, as well as what its contents turn into
	var/statue_material = "steel"
	// The mob inside of the statue
	var/mob/mob_inside
	// In case we want to free the mob after entrapping them, for statues that encase, rather than turn into a material
	var/preserve_mob = FALSE
	// List of organs we want to drop when we release the occupant
	var/list/organs_to_drop = list("brain")

	gold
		name = "gold statue"
		statue_material = "gold"

	ice
		name = "ice statue"
		custom_desc = "We here at Space Station 13 believe in the transparency of our employees."
		statue_material = "ice"

	rock
		name ="rock statue"
		custom_desc = "It's not too uncommon for our employees to be stoned at work but this is just ridiculous!"
		statue_material = "rock"

	proc/setup_statue(var/mob/M, var/mat_id, var/new_desc)
		if (!istype(M))
			return
		src.mob_inside = M
		src.appearance = src.mob_inside.appearance
		src.real_name = "statue of [src.mob_inside.name]"
		src.name = src.real_name

		var/datum/material/stat_mat = mat_id ? getMaterial(mat_id) : src.statue_material
		if (stat_mat)
			src.setMaterial(stat_mat)

		src.set_desc(new_desc)
		src.set_dir(src.dir)

	proc/set_desc(var/new_desc)
		if(new_desc)
			src.desc = new_desc
		else
			src.desc = src.get_statue_text()

	proc/get_statue_text()
		if (src.custom_desc) return src.custom_desc
		. = "A statue made of [src.material] to [pick("commemorate","honor","praise","celebrate","commend","aggrandize","exalt")] "
		. += "the [pick("outstanding","astounding","incredible","awesome","amazing","wonderful")] "
		. += "[pick("deeds","inventions","feats","achievements","accomplishments","exploits","creations")] of "
		. += "[src.mob_inside.name] in the year "
		. += "[(CURRENT_SPACE_YEAR - rand(0, 50))].<br>"
		. += "Actually, never mind. It's just someone turned to [src.material]."

	examine(mob/user)
		. = ..()
		switch(src._health/src._max_health)
			if (0.6 to 0.9)
				. += SPAN_ALERT("It is a little bit damaged.")
			if (0.3 to 0.6)
				. += SPAN_ALERT("It looks pretty beaten up.")
			if (0 to 0.3)
				. += SPAN_ALERT("<b>It seems to be on the verge of falling apart!</b>")

	attackby(obj/item/W, mob/user)
		// Anything sufficiently hard, like rock, can be mined
		if (istype(W, /obj/item/mining_tool))
			src.mine_statue(W, user)
			return
		// Otherwise, it's probably soft enough to cut
		if (iscuttingtool(W) || issawingtool(W) || ischoppingtool(W))
			var/hardness = src.material.getProperty("hard")
			if (hardness < 2)
				boutput(user, SPAN_ALERT("The [src.material] is too hard to cut!"))
				return

			if(isliving(src.mob_inside))
				var/mob/living/L = src.mob_inside
				if (L.organHolder.head)
					boutput(user, SPAN_ALERT("You start cutting up [src]."))
			else
				boutput(user, SPAN_ALERT("You start cutting the head off of [src]."))
			playsound(user, 'sound/impact_sounds/Flesh_Cut_1.ogg', 50, TRUE)
			if (isalive(src.mob_inside))
				src.mob_inside.emote("scream")
			SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/statue/proc/cut_statue, list(user), W.icon, W.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
			return
		// Wow I love jank solutions in order to call temperature_expose on my object!!!!
		// Seriously, it would be cool if every firesource knew it's own burn_temp or something
		if (W.firesource)
			src.temperature_expose(null, 1000)
			return

	attack_hand(var/mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/C = H.gloves
				src.mine_statue(C.tool, user)
				return
		..()

	proc/mine_statue(var/obj/item/mining_tool/tool, var/mob/user)
		var/hardness = src.material.getProperty("hard")
		if (hardness < 2)
			boutput(user, SPAN_ALERT("The [src.material] is too soft to mine!"))
			return
		if(!ON_COOLDOWN(user, "mine_statue", 0.5 SECONDS))
			var/obj/item/mining_tool/mining_tool = tool
			var/digstr = mining_tool.get_dig_strength()
			var/minedifference = hardness - digstr

			playsound(user, mining_tool.get_mining_sound(), 50, 1)

			// Mimic mining behavior for maximum IMMERSION
			var/dig_chance = 100
			var/dig_feedback = "[src] is not very tough. This will be fast."
			switch(minedifference)
				if (1)
					dig_chance = 30
					dig_feedback = "[src] is tough. You may need a stronger tool."
				if (2)
					dig_chance = 10
					dig_feedback = "[src] is very tough. You'll be faster with a stronger tool."
				if (3 to INFINITY)
					dig_chance = 0
					dig_feedback = "You can't even make a dent in [src]! You need a stronger tool."

			if (prob(dig_chance))
				src.changeHealth(-digstr)
			hit_twitch(src)
			boutput(user, SPAN_ALERT("[dig_feedback]"))

	Exited(atom/movable/AM, atom/newloc)
		. = ..()
		if(!src.preserve_mob && AM == src.mob_inside)
			src.mob_inside.death(TRUE)

	ex_act(severity)
		if(severity == 1)
			if (isalive(src.mob_inside))
				src.mob_inside.emote("scream")
				src.mob_inside.emote("faint")
				src.mob_inside.remove()
			src.mob_inside = null
			src.visible_message(SPAN_ALERT("<b>[src] shatters into a million tiny pieces!</b>"))
			dothepixelthing(src)

	/// Deal some damage when flipping, in case someone's stuck and nobody else is around
	mob_flip_inside(var/mob/user)
		src.changeHealth(-1)
		..()

	onDestroy()
		src.make_material_chunk()
		qdel(src)

	disposing()
		src.visible_message(SPAN_ALERT("<b>[src] breaks apart!</b>"))
		src.free_occupant()
		src.drop_organs()
		src.cleanup_occupant()
		. = ..()

	/// Proc to cut off head to grab the brain, otherwise cuts the statue to pieces
	proc/cut_statue()
		if (!src.mob_inside)
			src.make_material_chunk()
			qdel(src)
			return
		src.mob_inside.death(TRUE)
		src.organs_to_drop.Remove("brain")
		src.organs_to_drop.Add("head")
		src.drop_organs()

	/// Proc to throw out the mob inside
	proc/free_occupant()
		if (!src.mob_inside)
			return

		if (src.preserve_mob)
			MOVE_OUT_TO_TURF_SAFE(src.mob_inside, src)
			src.mob_inside = null
			return

	/// Proc to drop a list of organs from the mob inside
	proc/drop_organs()
		if (!isliving(src.mob_inside))
			return

		var/mob/living/L = src.mob_inside
		for (var/organ in src.organs_to_drop)
			var/turf/T = get_turf(src)
			var/obj/item/organ/O = L.organHolder.drop_organ(organ, T)

			if(istype(O))
				O.setMaterial(src.material) // Because why not, it's funny
				O.decal_done = TRUE // Remove the decal because it looks weird

			if(istype(O, /obj/item/organ/head))
				// If we cut the head off, we need to update the appearance
				var/obj/item/organ/head/noggin = O
				src.appearance = L.appearance
				src.real_name = "headless [src.real_name]"
				src.name = src.real_name
				src.setMaterial(src.material)
				noggin.brain.setMaterial(src.material)
				noggin.brain.decal_done = TRUE

	/// Proc to generate a material from the statue
	proc/make_material_chunk()
		var/turf/T = get_turf(src)
		var/obj/item/raw_material/chunk = new /obj/item/raw_material(src)
		chunk.set_loc(T)
		chunk.setMaterial(src.material)
		chunk.name = "[chunk.material.getName()] chunk"
		chunk.desc = chunk.material.getDesc()
		return chunk

	/// Remove (read: kill and delete) the mob inside this statue
	proc/cleanup_occupant()
		if (src.mob_inside)
			boutput(src.mob_inside, SPAN_ALERT("Some kind of force rips your statue-bound body apart."))
			src.mob_inside.remove()
			src.mob_inside = null

/mob/proc/become_statue(var/mat_id, var/new_desc = null, survive=FALSE)
	var/statue_type = /obj/statue
	switch(mat_id)
		if ("gold")
			statue_type = /obj/statue/gold
		if ("ice")
			statue_type = /obj/statue/ice
		if ("rock")
			statue_type = /obj/statue/rock
	var/obj/statue/statueperson = new statue_type(get_turf(src))

	src.pixel_x = 0
	src.pixel_y = 0
	src.set_loc(statueperson)

	// Kill the person inside
	if(!survive)
		src.death(TRUE)
	src.canmove = FALSE
	src.transforming = FALSE

	statueperson.setup_statue(src, mat_id, new_desc)

	return statueperson
