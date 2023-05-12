#define GEN_ANODE 1
#define GEN_CATHODE 2

#define UNIT_OPEN 0
#define UNIT_INACTIVE 1
#define UNIT_ACTIVE 2

/obj/decal/fakeobjects/catalytic_doodad
	name = "catalytic generator pipe"
	desc = "Pipe section allowing a catalytic rod to contact outside fluid for catalysis."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "doodad"
	anchored = ANCHORED

/obj/machinery/power/catalytic_generator
	name = "catalytic generator core"
	desc = "Harnesses catalysts' reactions with a large body of appropriate fluid to generate electricity."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "core"
	anchored = ANCHORED
	density = 1

	var/obj/machinery/catalytic_rod_unit/anode_unit
	var/obj/machinery/catalytic_rod_unit/cathode_unit

	///Generation rate, determined by the least effective rod between the two inserted rods
	var/gen_rate = 0
	///Integer for picking an overlay icon state, determined by gen_rate during process
	var/output_tier = 0
	//Attached light
	var/datum/light/light

	var/sound_grump = 'sound/machines/buzz-two.ogg'

	New()
		..()
		START_TRACKING

		light = new /datum/light/point
		light.attach(src)

		SPAWN(0.5 SECONDS)
			src.anode_unit = locate(/obj/machinery/catalytic_rod_unit) in get_step(src,WEST)
			src.cathode_unit = locate(/obj/machinery/catalytic_rod_unit) in get_step(src,EAST)
			if(!src.anode_unit || !src.cathode_unit)
				src.status |= BROKEN

			UpdateIcon()

	disposing()
		STOP_TRACKING
		src.anode_unit = null
		src.cathode_unit = null
		..()

	attack_hand(mob/user,var/bot_operated)
		if(!src.anode_unit || !src.cathode_unit)
			boutput(user,"\The [src] doesn't seem to be operable.")
			return

		if(src.anode_unit.toggling || src.cathode_unit.toggling)
			boutput(user,"\The [src] doesn't respond to your input.")
			return

		if(src.anode_unit.mode == UNIT_OPEN && src.cathode_unit.mode == UNIT_OPEN)
			src.anode_unit.update_mode(UNIT_INACTIVE)
			src.cathode_unit.update_mode(UNIT_INACTIVE)
			boutput(user,"You [bot_operated ? "send a toggle signal to" : "press the front button on"] [src]. The catalytic rod units close for operation.")
			return
		else
			src.anode_unit.update_mode(UNIT_OPEN)
			src.cathode_unit.update_mode(UNIT_OPEN)
			boutput(user,"You [bot_operated ? "send a toggle signal to" : "press the front button on"] [src]. The catalytic rod units open up.")
			return

	attack_ai(mob/user)
		return attack_hand(user,TRUE)

	update_icon()
		if(status & NOPOWER)
			UpdateOverlays(null, "power")
		else if(status & BROKEN)
			UpdateOverlays(image('icons/obj/power.dmi', "teg-err"), "power")
		else
			if(output_tier != 0)
				UpdateOverlays(image('icons/obj/power.dmi', "teg-op[output_tier]"), "power")
			else
				UpdateOverlays(null, "power")

		switch (output_tier)
			if(0)
				light.disable()
			if(1 to 12)
				light.set_color(1, 1, 1)
				light.set_brightness(0.3)
			if(13 to INFINITY)
				light.set_color(1, 1, 1)
				light.set_brightness(0.6)
				light.enable()

	process(mult)

		gen_rate = 0
		output_tier = 0

		if(!src.anode_unit || !src.cathode_unit)
			UpdateIcon()
			return

		if(src.anode_unit.mode == UNIT_OPEN || src.cathode_unit.mode == UNIT_OPEN)
			UpdateIcon()
			return

		if(src.anode_unit.toggling || src.cathode_unit.toggling)
			UpdateIcon()
			return

		var/obj/anode_rod = src.anode_unit.contained_rod
		var/obj/cathode_rod = src.cathode_unit.contained_rod

		if(!anode_rod || !cathode_rod)
			src.visible_message("<span class='alert'>[src] shuts down due to an insufficient rod configuration.</span>")
			playsound(src.loc, sound_grump, 50, 0)
			src.anode_unit.update_mode(UNIT_OPEN)
			src.cathode_unit.update_mode(UNIT_OPEN)
			UpdateIcon()
			return

		src.anode_unit.update_mode(UNIT_ACTIVE)
		src.cathode_unit.update_mode(UNIT_ACTIVE)

		if(!(src.status & BROKEN))
			var/anode_level = src.anode_unit.use_rod()
			var/cathode_level = src.cathode_unit.use_rod()
			if(!anode_level || !cathode_level)
				src.visible_message("<span class='alert'>[src] shuts down due to insufficient rod efficacy.</span>")
				playsound(src.loc, sound_grump, 50, 0)
				if(!anode_level) src.anode_unit.update_mode(UNIT_OPEN)
				if(!cathode_level) src.cathode_unit.update_mode(UNIT_OPEN)
				UpdateIcon()
				return
			gen_rate = min(anode_level,cathode_level)
			add_avail(gen_rate WATTS)

		desc = "Current Output: [engineering_notation(gen_rate)]W"
		if(gen_rate < 110000 WATTS)
			output_tier = clamp(round(gen_rate/10000), 0, 10)
		else
			switch(gen_rate)
				if(110000 to 250000)
					output_tier = 11
				if(250001 to 500000)
					output_tier = 12
				if(500001 to INFINITY)
					output_tier = 13

		UpdateIcon()

/obj/machinery/catalytic_rod_unit
	name = "catalytic rod unit"
	desc = "Accepts a rod of catalytic material for use in electricity generation."
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "nonvis"
	anchored = ANCHORED
	density = 1

	//Overlay objects
	var/obj/overlay/ovr_door
	var/obj/overlay/ovr_rod
	var/obj/overlay/ovr_clamp

	///Directionality to be given to overlays; should be 4 for right unit and 8 for left
	var/overlay_dir = 1
	///Rod condition reference for overlay; should update when rod is expended
	var/rod_condition = 100
	///Rod viability reference for overlay; should update when rod is installed, based on viability for the unit type
	var/rod_viability = 100
	///What type of unit this is; used for viability calculation
	var/gentype = GEN_ANODE

	///Possible modes: open (rod clamp exposed and load/unloadable), inactive (clamp squared away, whether a rod is inserted or not), active (active)
	var/mode = UNIT_INACTIVE
	///Oldmode: update_icon uses this for reference purposes
	var/oldmode = UNIT_INACTIVE
	///True while toggling between modes
	var/toggling = FALSE
	///Rod contained within the rod units
	var/obj/item/catalytic_rod/contained_rod

	left
		name = "catalytic anode unit"
		icon_state = "base-l"
		overlay_dir = 8
		gentype = GEN_ANODE

		populated
			contained_rod = new /obj/item/catalytic_rod/anode_default

	right
		name = "catalytic cathode unit"
		icon_state = "base-r"
		overlay_dir = 4
		gentype = GEN_CATHODE

		populated
			contained_rod = new /obj/item/catalytic_rod/cathode_default

	New()
		..()
		src.ovr_door = new /obj/overlay/rod_unit_door
		src.ovr_rod = new /obj/overlay/rod_unit_rod
		src.ovr_clamp = new /obj/overlay/rod_unit_clamp
		src.ovr_door.dir = src.overlay_dir
		src.ovr_rod.dir = src.overlay_dir
		src.ovr_clamp.dir = src.overlay_dir
		src.vis_contents += src.ovr_door
		src.vis_contents += src.ovr_rod
		src.vis_contents += src.ovr_clamp

		if(src.contained_rod)
			src.rod_post_install()

	disposing()
		qdel(src.ovr_door)
		qdel(src.ovr_rod)
		qdel(src.ovr_clamp)
		qdel(src.contained_rod)
		..()

	attack_hand(mob/user,var/ejected_by_bot)
		if(src.mode == UNIT_OPEN)
			if(src.contained_rod)
				if(src.toggling) return
				boutput(user, "<span class='notice'>You [ejected_by_bot ? "eject" : "remove"] \the [contained_rod] from [src]'s retention clamp.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)
				src.contained_rod.UpdateIcon()
				if(ejected_by_bot)
					src.contained_rod.set_loc(src.loc)
				else
					user.put_in_hand_or_drop(src.contained_rod)
				src.contained_rod = null
				src.ovr_rod.icon_state = "nonvis"
			else
				boutput(user,"\The [src] is open. Its retention clamp seems to be missing a rod of some sort.")
		else
			boutput(user,"\The [src] doesn't seem to have any controls.")

	attack_ai(mob/user)
		return attack_hand(user,TRUE)

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if(src.mode == UNIT_OPEN && istype(I,/obj/item/catalytic_rod))
			if(!src.contained_rod)
				if(src.toggling) return
				boutput(user, "<span class='notice'>You insert \the [I] into [src]'s retention clamp.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)

				user.u_equip(I)
				I.set_loc(src)
				src.contained_rod = I
				src.rod_post_install()
				return
			else
				boutput(user,"\The [src] already has a rod installed.")
		else
			..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if(!isliving(user))
			boutput(user, "<span class='alert'>Your tether to the mortal realm is insufficient for rod loading.</span>")
			return

		if(!can_act(user))
			return

		if (!in_interact_range(src,user))
			boutput(user, "<span class='alert'>You are too far away to do that.</span>")
			return

		if (!in_interact_range(src,O))
			boutput(user, "<span class='alert'>[O] is too far away to do that.</span>")
			return

		if (src.mode == UNIT_OPEN && istype(O,/obj/item/catalytic_rod) && isturf(O.loc))
			if(!src.contained_rod)
				if(src.toggling) return
				boutput(user, "<span class='notice'>You insert \the [O] into [src]'s retention clamp.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 40, 1)

				O.set_loc(src)
				src.contained_rod = O
				src.rod_post_install()
			else
				boutput(user,"\The [src] already has a rod installed.")

	proc/rod_post_install()
		if(src.contained_rod)
			switch(src.gentype)
				if(GEN_ANODE)
					src.rod_viability = src.contained_rod.anode_viability
				if(GEN_CATHODE)
					src.rod_viability = src.contained_rod.cathode_viability
			src.ovr_rod.color = src.contained_rod.color
			if(src.mode == UNIT_OPEN)
				src.ovr_rod.icon_state = "rod-high"
		else
			src.rod_viability = 0

	proc/use_rod(var/expend_type)
		. = src.contained_rod.expend_rod(src.gentype)
		src.indicator_update()

	proc/update_mode(var/newmode)
		if(newmode == src.oldmode)
			return
		src.mode = newmode
		src.toggling = TRUE
		src.mode_update_sequencing()

	proc/mode_update_sequencing() //sweet holy jebus what have I done
		if(src.mode == UNIT_OPEN && src.oldmode != UNIT_OPEN)

			src.indicator_update()

			src.ovr_door.icon_state = "nonvis"
			flick("door-open",src.ovr_door)
			playsound(src, 'sound/machines/sleeper_open.ogg', 40, 1)

			if(src.contained_rod)
				src.ovr_rod.icon_state = "rod-high"
				flick("rod-raise-[src.dir]",src.ovr_rod)

			src.ovr_clamp.icon_state = "clamp-high"
			flick("clamp-raise-[src.dir]",src.ovr_clamp)

			SPAWN(1.6 SECONDS)
				src.toggling = FALSE

		else if(src.mode == UNIT_INACTIVE && src.oldmode == UNIT_OPEN)

			if(src.contained_rod)
				src.ovr_rod.icon_state = "nonvis"
				flick("rod-lower-[src.dir]",src.ovr_rod)

			src.ovr_clamp.icon_state = "nonvis"
			flick("clamp-lower-[src.dir]",src.ovr_clamp)

			SPAWN(1 SECOND)

				src.ovr_door.icon_state = "door-shut"
				flick("door-close",src.ovr_door)
				playsound(src, 'sound/machines/sleeper_close.ogg', 40, 1)

				SPAWN(0.6 SECONDS)

					src.toggling = FALSE
					src.indicator_update()

		else
			if(src.mode != src.oldmode)
				src.indicator_update()
			src.toggling = FALSE

		src.oldmode = src.mode


	proc/indicator_update()
		if(src.mode != UNIT_OPEN && src.contained_rod && powered())
			var/dirbop = "r"
			if(src.gentype == GEN_ANODE) dirbop = "l"

			var/cond_base = src.contained_rod.condition
			var/cond_ratio = min(round(cond_base, 20)+20,100)
			var/image/conditioning = SafeGetOverlayImage("condition", 'icons/obj/machines/catalysis.dmi', "condition-[cond_ratio]-[dirbop]")
			conditioning.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(conditioning, "condition", 0, 1)

			var/via_ratio = clamp(round(src.rod_viability * cond_base * 0.01,10),0,150)
			var/image/viability = SafeGetOverlayImage("viability", 'icons/obj/machines/catalysis.dmi', "via-[via_ratio]-[dirbop]")
			viability.plane = PLANE_OVERLAY_EFFECTS
			UpdateOverlays(viability, "viability", 0, 1)

		else
			ClearSpecificOverlays("viability","condition")

	///Reports installed rod's efficacy (effective power output multiplier) for use by external sources (currently power checker pda program)
	proc/report_efficacy()
		. = 0
		var/cond_base = src.contained_rod.condition
		switch(src.gentype)
			if(GEN_ANODE)
				. = round(src.contained_rod.anode_efficacy * cond_base * 0.01)
			if(GEN_CATHODE)
				. = round(src.contained_rod.cathode_efficacy * cond_base * 0.01)


/obj/overlay/rod_unit_door
	name = "rod door"
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "door-shut"
	layer = 3.3
	mouse_opacity = 0

/obj/overlay/rod_unit_rod
	name = "rod slot"
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "nonvis"
	layer = 3.2
	mouse_opacity = 0

/obj/overlay/rod_unit_clamp
	name = "rod clamp"
	icon = 'icons/obj/machines/catalysis.dmi'
	icon_state = "nonvis"
	layer = 3.1
	mouse_opacity = 0


/obj/item/catalytic_rod
	name = "catalytic rod"
	desc = "Rod of material extruded in a suitable form for catalytic electrical generation. Hopefully it's good for that."
	icon = 'icons/obj/machines/catalysis.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "roditem-100"
	item_state = "rods"
	rand_pos = TRUE
	///Rod condition: decays over time, combines with generation efficacy to yield a production rate
	var/condition = 100
	///Generation efficacy for anode use. Influenced by material properties, increases dramatically above standard parameters
	var/anode_efficacy = 0
	///Generation efficacy for cathode use. Influenced by material properties, increases dramatically above standard parameters
	var/cathode_efficacy = 0
	//Base viability before any efficacy exponentiation
	var/anode_viability = 0
	var/cathode_viability = 0

	///Decay ratio: how fast rod will fall apart. Influenced by material corrosion resistance
	var/decay_ratio = 0.998

	anode_default
		name = "catalytic anode rod"
		desc = "Rod of material extruded in a suitable form for catalytic electrical generation. It's stamped on one end with an indicative symbol."
		New()
			var/datum/material/M = getMaterial("copper")
			src.setMaterial(M)
			src.setupMaterial()
			..()

	cathode_default
		name = "catalytic cathode rod"
		desc = "Rod of material extruded in a suitable form for catalytic electrical generation. It's stamped on one end with an indicative symbol."
		New()
			var/datum/material/M = getMaterial("steel")
			src.setMaterial(M)
			src.setupMaterial()
			..()

	//you should only be able to make these from things with a metal material flag
	proc/setupMaterial()
		///Corrosion resistance slows decay per cycle by an amount proportional to resistance percentage. Total corrosion immunity = no decay.
		var/decay_ratio_adjustment = src.material.getProperty("chemical") * 0.00023
		src.decay_ratio = min(src.decay_ratio + decay_ratio_adjustment,1)
		src.anode_viability = max(0,src.material.getProperty("electrical") * 17)
		if(src.material.material_flags & MATERIAL_ENERGY && src.anode_viability)
			src.anode_viability = round(src.anode_viability * 1.3)
		var/cathode_density_factor = 180 - (abs(5-src.material.getProperty("density")) * 45)
		var/cathode_hardness_factor = 100 - (abs(5-src.material.getProperty("hard")) * 12)
		src.cathode_viability = round(cathode_density_factor * cathode_hardness_factor * 0.01)

		//Apply efficacy multiplier to viability. increases in parameters beyond standard exponentially increase the base efficacy
		if(src.anode_viability > 100)
			src.anode_efficacy = 100 * ((0.01 * src.anode_viability) ** 4)
		else
			src.anode_efficacy = src.anode_viability
		if(src.cathode_viability > 100)
			src.cathode_efficacy = 100 * ((0.01 * src.cathode_viability) ** 4)
		else
			src.cathode_efficacy = src.cathode_viability

	///Consumes rod condition in furtherance of electrical generation; pass anode or cathode use for appropriate effectiveness factor
	proc/expend_rod(var/expend_type)
		. = FALSE //If rod is so ineffective in role as to yield no generation whatsoever, generator should abort operation
		switch(expend_type)
			if(GEN_ANODE)
				. = round(src.condition * src.anode_efficacy * 10)
				src.condition = src.condition * src.decay_ratio
			if(GEN_CATHODE)
				. = round(src.condition * src.cathode_efficacy * 10)
				src.condition = src.condition * src.decay_ratio
		return

	update_icon()
		..()
		var/ratio = min(round(condition, 20)+20,100)
		src.icon_state = "roditem-[ratio]"

	examine()
		. = ..()
		var/ratio = min(round(condition, 20)+20,100) //ensure parity with visual decay tiers
		var/conditiondesc = "pretty intact"
		switch(ratio)
			if(20)
				conditiondesc = "almost completely corroded"
			if(40)
				conditiondesc = "heavily corroded"
			if(60)
				conditiondesc = "moderately corroded"
			if(80)
				conditiondesc = "a bit corroded"

		. += "\n It seems to be [conditiondesc]."


#undef UNIT_OPEN
#undef UNIT_INACTIVE
#undef UNIT_ACTIVE

#undef GEN_ANODE
#undef GEN_CATHODE

/datum/matfab_recipe/catarod
	name = "Catalytic Generation Rod"
	desc = "A rod with a form factor suitable for usage in a catalytic generator. Material composition affects its performance."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Rod"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i in 1 to amount)
			var/obj/item/catalytic_rod/newObj = new()
			var/obj/item/source = getObjectByPartName("Rod")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.setupMaterial()
			newObj.set_loc(getOutputLocation(owner))
