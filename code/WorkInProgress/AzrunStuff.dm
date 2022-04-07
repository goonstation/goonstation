/obj/item/deconstructor/admin_crimes
	// do not put this anywhere anyone can get it. it is for crime.
	name = "(de/re)-construction device"
	desc = "A magical saw-like device for unmaking things. Is that a soldering iron on the back?"

	New()
		..()
		setMaterial(getMaterial("miracle"))

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!isobj(target))
			return
		if(istype(target, /obj/item/electronics/frame))
			var/obj/item/electronics/frame/F = target
			F.deploy(user)

		finish_decon(target, user)

/obj/item/paper/artemis_todo
	icon = 'icons/obj/electronics.dmi';
	icon_state = "blueprint";
	info = "<h3>Project Artemis</h3><i>The blueprint depicts the design of a small spaceship and a unique method of travel through space.  It is covered in small todo-lists in red ink.</i>";
	item_state = "sheet";
	name = "Artemis Blueprint"
	interesting = "The title block indicates this was originally made by Emily while all revisions seem to have been done in crayon by Azrun?"

/obj/item/paper/terrainify
	icon = 'icons/obj/electronics.dmi';
	icon_state = "blueprint";
	info = "<h3>Project Metamorphose</h3><i>It depicts of a series of geoids with varying topology and various processing to convert to and from one another.</i>";
	item_state = "sheet";
	name = "Strange Blueprint"
	interesting = "There is additional detail regarding the creation of flora and fauna."

/obj/item/storage/desk_drawer/azrun/
	spawn_contents = list(	/obj/item/raw_material/molitz_beta,\
	/obj/item/raw_material/molitz_beta,\
	/obj/item/raw_material/plasmastone,\
	/obj/item/organ/lung/plasmatoid/left,\
	/obj/item/pen/crayon/red,\

)
/obj/table/wood/auto/desk/azrun
	New()
		..()
		var/obj/item/storage/desk_drawer/azrun/L = new(src)
		src.desk_drawer = L


/obj/machinery/plantpot/bareplant/swamp_flora
	New()
		..()
		spawn_plant = pick(/datum/plant/spore_poof, /datum/plant/seed_spitter)

/datum/plant/spore_poof
	name = "mysterious plant"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	growthmode = "weed"
	sprite = "Poof"
	special_proc = 1
	attacked_proc = 1
	harvestable = 0
	assoc_reagents = list("cyanide", "histamine", "nitrogen_dioxide")
	starthealth = 40
	growtime = 50
	harvtime = 90
	cropsize = 1
	harvests = 0
	endurance = 5
	vending = FALSE


	var/list/cooldowns

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA.harvtime + 10))
			for (var/mob/living/X in view(1,POT.loc))
				if(isalive(X) && !iskudzuman(X))
					poof(X, POT)
					break

	HYPattacked_proc(obj/machinery/plantpot/POT, mob/user)
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		if (POT.growth > (P.harvtime + DNA.harvtime + 10))
			if(!iskudzuman(user))
				poof(user, POT)

	proc/poof(atom/movable/AM, obj/machinery/plantpot/POT)
		if(!ON_COOLDOWN(src,"spore_poof", 2 SECONDS))
			var/datum/plantgenes/DNA = POT.plantgenes
			var/datum/reagents/reagents_temp = new/datum/reagents(max(1,(50 + DNA.cropsize))) // Creating a temporary chem holder
			reagents_temp.my_atom = POT

			for (var/plantReagent in assoc_reagents)
				reagents_temp.add_reagent(plantReagent, 2 * round(max(1,(1 + DNA.potency / (10 * length(assoc_reagents))))))

			SPAWN(0) // spawning to kick fluid processing out of machine loop
				reagents_temp.smoke_start()
				qdel(reagents_temp)

			POT.growth = clamp(POT.growth/2, src.growtime, src.harvtime-10)
			POT.UpdateIcon()

	getIconState(grow_level, datum/plantmutation/MUT)
		if(GET_COOLDOWN(src, "spore_poof"))
			return "Poof-Open"
		else
			. = ..()

/obj/item/seed/alien/spore_poof
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/spore_poof, src)

/datum/plant/seed_spitter
	name = "mysterious plant"
	plant_icon = 'icons/obj/hydroponics/plants_alien.dmi'
	sprite = "Spit"
	growthmode = "weed"
	special_proc = 1
	attacked_proc = 1
	harvestable = 0
	starthealth = 40
	growtime = 80
	harvtime = 120
	cropsize = 1
	harvests = 0
	endurance = 5
	assoc_reagents = list("toxin", "histamine")
	vending = FALSE

	var/datum/projectile/syringe/seed/projectile

	New()
		..()
		projectile = new

	proc/alter_projectile(var/obj/projectile/P)
		if (!P.reagents)
			P.reagents = new /datum/reagents(P.proj_data.cost)
			P.reagents.my_atom = P
		for (var/plantReagent in assoc_reagents)
			P.reagents.add_reagent(plantReagent, 2)

	HYPspecial_proc(var/obj/machinery/plantpot/POT)
		..()
		if (.) return
		var/datum/plant/P = POT.current
		var/datum/plantgenes/DNA = POT.plantgenes

		var/mob/M = POT.loc
		if(isalive(M))
			M.TakeDamage("All", 2, 0, 0, DAMAGE_STAB)
			if(prob(20))
				return

		if (POT.growth > (P.harvtime + DNA.harvtime + 5))
			var/list/stuffnearby = list()
			for (var/mob/living/X in view(7,POT.loc))
				if(isalive(X) && (X != POT.loc) && !iskudzuman(X))
					stuffnearby += X
			if(length(stuffnearby))
				var/mob/living/target = pick(stuffnearby)
				var/datum/callback/C = new(src, .proc/alter_projectile)
				if(prob(10))
					shoot_projectile_ST(POT, projectile, get_step(target, pick(ordinal)), alter_proj=C)
				else
					shoot_projectile_ST(POT, projectile, target, alter_proj=C)
				POT.growth -= rand(1,5)
			return

/obj/item/seed/alien/seed_spitter
	gen_plant_type()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/seed_spitter, src)

/datum/projectile/syringe/seed
	name = "strange seed"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "seedproj"
	implanted = /obj/item/implant/projectile/spitter_pod

/obj/item/implant/projectile/spitter_pod
	name = "strange seed pod"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	desc = "A small hollow pod."
	icon_state = "seedproj"

	var/heart_ticker = 10
	online = TRUE

	implanted(mob/M, mob/Implanter)
		..()
		if(prob(10))
			online = FALSE

	on_death()
		if(!online)
			return
		var/atom/movable/P = locate(/obj/machinery/plantpot/bareplant) in src.owner

		// Uhhh.. just one thanks, don't need a pew pew army growing out of someone
		if(!P)
			P = new /obj/machinery/plantpot/bareplant {spawn_plant=/datum/plant/seed_spitter; spawn_growth=1; auto_water=FALSE;} (src.owner)
			var/atom/movable/target = src.owner
			src.owner.vis_contents |= P
			P.alpha = 0
			SPAWN(rand(2 SECONDS, 3 SECONDS))
				P.rest_mult = target.rest_mult
				P.pixel_x = 15 * -P.rest_mult
				P.transform = P.transform.Turn(P.rest_mult * -90)
				animate(P, alpha=255, time=2 SECONDS)

	do_process()
		heart_ticker = max(heart_ticker--,0)
		if(heart_ticker & prob(50))
			if(prob(30))
				boutput(src.owner,__red("You feel as though something moving towards your heart... That can't be good."))
			else
				boutput(src.owner,__red("You feel as though something is working its way through your chest."))
		else if(!heart_ticker)
			var/mob/living/carbon/human/H = src.owner
			if(istype(H))
				H.organHolder.damage_organs(2, 0, 1, "heart")
			else
				src.owner.TakeDamage("All", 2, 0)

			if(prob(5))
				boutput(src.owner,__red("AAHRRRGGGG something is trying to dig your heart out from the inside?!?!"))
				src.owner.emote("scream")
				src.owner.changeStatus("stunned", 2 SECONDS)
			else if(prob(10))
				boutput(src.owner,__red("You feel a sharp pain in your chest."))


/datum/manufacture/ghost_brain // Move to manufacturing.dm
	name = "Ghost Intelligence Core"
	item_paths = list("MET-1","CON-1","ALL", "soulsteel")
	item_amounts = list(6,5,3,5)
	item_outputs = list(/obj/item/organ/brain/ghost)
	time = 45 SECONDS
	create = 1
	category = "Component"

/obj/item/organ/brain/ghost // Move to brain.dm
	name = "Ghost Intelligence Core"
	desc = "A brain shaped mass of silicon, soulsteel, and LED lights. Attempts to hold onto soul to give life to something else."
	icon_state = "ghost_brain"
	item_state = "ai_brain"
	created_decal = /obj/decal/cleanable/oil
	made_from = "pharosium"
	var/activated = 0
	var/lastTrigger
	var/datum/movement_controller/ghost_brain/MC
	var/obj/item/organ/brain/old_brain

	New()
		..()
		MC = new

	get_desc()
		if (usr?.traitHolder?.hasTrait("training_medical"))
			if (activated)
				if (src.owner?.key)
					if (!find_ghost_by_key(src.owner?.key))
						. += "<br><span class='notice'>[src]'s indicators show that it once had a conciousness captured, but that conciousness cannot be located.</span>"
					else
						. += "<br><span class='notice'>[src]'s indicators show that it is still operational, and can be installed into a new body immediately.</span>"
				else
					. += "<br><span class='alert'>[src] has powered down fully.</span>"
			else
				. += "<br><span class='alert'>[src] is brand new. No conciousness has entered it yet.</span>"

	attack_self(mob/user as mob)
		if(activated && src.owner?.key && istype(owner.current, /mob/dead/observer))
			if(alert(user, "Are you sure you want to release the ghost?", "Release Ghost?", "Yes", "No") == "Yes")
				boutput(owner.current, "You no longer feel anchored to [src]!")
				owner.current.delStatus("bound_ghost")
				if(old_brain)
					owner.brain = old_brain // attempt to restore to previous brain?
				owner = null

	on_life()
		var/mob/living/M = holder.donor
		if(!ishuman(M)) // silicon shouldn't have these problems
			return

		if(M.client && (isnull(M.client.color) || M.client.color == "#FFFFFF") && !ON_COOLDOWN(src,"ghost_eyes", 5 MINUTES))
			boutput(M,"Your vision starts to change as your connection this body wavers.")
			animate(M.client, color=COLOR_MATRIX_GRAYSCALE, time=5 SECONDS, easing=SINE_EASING)
			animate(color=COLOR_MATRIX_IDENTITY, time=30 SECONDS, easing=SINE_EASING)
		if(prob(1))
			boutput(M,"You find you lose control of your body for a moment...")
			M.changeStatus("paralysis", 2 SECONDS)
		if(prob(1))
			boutput(M,"You suddenly feel sluggish as though your connection to your body isn't as strong.")
			M.changeStatus("slowed", 8 SECONDS, 2)

	get_movement_controller()
		.= MC

	Crossed(atom/movable/AM)
		..()

		var/mob/dead/observer/O = AM
		if(!src.owner && !GET_COOLDOWN(src,"ghost_suck") && istype(O))
			if(jobban_isbanned(O, "Ghostbrain"))
				boutput(O, "<span class='notice'>Sorry, you are banned from playing a ghostbrain.</span>")
				return
			if(O.can_respawn_as_ghost_critter()) // Azrun TODO New func with more apporpriate verbage?
				actions.start(new/datum/action/bar/capture_ghost(O), src)
				ON_COOLDOWN(src, "ghost_suck", 2 SECONDS)

	Entered(atom/movable/A,atom/OldLoc)
		. = ..()
		var/mob/dead/observer/O = A
		if(MC && istype(O) )
			O.use_movement_controller = src
			O.setStatus("bound_ghost", duration = 2 MINUTES, optional=list("anchor"=src, "client"=O.client))
			if (istype(O.abilityHolder, /datum/abilityHolder/ghost_observer))
				var/datum/abilityHolder/ghost_observer/GH = O.abilityHolder
				GH.disable(TRUE)
				GH.updateButtons()

	Exited(atom/movable/A,atom/OldLoc)
		. = ..()
		var/mob/dead/observer/O = A
		if(istype(O) && O.use_movement_controller == src)
			O.use_movement_controller = null

		if (istype(O) && istype(O.abilityHolder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GH = O.abilityHolder
			GH.disable(FALSE)
			GH.updateButtons()

/datum/action/bar/capture_ghost
	id = "capture_ghost"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	var/mob/dead/observer/target
	var/image/pulling

	New(mob/dead/observer/O)
		..()
		if (istype(O))
			target = O
		if(!pulling)
			pulling = image('icons/effects/effects.dmi',"pulling",pixel_y=16)
			pulling.alpha = 200

	onUpdate()
		..()
		if(GET_DIST(target,owner) != 0)
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		boutput(target, "<span class='notice'>You feel yourself being pulled into [owner]!</span>")
		owner.UpdateOverlays(pulling, id)

	onEnd()
		..()
		var/obj/item/organ/brain/ghost/B = owner
		if(target.observe_round) return
		if(B && target.client)
			B.activated = TRUE
			playsound(B, "sound/effects/suck.ogg", 20, TRUE, 0, 0.9)
			B.old_brain = target.mind.brain
			B.setOwner(target.mind)
			target.set_loc(B)
			target.changeStatus("ghost_bound", 2 MINUTES, B)

	onDelete()
		..()
		owner.ClearSpecificOverlays(id)


/datum/movement_controller/ghost_brain
	var/next_move = 0
	var/mc_delay = 5

	keys_changed(mob/user, keys, changed)
		var/do_step = TRUE
		var/obj/O = user.loc
		if(istype(O))
			if (changed & (KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT))
				var/move_x = 0
				var/move_y = 0
				if (keys & KEY_FORWARD)
					move_y += 1
				if (keys & KEY_BACKWARD)
					move_y -= 1
				if (keys & KEY_RIGHT)
					move_x += 1
				if (keys & KEY_LEFT)
					move_x -= 1
				if (move_x || move_y)
					if(!user.move_dir && user.canmove && user.restrained())
						if (user.pulled_by || length(user.grabbed_by))
							boutput(user, "<span class='notice'>You're restrained! You can't move!</span>")
							do_step = FALSE

					user.move_dir = angle2dir(arctan(move_y, move_x))
					if(do_step)
						if(!attempt_move(user) )
							if(!ON_COOLDOWN(user,"ghost_glow", 5 SECONDS))
								O.visible_message("[O] glows brightly momentarily.")
							if(!ON_COOLDOWN(user,"ghost_wiggle", 1 SECONDS))
								animate(O, time=0.5 SECONDS, pixel_x=move_x, pixel_y=move_y, flags=ANIMATION_RELATIVE)
								animate(pixel_x=-move_x, pixel_y=-move_y, time=0.2 SECONDS, flags=ANIMATION_RELATIVE)
				else
					user.move_dir = 0

			if(!user.dir_locked)
				user.set_dir(user.move_dir)
			if (changed & (KEY_THROW|KEY_PULL|KEY_POINT|KEY_EXAMINE|KEY_BOLT|KEY_OPEN|KEY_SHOCK)) // bleh
				user.update_cursor()

	process_move(mob/user, keys)
		var/obj/O = user.loc
		var/old_loc = O.loc
		var/delay = src.mc_delay

		if (next_move - world.time >= world.tick_lag / 10)
			return max(world.tick_lag, (next_move - world.time) - world.tick_lag / 10)

		if (user.move_dir & (user.move_dir-1))
			delay *= DIAG_MOVE_DELAY_MULT
		var/glide = (world.icon_size / ceil(delay / world.tick_lag))
		O.glide_size = glide // dumb hack: some Move() code needs glide_size to be set early in order to adjust "following" objects
		O.animate_movement = SLIDE_STEPS
		step(O, user.move_dir)
		if (O.loc != old_loc)
			O.OnMove()
		O.glide_size = glide // but Move will auto-set glide_size, so we need to override it again

		next_move = world.time + delay

		return O.loc != old_loc

/datum/statusEffect/bound_ghost
	id= "bound_ghost"
	var/atom/bound_target
	var/client/target_client
	move_triggered = TRUE
	onAdd(optional)
		..()
		var/list/statusargs = optional
		if(statusargs["anchor"])
			bound_target = statusargs["anchor"]
		if(statusargs["client"])
			target_client = statusargs["client"]

	onUpdate()
		..()
		get_back_here()

	move_trigger(mob/user, ev)
		. = 0
		get_back_here()

	proc/get_back_here()
		var/mob/dead/observer/ghost = owner
		if(istype(ghost) && bound_target && ghost.loc != bound_target)
			boutput(ghost, "You find yourself pulled back into [bound_target]!")
			ghost.set_loc(bound_target)

	onRemove()
		..()
		var/mob/dead/observer/ghost = owner
		if(istype(ghost) && bound_target && ghost.loc == bound_target)
			ON_COOLDOWN(bound_target, "ghost_suck", 2 SECONDS)
			ghost.set_loc(get_turf(bound_target))


/obj/item/organ/brain/ghost/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/bot))
		target.AddComponent(/datum/component/brain_control, src, user)

/obj/item/organ/brain/ghost/mouse_drop(atom/over_object, src_location, over_location, over_control, params)
	if(istype(over_object, /obj/machinery/bot))
		afterattack(over_object, usr)

/datum/component/brain_control
	var/orig_path
	var/obj/item/organ/brain/controller

TYPEINFO(/datum/component/brain_control)
	initialization_args = list()

TYPEINFO(/datum/component/controlled_by_mob)
	initialization_args = list(
		ARG_INFO("B", DATA_INPUT_REFPICKER, "Brain to enter"),
		ARG_INFO("user", DATA_INPUT_MOB_REFERENCE, "Mob to control the component")
	)

/datum/component/brain_control/Initialize(obj/item/organ/brain/B, mob/user)
	var/atom/target = parent
	if(!istype(target))
		return COMPONENT_INCOMPATIBLE

	orig_path = parent.type
	if(istype(B))
		controller = B
	else
		return COMPONENT_INCOMPATIBLE

	// /obj/machinery/bot/medbot  TODO?
	// /obj/machinery/bot/cleanbot <-> /mob/living/critter/bot/cleanbot
	// /obj/machinery/bot/firebot <-> /mob/living/critter/bot/firebot
	// /obj/machinery/bot/floorbot  TODO?
	var/obj/machinery/bot/new_bot
	if(istype(target, /obj/machinery/bot)) // Maybe move to /obj/machinery/bot to get mapping out of here
		if(istype(target, /obj/machinery/bot/cleanbot ))
			new_bot = new /mob/living/critter/bot/cleanbot(target.loc)
		else if(istype(target, /obj/machinery/bot/firebot ))
			new_bot = new /mob/living/critter/bot/firebot(target.loc)

	if(new_bot)
		qdel(target)
		parent = new_bot
		RegisterSignal(parent, list(COMSIG_ATOM_POST_UPDATE_ICON), .proc/update_icon)
		RegisterSignal(parent, list(COMSIG_ATTACKBY), .proc/check_attack)

		if (controller.owner) //Mind transfer also handles key transfer.
			controller.owner.transfer_to(new_bot)
		user.u_equip(controller)
		controller.set_loc(new_bot)
		new_bot.UpdateIcon()
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/brain_control/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATTACKBY, COMSIG_ATOM_POST_UPDATE_ICON))
	. = ..()

/datum/component/brain_control/proc/update_icon(atom/A)
	var/image/I = A.SafeGetOverlayImage("brain",image('icons/obj/items/device.dmi', "head-brain"))
	I.appearance_flags = RESET_COLOR | KEEP_APART
	if(istype(parent, /mob/living/critter/bot/cleanbot))
		I.pixel_x = -4
		I.pixel_y = 3
	else if(istype(parent, /mob/living/critter/bot/firebot ))
		I.pixel_x = -5
		I.pixel_y = 2

	var/mob/M = A
	if(controller)
		if(controller.owner || M.mind )
			I.icon_state = "head-brain"
		else
			I.icon_state = "head-nobrain"
	else
		I = null

	A.UpdateOverlays(I,"brain")

/datum/component/brain_control/proc/check_attack(mob/M, obj/item/thing, mob/user)
	if(ispryingtool(thing))
		actions.start(new /datum/action/bar/icon/callback(user, M, 3 SECONDS, /datum/component/brain_control/proc/detach, list(M, thing, user), \
					thing.icon, thing.icon_state, end_message="[user] successfully pries [thing] free from \the [M]!", call_proc_on=src), user)

		return ATTACK_PRE_DONT_ATTACK

/datum/component/brain_control/proc/detach(mob/M, obj/item/thing, mob/user)
	if(controller)
		controller.setOwner(M.mind)
		controller.set_loc(M.loc)

	M.ghostize()

	if(ispath(orig_path))
		new orig_path(M.loc)
	qdel(parent)
	qdel(src)
