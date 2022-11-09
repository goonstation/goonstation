#define MAGIC_GLUE_ANCHORED 12345

TYPEINFO(/datum/component/glued)
	initialization_args = list(
		ARG_INFO("target", DATA_INPUT_REF, "What is this glued to", null),
		ARG_INFO("glue_duration", DATA_INPUT_NUM, "How long the glue lasts, null for infinity", null),
		ARG_INFO("glue_removal_time", DATA_INPUT_NUM, "How long does it take to unglue stuff", null),
	)

/datum/component/glued
	var/dries_up_timestamp
	var/glue_removal_time
	var/original_animate_movement
	var/original_anchored
	var/atom/glued_to
	var/set_loc_rippoff_in_progress = FALSE
	var/outline = TRUE

/datum/component/glued/Initialize(atom/target, glue_duration=null, glue_removal_time=null, visible_outline=TRUE)
	if(!istype(src.parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.glued_to = target
	RegisterSignal(glued_to, COMSIG_PARENT_PRE_DISPOSING, .proc/delete_self)
	src.dries_up_timestamp = glue_duration ? TIME + glue_duration : null
	src.glue_removal_time = glue_removal_time
	var/atom/movable/parent = src.parent
	src.outline = visible_outline
	if (src.outline)
		parent.add_filter("glued_outline", 0, outline_filter(size=1, color="#e6e63c7f"))
	delayed_dry_up(glue_duration)
	if(ismovable(glued_to))
		var/atom/movable/glued_to = src.glued_to
		LAZYLISTADDUNIQUE(glued_to.attached_objs, parent)
		glued_to.vis_contents += parent
	if(ismob(parent))
		var/mob/parent_mob = parent
		APPLY_ATOM_PROPERTY(parent_mob, PROP_MOB_CANTMOVE, "glued")
	if(isitem(parent) && ismob(parent.loc))
		var/mob/parent_holder = parent.loc
		var/obj/item/item_parent = parent
		parent_holder.u_equip(parent)
		item_parent.dropped(parent_holder)
	parent.set_loc(isturf(glued_to) ? glued_to : glued_to.loc)
	src.original_animate_movement = parent.animate_movement
	src.original_anchored = parent.anchored
	parent.animate_movement = SYNC_STEPS
	parent.anchored = MAGIC_GLUE_ANCHORED // replace with atom_properties once we move atom_properties to /atom
	parent.layer = OBJ_LAYER
	if(isturf(glued_to))
		parent.plane = PLANE_NOSHADOW_BELOW
	else
		parent.plane = PLANE_UNDERFLOOR
	parent.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/on_attackhand)
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/pass_on_attackby)
	RegisterSignal(parent, COMSIG_MOVABLE_BLOCK_MOVE, .proc/move_blocked_check)
	RegisterSignal(parent, COMSIG_MOVABLE_SET_LOC, .proc/on_set_loc)
	RegisterSignals(parent, list(COMSIG_ATOM_EXPLODE, COMSIG_ATOM_EXPLODE_INSIDE), .proc/on_explode)
	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, .proc/on_hitby_proj)

/datum/component/glued/proc/delayed_dry_up(glue_duration)
	set waitfor = FALSE
	if(glue_duration != null)
		sleep(glue_duration)
		dry_up()

/datum/component/glued/proc/delete_self()
	qdel(src)

/datum/component/glued/proc/dry_up()
	if(src.disposed || !src.parent || src.parent.disposed || !glued_to || glued_to.disposed)
		return
	var/atom/movable/parent = src.parent
	var/turf/T = get_turf(parent)
	T.visible_message("<span class='notice'>The glue on [parent] dries up and it falls off from [glued_to].</span>")
	qdel(src)

/datum/component/glued/proc/on_attackhand(atom/movable/parent, mob/user)
	if(user?.a_intent == INTENT_HELP)
		src.start_ungluing(parent, user)
	else
		src.glued_to.Attackhand(user)
		user.lastattacked = user

/datum/component/glued/proc/start_ungluing(atom/movable/parent, mob/user)
	if(isnull(src.glue_removal_time))
		boutput(user, "<span class='alert'>You try to unglue [parent] from [src.glued_to] but the glue is too strong.</span>")
		return
	var/turf/T = get_turf(parent)
	T.visible_message("<span class='notice'>[user] starts ungluing [parent] from [src.glued_to].</span>")
	actions.start(
		new /datum/action/bar/icon/callback(user, parent, src.glue_removal_time, .proc/delete_self, null, parent.icon, parent.icon_state,\
		"<span class='notice'>[user] manages to unglue [parent] from [src.glued_to].</span>", 0, src), user)

/datum/component/glued/proc/pass_on_attackby(atom/movable/parent, obj/item/item, mob/user, list/params, is_special)
	src.glued_to.Attackby(item, user, params, is_special)
	user.lastattacked = user

/datum/component/glued/proc/on_hitby_proj(atom/movable/parent, obj/projectile/proj)
	src.glued_to.bullet_act(proj)

/datum/component/glued/proc/move_blocked_check(atom/movable/parent, atom/new_loc, direct)
	return new_loc != glued_to.loc

/datum/component/glued/proc/on_set_loc(atom/movable/parent, atom/old_loc)
	if(old_loc == parent.loc) // this will generally happen when our glued_to moves in with us, yay 😊
		src.set_loc_rippoff_in_progress = FALSE
	if(parent.loc != glued_to.loc) // we moved to a place where our glued_to isn't better rip ourselves off
		src.set_loc_rippoff_in_progress = TRUE
		SPAWN(1) // but first wait if the glued_to doesn't move in with us 🥺
			if(src.set_loc_rippoff_in_progress && !QDELETED(src))
				var/turf/T = get_turf(parent)
				T?.visible_message("<span class='notice'>\The [parent] is ripped off from [glued_to].</span>")
				qdel(src)

/datum/component/glued/proc/on_explode(atom/movable/parent, list/explode_args)
	// explode_args format: list(atom/source, turf/epicenter, power, brisance = 1, angle = 0, width = 360, turf_safe=FALSE)
	explode_args[3] /= 3 // reduce explosion size by a factor of 3
	qdel(src)

/datum/component/glued/UnregisterFromParent()
	var/atom/movable/parent = src.parent
	UnregisterSignal(parent, list(COMSIG_ATTACKHAND, COMSIG_ATTACKBY, COMSIG_MOVABLE_BLOCK_MOVE, COMSIG_MOVABLE_SET_LOC, COMSIG_ATOM_EXPLODE,
		COMSIG_ATOM_EXPLODE_INSIDE, COMSIG_ATOM_HITBY_PROJ))
	UnregisterSignal(glued_to, COMSIG_PARENT_PRE_DISPOSING)
	if (src.outline)
		parent.remove_filter("glued_outline")
	parent.animate_movement = src.original_animate_movement
	if(parent.anchored == MAGIC_GLUE_ANCHORED)
		parent.anchored = src.original_anchored
	parent.layer = initial(parent.layer)
	parent.plane = initial(parent.plane)
	parent.vis_flags &= ~(VIS_INHERIT_PLANE | VIS_INHERIT_LAYER)
	if(ismovable(glued_to))
		var/atom/movable/glued_to = src.glued_to
		glued_to.attached_objs -= parent
		glued_to.vis_contents -= parent
	if(ismob(parent))
		var/mob/parent_mob = parent
		REMOVE_ATOM_PROPERTY(parent_mob, PROP_MOB_CANTMOVE, "glued")
	parent.set_loc(get_turf(parent))
	src.glued_to = null
	. = ..()

#undef MAGIC_GLUE_ANCHORED
