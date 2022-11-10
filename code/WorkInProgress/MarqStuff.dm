// The day has come when this warps into existence.
// Dear god, imagine the horrors that will soon lurk in here.

/proc/chs(var/str, var/i)
	return ascii2text(text2ascii(str,i))

// TODO: Variable processing.

#define NONE 0
#define APOS 1
#define QUOT 2

#define ESCAPE "\\"

/**
 * BASH explode: Splits a string into string pieces the same way BASH handles this.
 *
 * - Process quoted strings LTR: Apostrophized strings are unparsed. Quoted strings are parsed.
 * - Insert parsed strings back into the string by using a placeholder for spaces.
 * - Split the string with the usual space separation method.
 * - Return list.
 */
/proc/bash_explode(var/str)
	var/fin = 0
	var/state = NONE
	var/pos = 1
	var/qpos = 1
	var/buf = ""
	while (!fin)
		switch(state)
			if (NONE)
				var/NA = findtext(str, "'", pos)
				var/NQ = findtext(str, "\"", pos)
				if (!NA && !NQ)
					buf += copytext(str, pos)
					fin = 1
				else if (NA && !NQ || (NA && NQ && NA < NQ))
					if (chs(str, NA - 1) == ESCAPE)
						buf += copytext(str, pos, NA - 1) + "'"
						pos = NA + 1
						continue
					else
						buf += copytext(str, pos, NA)
						pos = NA + 1
						state = APOS
				else if (NQ && !NA || (NA && NQ && NQ < NA))
					if (chs(str, NQ - 1) == ESCAPE)
						buf += copytext(str, pos, NQ - 1) + "\""
						pos = NQ + 1
						continue
					else
						buf += copytext(str, pos, NQ)
						pos = NQ + 1
						qpos = NQ + 1
						state = QUOT
				else if (NA == NQ)
					//??????
					return null

			if (APOS)
				var/NA = findtext(str, "'", pos)
				if (!NA)
					return null
				var/temp = copytext(str, pos, NA)
				buf += replacetext(temp, " ", "&nbsp;")
				pos = NA + 1
				state = NONE

			if (QUOT)
				var/NQ = findtext(str, "\"", pos)
				if (!NQ)
					return null
				if (copytext(str, NQ - 1, NQ) == ESCAPE)
					pos = NQ + 1
					continue
				var/temp = copytext(str, qpos, NQ)
				buf += replacetext(replacetext(temp, " ", "&nbsp;"), "\\\"", "\"")
				pos = NQ + 1
				state = NONE

	var/list/el = splittext(buf, " ")
	var/list/ret = list()
	for (var/s in el)
		ret += replacetext(s, "&nbsp;", " ")
	return ret

#undef ESCAPE
#undef QUOT
#undef APOS
#undef NONE

/proc/bash_sanitize(var/data)
	var/list/allowed_chars = list(" ")
	var/ret = ""
	var/lgp = 0
	for (var/i = 1, i <= length(data), i++)
		var/char = text2ascii(data, i)
		var/ord = ascii2text(char)
		if ((65 <= char && char <= 90) || (97 <= char && char <= 122) || (ord in allowed_chars))
			if (lgp == 0)
				lgp = i
			continue
		if (lgp == 0)
			continue
		ret += copytext(data, lgp, i)
		lgp = 0
	if (lgp)
		ret += copytext(data, lgp)
	return ret


/obj/nerd_trap_door
	name = "Heavily locked door"
	desc = "Man, whatever is in here must be pretty valuable. This door seems to be indestructible and features an unrealistic amount of keyholes."
	var/list/expected = list("silver key", "skeleton key", "cold steel key", "literal skeleton key", "hot iron key", "onyx key", "virtual key", "golden key", "iron key", "iridium key", "lunar key")
	var/list/unlocked = list()
	var/list/ol = list()
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "hld0"
	opacity = 1
	density = 1
	anchored = 1

	examine()
		. = ..()
		. += "Your keen skills of observation tell you that [expected.len - unlocked.len] out of the [expected.len] locks are locked."

	attackby(var/obj/item/I, var/mob/user)
		if (istype(I, /obj/item/device/key))
			var/kname = null
			if (I.name in expected)
				kname = I.name
			//for (var/N in expected)
			//	if (dd_hasprefix(I.name, N))
			//		break
			if (kname)
				boutput(user, "<span class='notice'>You insert the [I.name] into the [kname]hole and turn it. The door emits a loud click.</span>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 60, 1)
				if (kname in unlocked)
					unlocked -= kname
					overlays -= ol[kname]
					ol -= kname
				else
					unlocked += kname
					var/image/IM = image('icons/misc/aprilfools.dmi', "[kname]hole")
					ol[kname] = IM
					overlays += IM
			else
				boutput(user, "<span class='alert'>You cannot find a matching keyhole for that key!</span>")
		else if (istype(I, /obj/item/reagent_containers/food/snacks/pie/lime))
			if ("key lime pie" in expected)
				boutput(user, "<span class='notice'>You insert the [I.name] into the key lime piehole and turn it. The door emits a loud click.</span>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 60, 1)
				if ("key lime pie" in unlocked)
					unlocked -= "key lime pie"
					overlays -= ol["key lime pie"]
					ol -= "key lime pie"
				else
					unlocked += "key lime pie"
					var/image/IM = image('icons/misc/aprilfools.dmi', "key lime piehole")
					ol["key lime pie"] = IM
					overlays += IM
			else
				boutput(user, "<span class='alert'>You cannot find a matching keyhole for that key!</span>")

	Bumped(var/mob/M)
		if (!istype(M))
			return
		attack_hand(M)

	attack_hand(var/mob/user)
		if (!density)
			return
		if (unlocked.len == expected.len)
			open()
		else
			boutput(user, "<span class='alert'>The door won't budge!</span>")

	proc/open()
		if (unlocked.len != expected.len)
			return
		playsound(src.loc, 'sound/machines/door_open.ogg', 50, 1)
		icon_state = "hld1"
		set_density(0)
		set_opacity(0)
		overlays.len = 0

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/nerd_trap_door/voidoor
	name = "V O I D O O R"
	desc = "This door cannot be returned. You see, the warranty is void."
	expected = list("silver key", /*"skeleton key",*/ /*"literal skeleton key",*/ "hot iron key", "cold steel key", "onyx key", /*"key lime pie",*/ /*"futuristic key"*/, /*"virtual key",*/ "golden key", "bee key", "iron key", /*"iridium key",*/ "lunar key")
	icon_state = "hld2"

/obj/steel_beams
	name = "steel beams"
	desc = "A bunch of unfortunately placed, tightly packed steel beams. You cannot get a meaningful glimpse of what's on the other side."
	anchored = 1
	density = 1
	opacity = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "beams"

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/faint_shimmer
	name = "faint shimmer"
	desc = "Huh."
	anchored = 1
	density = 0
	invisibility = INVIS_CLOAK
	blend_mode = 4
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "noise5"
	var/decloaked_type = /obj/item/storage/toilet

	dense
		density = 1

// Aiming bow action.
/datum/action/bar/aim
	duration = -1
	var/obj/item/gun/bow/bow = null
	var/progress = 0
	var/progression = 0.34
	var/moved = 0

	New(var/mob/M, var/obj/item/gun/bow/B)
		owner = M
		bow = B
		..()

	onStart()
		..()
		playsound(owner, 'sound/effects/bow_aim.ogg', 75, 1)
		owner.visible_message("<span class='alert'>[owner] pulls the string on [bow]!</span>", "<span class='notice'>You pull the string on [bow]!</span>")

	onDelete()
		if (bow)
			bow.aim = null
		..()

	onEnd()
		boutput(owner, "<span class='alert'>You let go of the string.</span>")
		if (bow)
			bow.aim = null
		..()

	interrupt(var/flag)
		if(flag == INTERRUPT_MOVE)
			moved = 1
			return
		..()


	onUpdate()
		if (moved)
			progress += (progression/2)
		else
			progress +=progression
		progress = min(1,progress)
		moved = 0

		var/complete = progress
		bar.color = "#0000FF"
		bar.transform = matrix(complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * complete)) / 2) )

/obj/item/arrow
	name = "steel-headed arrow"
	icon = 'icons/obj/items/items.dmi'
	icon_state = null
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	// placeholder
	var/datum/material/head_material
	var/datum/material/shaft_material
	var/image/shaft
	var/image/head
	amount = 1
	max_stack = 50
	appearance_flags = RESET_COLOR | RESET_ALPHA | LONG_GLIDE | PIXEL_SCALE
	move_triggered = 1

	New()
		..()
		shaft = image(icon, "arrow_base")
		head = image(icon, "arrow_head")
		reagents = new /datum/reagents(3)
		reagents.my_atom = src
		overlays += shaft
		overlays += head

	check_valid_stack(atom/movable/O as obj)
		if(!istype(O, /obj/item/arrow)) return 0
		var/obj/item/arrow/A = O

		if(A.head_material && src.head_material)
			if(!isSameMaterial(A.head_material, src.head_material))
				return 0
		else if ((A.head_material && !src.head_material) || (!A.head_material && src.head_material))
			return 0

		if(A.shaft_material && src.shaft_material)
			if(!isSameMaterial(A.shaft_material, src.shaft_material))
				return 0
		else if ((A.shaft_material && !src.shaft_material) || (!A.shaft_material && src.shaft_material))
			return 0

		return 1

	examine()
		. = ..()
		if (amount > 1)
			. += "<span class='notice'>This is a stack of [amount] arrows."
		if (reagents.total_volume)
			. += "<span class='notice'>The tip of the arrow is coated with reagents.</span>"

	clone(var/newloc = null)
		var/obj/item/arrow/O = new(loc)
		if (newloc)
			O.set_loc(newloc)
		O.setHeadMaterial(head_material)
		O.setShaftMaterial(shaft_material)
		return O
/*
	attack_hand(var/mob/user)
		if (amount > 1)
			amount--
			var/obj/item/arrow/O = clone(loc)
			user.put_in_hand_or_drop(O, user.hand)
			boutput(user, "<span class='notice'>You take \a [src] from the stack of [src]s. [amount] remaining on the stack.")
		else
			..()
*/

	set_loc()
		..()
		if (isturf(loc))
			overlays.len = 0
			head.layer = initial(head.layer)
			shaft.layer = initial(shaft.layer)
			overlays += shaft
			overlays += head
		else
			overlays.len = 0
			head.layer = HUD_LAYER+3
			shaft.layer = HUD_LAYER+3
			overlays += shaft
			overlays += head

	update_stack_appearance()
		setName()
		return

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	proc/setName()
		if (head_material && shaft_material)
			name = "[amount] [head_material]-headed [shaft_material] arrow[amount > 1 ? "s":""]"
		else if (head_material)
			name = "[amount] [head_material]-headed arrow[amount > 1 ? "s":""]"
		else if (shaft_material)
			name = "[amount] steel-headed [shaft_material] arrow[amount > 1 ? "s":""]"
		else
			name = "[amount] steel-headed arrow[amount > 1 ? "s":""]"

	proc/setHeadMaterial(var/datum/material/M)
		head_material = copyMaterial(M)
		overlays -= head
		if (M)
			head.color = M.color
			head.alpha = M.alpha
		else
			head.color = null
			head.alpha = 255
		overlays += head
		setName()

	proc/setShaftMaterial(var/datum/material/M)
		shaft_material = copyMaterial(M)
		src.setMaterial(shaft_material,copy = 0, appearance = 0, setname = 0)
		overlays -= shaft
		if (M)
			shaft.color = M.color
			shaft.alpha = M.alpha
		else
			shaft.color = null
			shaft.alpha = 255
		overlays += shaft
		setName()

	afterattack(var/atom/target, var/mob/user, reach)
		if (!reach)
			return
		if (isliving(target))
			if (prob(50))
				user.visible_message("<span class='alert'><b>[user] tries to stab [target] with [src] but misses!</b></span>")
				playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, 1)
				return
			user.visible_message("<span class='alert'><b>[user] stabs [target] with [src]!</b></span>")
			user.u_equip(src)
			playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 75, 1)
			var/datum/material/fusedmaterial = getFusedMaterial(head_material,shaft_material)//uses a fused material to get the effects of both the shaft and head material as an implant as the lifeloop only accepts one material per implant
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				var/obj/item/implant/projectile/body_visible/arrow/A = new
				A.material = fusedmaterial
				A.setMaterial(fusedmaterial, appearance = 0, setname = 0)
				A.arrow = src
				A.name = name
				set_loc(A)
				A.set_loc(target)
				A.owner = target
				H.implant += A
				A.implanted(H, null, 100)
			reagents.reaction(target, 2)
			reagents.trans_to(target, reagents.total_volume)
			take_bleeding_damage(target, null, 8, DAMAGE_STAB)
			if (fusedmaterial)
				fusedmaterial.triggerOnAttack(src, user, target)
			return 1
		else
			var/obj/item/I = target
			if (istype(I) && I.is_open_container() == 1 && I.reagents)
				if (reagents.total_volume == reagents.maximum_volume)
					boutput(user, "<span class='alert'>[src] is already coated in the maximum amount of reagents it can hold.</span>")
				else if (!I.reagents.total_volume)
					boutput(user, "<span class='alert'>[I] is empty.</span>")
				else
					var/amt = min(reagents.maximum_volume - reagents.total_volume, I.reagents.total_volume)
					logTheThing(LOG_COMBAT, user, "poisoned [src] [log_reagents(I)] at [log_loc(user)].") // Logs would be nice (Convair880).
					I.reagents.trans_to(src, amt)
					boutput(user, "<span class='notice'>You dip [src] into [I], coating it with [amt] units of reagents.</span>")

/obj/item/implant/projectile/body_visible/arrow
	name = "arrow"
	pull_out_name = "arrow"
	icon = null
	icon_state = null
	desc = "An arrow."
	var/obj/item/arrow/arrow = null

	New()
		..()
		implant_overlay = image(icon='icons/mob/human.dmi', icon_state="arrow_stick_[rand(0,4)]", layer=MOB_EFFECT_LAYER)

	// Hack.
	set_loc()
		..()
		if (isturf(loc))
			if (arrow)
				arrow.set_loc(loc)
			qdel(src)

/obj/item/quiver
	name = "quiver"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "quiver-0"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	item_state = "quiver"
	flags = FPRINT | TABLEPASS | ONBACK | ONBELT
	move_triggered = 1

	attackby(var/obj/item/arrow/I, var/mob/user)
		if (!istype(I))
			boutput(user, "<span class='alert'>That cannot be placed in [src]!</span>")
			return

		if(I.amount > 1)
			var/amountinitial = I.amount
			for(var/i=0, i<amountinitial, i++)
				I.clone(src)
				I.change_stack_amount(-1)
			maptext = "[contents.len]"
			icon_state = "quiver-[min(contents.len, 4)]"
		else
			user.u_equip(I)
			I.set_loc(src)
			maptext = "[contents.len]"
			icon_state = "quiver-[min(contents.len, 4)]"

	proc/getArrow(var/mob/user)
		if (src in user)
			if (contents.len)
				boutput(user, "<span class='notice'>You take [contents[1]] from [src].</span>")
				return contents[1]
			else return null

	proc/updateAppearance()
		if (contents.len)
			maptext = "[contents.len]"
		else
			maptext = null
		icon_state = "quiver-[min(contents.len, 4)]"
		return

	attack_hand(var/mob/user)
		if (src in user)
			var/obj/item/arrow/I = getArrow(user)
			if(I)
				user.put_in_hand(I, user.hand)
				updateAppearance()
			return
		..()

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		var/atom/movable/screen/hud/S = over_object
		if (istype(S))
			playsound(src.loc, "rustle", 50, 1, -5)
			if (!usr.restrained() && !usr.stat && src.loc == usr)
				if (S.id == "rhand")
					if (!usr.r_hand)
						usr.u_equip(src)
						usr.put_in_hand(src, 0)
				else
					if (S.id == "lhand")
						if (!usr.l_hand)
							usr.u_equip(src)
							usr.put_in_hand(src, 1)
				return
		if (usr.is_in_hands(src))
			var/turf/T = over_object
			if (istype(T, /obj/table))
				T = get_turf(T)
			if (!(usr in range(1, T)))
				return
			if (istype(T))
				for (var/obj/O in T)
					if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
						return
				if (!T.density)
					usr.visible_message("<span class='alert'>[usr] dumps the contents of [src] onto [T]!</span>")
					for (var/obj/item/I in src)
						I.set_loc(T)
						I.layer = initial(I.layer)

	move_trigger(var/mob/M, kindof)
		if (..())
			for (var/obj/O in contents)
				if (O.move_triggered)
					O.move_trigger(M, kindof)

/datum/projectile/arrow
	name = "arrow"
	damage = 17
	dissipation_delay = 12
	dissipation_rate = 5
	shot_sound = 'sound/effects/bow_fire.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	implanted = null
	impact_image_state = "bhole"
	icon_state = "arrow"

	on_hit(var/atom/A, angle, var/obj/projectile/P)
		if (ismob(A))
			playsound(A, 'sound/impact_sounds/Flesh_Stab_1.ogg', 75, 1)
			var/obj/item/implant/projectile/body_visible/arrow/B = P.implanted
			if (istype(B))
				if (B.material)
					B.material.triggerOnAttack(B, null, A)
				B.arrow.reagents?.reaction(A, 2)
				B.arrow.reagents?.trans_to(A, B.arrow.reagents.total_volume)
			take_bleeding_damage(A, null, round(src.power / 2), src.hit_type)


/obj/item/gun/bow
	name = "bow"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "bow"
	item_state = "bow"
	var/obj/item/arrow/loaded = null
	var/datum/action/bar/aim/aim = null
	spread_angle = 40
	force = 5
	can_dual_wield = 0
	contraband = 0
	move_triggered = 1

	New()
		set_current_projectile(new/datum/projectile/arrow)
		. = ..()

	proc/loadFromQuiver(var/mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(istype(H.back, /obj/item/quiver))
				var/obj/item/quiver/Q = H.back
				var/obj/item/arrow/I = Q.getArrow(user)
				if(I)
					loaded = I
					I.set_loc(src)
					overlays += I
					Q.updateAppearance()
			if(istype(H.belt, /obj/item/quiver))
				var/obj/item/quiver/Q = H.belt
				var/obj/item/arrow/I = Q.getArrow(user)
				if(I)
					loaded = I
					I.set_loc(src)
					overlays += I
					Q.updateAppearance()
		return

	attack_hand(var/mob/user)
		if (!loaded && user.is_in_hands(src))
			loadFromQuiver(user)

		if (loaded && user.is_in_hands(src))
			user.put_in_hand_or_drop(loaded)
			boutput(user, "<span class='notice'>You unload the arrow from the bow.</span>")
			overlays.len = 0
			loaded = null
		else
			..()

	move_trigger(var/mob/M, kindof)
		if (istype(loaded))
			loaded.move_trigger(M, kindof)


	attack(var/mob/target, var/mob/user)
		user.lastattacked = target
		target.lastattacker = user
		target.lastattackertime = world.time


	//absolutely useless as an attack but removing it causes bugs, replaced fire point blank which had issues with the way arrow damage is calculated.
		if(isliving(target))
			if(loaded)
				if(loaded.AfterAttack(target,user,1))
					loaded =null;//arrow isnt consumed otherwise, for some inexplicable reason.
			else
				boutput(user, "<span class='alert'>Nothing is loaded in the bow!</span>")
		else
			..()

	#ifdef DATALOGGER
			game_stats.Increment("violence")
	#endif
			return

	/*
	onMouseDown(atom/target,location,control,params)
		var/mob/user = usr
		var/list/parameters = params2list(params)
		if(ismob(target.loc) || istype(target, /atom/movable/screen)) return
		if(parameters["left"])
			if (!aim && !loaded)
				loadFromQuiver(user)

			if (!aim && loaded)
				aim = new(user, src)
				actions.start(aim, user)
		return
	*/

	attack_self(var/mob/user)
		return

	process_ammo(var/mob/user)
		if (!loaded)
			boutput(user, "<span class='alert'>Nothing is loaded in the bow!</span>")
			return 0
		overlays.len = 0
		var/obj/item/implant/projectile/body_visible/arrow/A = new
		A.setMaterial(loaded.head_material, appearance = 0, setname = 0)
		A.arrow = loaded
		A.name = loaded.name
		current_projectile.name = loaded.name
		loaded.set_loc(A)
		current_projectile.implanted = A
		current_projectile.material = copyMaterial(loaded.head_material)
		var/default_damage = 20
		if(loaded.head_material)
			if(loaded.head_material.hasProperty("hard"))
				current_projectile.damage = round(17+loaded.head_material.getProperty("hard") * 3) //pretty close to the 20-50 range
			else
				current_projectile.damage = default_damage
		else
			current_projectile.damage = default_damage

		current_projectile.generate_stats()

		loaded = null
		return 1

	canshoot(mob/user)
		return loaded != null

	pixelaction(atom/target, params, mob/user, reach)
		/*
		if (!loaded)
			boutput(user, "<span class='alert'>Nothing is loaded in the bow!</span>")
			return 1
		*/

		if (!aim)
			//var/list/parameters = params2list(params)
			if(ismob(target.loc) || istype(target, /atom/movable/screen)) return
			if (!loaded)//removed redundant check
				loadFromQuiver(user)
				if(loaded)
					boutput(user, "<span class='alert'>You load an arrow from the quiver.</span>")
				return
			if(reach)
				return
			if (loaded)
				aim = new(user, src)
				actions.start(aim, user)
		else
			var/spread_base = 40
			if(src.material)
				if(src.material.getProperty("density") <= 2)
					spread_base *= 1.5
				else if (src.material.getProperty("density") >= 5)
					spread_base *= 0.75

				else if (src.material.getProperty("density") >= 7)
					spread_base *= 0.5

			spread_angle = spread_base
			if (aim)
				spread_angle = (1 - aim.progress) * spread_base
				aim.state = ACTIONSTATE_FINISH
			..()

	attackby(var/obj/item/arrow/I, var/mob/user)
		if (!istype(I))
			return
		if (loaded)
			boutput(user, "<span class='alert'>An arrow is already loaded onto the bow.</span>")

		if(I.amount > 1)
			var/obj/item/arrow/C = I.clone(src)
			I.change_stack_amount(-1)
			overlays += C
			loaded = C
		else
			overlays += I
			user.u_equip(I)
			loaded = I
			I.set_loc(src)
