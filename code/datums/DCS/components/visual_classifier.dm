#define CLASSIFIER_CELL_FREE 1
#define CLASSIFIER_BRACKETS 0

/datum/spatial_hashmap/classifier_targets
	cell_size = 8

	proc/add_visible_targets(client/viewer, list/visible_tiles, radius)
		var/alist/anchors = src.supremum(viewer.mob.loc, radius)
		var/check_footprints = length(anchors) < length(src.atoms_by_entry)
		var/list/targets = list()
		for (var/atom/movable/target as anything in anchors)
			if (!isturf(target.loc))
				continue
			if (target.bound_x || target.bound_y || target.bound_width != world.icon_size || target.bound_height != world.icon_size || target.step_x || target.step_y)
				anchors -= target
				check_footprints = TRUE
			else if (visible_tiles[target.loc])
				targets += target

		if (check_footprints)
			// A big object can overlap a visible turf even if its origin is offscreen.
			var/alist/footprints = alist()
			for (var/turf/tile as anything in visible_tiles)
				footprints += tile.contents
			footprints &= src.atoms_by_entry
			footprints -= anchors
			targets += footprints
		visible_tiles += targets

TYPEINFO(/datum/component/visual_classifier)
	initialization_args = list(ARG_INFO("slot", DATA_INPUT_NUM, "Equipment slot (items only)", SLOT_GLASSES))

/datum/component/visual_classifier
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/enabled = TRUE
	var/scan_interval = 0.5 SECONDS
	var/boot_duration = 0
	var/target_limit = 192
	var/label_limit = 16
	var/label_attempt_limit = 48
	var/max_frame_tiles = 5

	/// Last matching category wins.
	var/list/category_types = list()
	var/list/filter_order
	var/list/category_labels = list()
	var/list/category_colors = list()
	var/list/projection_types
	var/list/excluded_types = list()
	var/list/flavor_labels = list()
	var/priority_category
	/// Rolled once per character when the label appears.
	var/label_glitch_chance = 2
	var/display_name = "Classifier"
	var/boot_banner_type
	var/boot_sound
	var/equipment_slot
	var/tmp/list/categories_by_type
	var/tmp/list/unindexed_categories
	var/tmp/list/flavor_rule_by_type
	var/tmp/mob/living/wearer
	var/tmp/client/viewer
	var/tmp/scan_generation = 0
	var/tmp/atom/movable/focused_target
	var/tmp/obj/overlay/classifier_projection/projection
	var/tmp/filter_class
	var/tmp/list/datum/classifier_callout/callouts
	var/tmp/list/last_label_layout
	var/tmp/atom/movable/screen/boot_banner

	Initialize(slot = SLOT_GLASSES)
		. = ..()
		if (!isliving(src.parent) && !isitem(src.parent))
			return COMPONENT_INCOMPATIBLE
		src.equipment_slot = slot

	RegisterWithParent()
		. = ..()
		if (isliving(src.parent))
			src.attach_wearer(src.parent)
		else
			src.RegisterSignal(src.parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			src.RegisterSignal(src.parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(detach_wearer))
			src.check_current_slot()

	proc/check_current_slot()
		var/obj/item/item = src.parent
		if (!istype(item))
			return
		var/mob/living/carbon/human/user = item.loc
		if (istype(user) && user.get_slot(src.equipment_slot) == item)
			src.attach_wearer(user)
		else
			src.detach_wearer()

	UnregisterFromParent()
		src.detach_wearer()
		if (isitem(src.parent))
			src.UnregisterSignal(src.parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED))
		. = ..()

	proc/on_equip(obj/item/source, mob/living/user, slot)
		if (slot == src.equipment_slot && istype(user))
			src.attach_wearer(user)
		else
			src.detach_wearer()

	proc/attach_wearer(mob/living/user)
		if (src.wearer == user)
			return
		src.detach_wearer()
		src.wearer = user
		src.RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(start_scanning))
		src.RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(stop_scanning))
		src.RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(reset_display))
		if (user != src.parent)
			src.RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(detach_wearer))
		src.start_scanning(user)

	proc/detach_wearer()
		src.stop_scanning()
		if (!src.wearer)
			return
		src.UnregisterSignal(src.wearer, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_PARENT_PRE_DISPOSING))
		src.wearer = null

	proc/start_scanning(mob/living/user)
		var/client/active_client = user.client
		if (!src.enabled || !active_client || src.viewer == active_client)
			return
		src.stop_scanning()
		src.viewer = active_client
		src.callouts = list()
		var/generation = src.scan_generation
		// force_equip() still has to move the item into the wearer's contents.
		SPAWN(0)
			if (!QDELETED(src) && src.scan_generation == generation && src.can_scan())
				src.show_boot()
			while (!QDELETED(src) && src.scan_generation == generation && user.client == active_client && src.source_active())
				src.refresh_callouts()
				sleep(max(world.tick_lag, src.scan_interval))
			if (!QDELETED(src) && src.scan_generation == generation)
				if (src.source_active())
					src.stop_scanning()
				else
					src.detach_wearer()

	proc/stop_scanning()
		src.scan_generation++
		src.reset_display()
		src.callouts = null
		src.viewer = null

	proc/reset_display()
		src.clear_boot()
		SEND_SIGNAL(src, COMSIG_CLASSIFIER_CHANGED, TRUE)
		src.set_filter(null)
		src.clear_callouts()

	proc/show_boot()
		if (!src.boot_banner_type || src.boot_duration <= 0)
			return
		var/atom/movable/screen/banner = new src.boot_banner_type
		src.boot_banner = banner
		src.viewer.screen += banner
		if (src.boot_sound)
			src.wearer.playsound_local_not_inworld(src.boot_sound, 25, FALSE, flags = SOUND_SKIP_OBSERVERS)
		SPAWN(src.boot_duration)
			if (!QDELETED(src) && src.boot_banner == banner)
				src.clear_boot()

	proc/clear_boot()
		if (!src.boot_banner)
			return
		src.viewer?.screen -= src.boot_banner
		qdel(src.boot_banner)
		src.boot_banner = null

	proc/set_power(active)
		src.enabled = !!active
		SEND_SIGNAL(src, COMSIG_CLASSIFIER_CHANGED)
		if (src.enabled && src.wearer)
			src.start_scanning(src.wearer)
		else if (!src.enabled)
			src.stop_scanning()

	onVarChanged(variable, oldval, newval)
		. = ..()
		switch (variable)
			if ("enabled")
				src.set_power(newval)
			if ("equipment_slot")
				src.check_current_slot()
			if ("category_types", "excluded_types", "flavor_labels")
				src.invalidate_rules()
			if ("target_limit", "label_limit", "label_attempt_limit", "max_frame_tiles", "scan_interval", "boot_duration")
				if (!isnum(newval))
					src.vars[variable] = initial(src.vars[variable])
				else if (variable == "scan_interval")
					src.scan_interval = max(world.tick_lag, newval)
				else if (variable == "boot_duration")
					src.boot_duration = max(0, newval)
				else if (variable == "max_frame_tiles")
					src.max_frame_tiles = max(1, floor(newval))
				else
					src.vars[variable] = max(0, floor(newval))

	proc/set_filter(category, atom/movable/sample)
		if (src.filter_class == category && src.focused_target == sample)
			return
		if (src.projection)
			qdel(src.projection)
		src.filter_class = category
		src.focused_target = sample
		var/marker_type = src.projection_types?[category]
		if (sample && ispath(marker_type, /obj/overlay/classifier_projection))
			src.projection = new marker_type(null, src, sample)
		SEND_SIGNAL(src, COMSIG_CLASSIFIER_CHANGED)

	proc/focus_on(atom/target)
		if (!src.can_scan())
			return
		var/list/visible_atoms = src.scan_view()
		var/atom/movable/subject = src.find_focus_target(target, visible_atoms)
		if (!subject)
			boutput(src.wearer, SPAN_ALERT("NO HIT // Aim at a visible classifier target."))
			return
		src.clear_boot()
		src.set_filter(src.classify(subject), subject)
		src.wearer.examine_verb(subject)
		src.wearer.playsound_local_not_inworld('sound/machines/tone_beep.ogg', 23, FALSE, flags = SOUND_SKIP_OBSERVERS)
		src.refresh_callouts(visible_atoms, announce = TRUE)

	proc/find_focus_target(atom/clicked, list/visible_atoms)
		var/turf/tile = isturf(clicked) ? clicked : clicked?.loc
		if (!istype(tile) || !(tile in visible_atoms))
			return null
		var/atom/movable/target = clicked
		if (istype(target) && (target in visible_atoms) && src.can_mark(target, src.classify(target)))
			return target

		// Spills are click-through.
		var/obj/fluid/spill = tile.active_liquid
		if (spill && src.can_mark(spill, src.classify(spill)))
			return spill
		for (var/atom/movable/candidate in visible_atoms)
			if (candidate.loc == tile && src.can_mark(candidate, src.classify(candidate)))
				return candidate
		return null

	proc/cycle_filter(mob/user)
		if (user != src.wearer || !src.can_scan())
			return
		src.clear_boot()
		SEND_SIGNAL(src, COMSIG_CLASSIFIER_CHANGED, TRUE)
		var/list/categories = src.category_types
		if (src.filter_order)
			categories = (src.filter_order & categories) | categories
		var/index = categories?.Find(src.filter_class)
		src.set_filter(index < length(categories) ? categories[index + 1] : null)
		src.refresh_callouts(announce = TRUE)

	proc/clear_callouts()
		src.last_label_layout = null
		for (var/atom/movable/target as anything in src.callouts)
			src.remove_callout(target)

	proc/remove_callout(atom/movable/target)
		var/datum/classifier_callout/callout = src.callouts?[target]
		if (!callout)
			return
		src.last_label_layout = null
		if (src.focused_target == target && !src.projection)
			src.set_filter(src.filter_class)
		callout.hide_from(src.viewer)
		src.callouts -= target
		src.UnregisterSignal(target, COMSIG_ATOM_PROP_MOB_INVISIBILITY)
		if (target != src.wearer)
			src.UnregisterSignal(target, COMSIG_PARENT_PRE_DISPOSING)
		qdel(callout)

	proc/source_active()
		if (src.wearer == src.parent)
			return TRUE
		var/obj/item/item = src.parent
		if (!item || item.loc != src.wearer)
			return FALSE
		var/mob/living/carbon/human/human = src.wearer
		return !istype(human) || human.get_slot(src.equipment_slot) == item

	proc/can_scan()
		if (!src.enabled || !src.viewer || src.viewer.eye != src.wearer || !src.source_active())
			return FALSE
		if (!isturf(src.wearer.loc) || isdead(src.wearer) || src.wearer.blinded)
			return FALSE
		var/mob/living/carbon/human/human = src.wearer
		return !istype(human) || human.last_eyes_blinded != (EYEBLIND_L | EYEBLIND_R)

	proc/scan_view(category)
		if (isnull(src.categories_by_type))
			src.build_rules()
		if (category ? src.unindexed_categories[category] : length(src.unindexed_categories))
			return view(src.viewer)
		if (src.wearer.sight & (SEE_TURFS | SEE_OBJS | SEE_MOBS | SEE_PIXELS | SEE_INFRA | BLIND))
			return view(src.viewer)

		var/list/visible = list()
		var/radius = 0
		for (var/turf/tile in view(src.viewer))
			visible[tile] = TRUE
			radius = max(radius, abs(tile.x - src.wearer.x), abs(tile.y - src.wearer.y))
		global.classifier_hashmap.add_visible_targets(src.viewer, visible, radius)
		return visible

	proc/refresh_callouts(list/visible_atoms, announce = FALSE)
		if (!src.can_scan())
			src.reset_display()
			return
		if (src.target_limit <= 0)
			src.clear_callouts()
			if (announce)
				boutput(src.wearer, SPAN_NOTICE("[src.display_name] // Markers disabled."))
			return
		if (isnull(visible_atoms))
			visible_atoms = src.scan_view(src.filter_class)

		var/list/label_layout = list(src.wearer.loc, src.focused_target, src.label_limit, src.label_attempt_limit)
		var/list/targets_by_turf = list()
		var/list/visible_spills = list()
		var/matches = 0
		for (var/atom/seen as anything in visible_atoms)
			var/atom/movable/target
			if (isturf(seen))
				var/turf/tile = seen
				label_layout += tile
				target = tile.active_liquid
			else if (ismovable(seen) && !istype(seen, /obj/fluid))
				target = seen
			if (!target)
				continue

			var/category = src.classify(target)
			if ((src.filter_class && category != src.filter_class) || !src.can_mark(target, category))
				continue
			var/turf/tile = target.loc

			var/obj/fluid/fluid = target
			if (istype(fluid))
				var/datum/classifier_spill/spill = visible_spills[fluid.group]
				if (!spill)
					spill = new
					visible_spills[fluid.group] = spill
				spill.include_tile(fluid, src)
				continue

			matches++
			var/atom/movable/previous = targets_by_turf[tile]
			if (previous && target != src.focused_target)
				if (previous == src.focused_target || src.callouts[previous])
					continue
				if (!src.callouts[target] && category != src.priority_category)
					continue
			targets_by_turf[tile] = target

		matches += length(visible_spills)
		var/list/distance_rings = list()
		var/list/placements = list()
		for (var/datum/fluid_group/group as anything in visible_spills)
			var/datum/classifier_spill/spill = visible_spills[group]
			src.queue_target(spill.anchor, distance_rings, placements)
		for (var/turf/tile as anything in targets_by_turf)
			src.queue_target(targets_by_turf[tile], distance_rings, placements)
		for (var/list/ring in distance_rings)
			for (var/atom/movable/target as anything in ring)
				placements[target] = CLASSIFIER_BRACKETS
				if (length(placements) >= src.target_limit)
					break
			if (length(placements) >= src.target_limit)
				break

		src.sync_callouts(visible_atoms, placements, visible_spills, label_layout)
		if (announce)
			boutput(src.wearer, SPAN_NOTICE("[src.display_name] // [src.filter_class || "ALL"] // [matches] targets, [length(placements)] marked."))

	proc/queue_target(atom/movable/target, list/distance_rings, list/placements)
		if (target == src.focused_target)
			placements[target] = CLASSIFIER_BRACKETS
			return
		var/ring_index = 1 + max(abs(target.x - src.wearer.x), abs(target.y - src.wearer.y))
		if (ring_index > length(distance_rings))
			distance_rings.len = ring_index
		var/list/ring = distance_rings[ring_index]
		if (!ring)
			ring = list()
			distance_rings[ring_index] = ring
		ring += target

	proc/build_label_cells(list/visible_atoms, list/placements)
		var/list/label_cells = list()
		var/tile_size = world.icon_size
		var/min_x = src.wearer.x
		var/max_x = min_x
		var/min_y = src.wearer.y
		var/max_y = min_y
		for (var/turf/tile in visible_atoms)
			label_cells[tile] = CLASSIFIER_CELL_FREE
			min_x = min(min_x, tile.x)
			max_x = max(max_x, tile.x)
			min_y = min(min_y, tile.y)
			max_y = max(max_y, tile.y)
		label_cells[src.wearer.loc] = FALSE
		for (var/atom/movable/target as anything in placements)
			var/datum/classifier_callout/callout = src.callouts[target]
			if (!callout.tile_left && !callout.tile_bottom && callout.frame_width == tile_size && callout.frame_height == tile_size)
				label_cells[target.loc] = FALSE
				continue
			var/right = callout.tile_left + callout.frame_width
			var/top = callout.tile_bottom + callout.frame_height
			var/first_x = max(min_x, target.x + floor(callout.tile_left / tile_size))
			var/last_x = min(max_x, target.x + floor((right - 1) / tile_size))
			var/first_y = max(min_y, target.y + floor(callout.tile_bottom / tile_size))
			var/last_y = min(max_y, target.y + floor((top - 1) / tile_size))
			for (var/tile_x in first_x to last_x)
				for (var/tile_y in first_y to last_y)
					var/turf/cell = locate(tile_x, tile_y, target.z)
					if (!label_cells[cell])
						continue
					var/cell_left = (tile_x - target.x) * tile_size
					var/cell_bottom = (tile_y - target.y) * tile_size
					if (cell_left >= callout.tile_left && cell_left + tile_size <= right \
						&& cell_bottom >= callout.tile_bottom && cell_bottom + tile_size <= top)
						label_cells[cell] = FALSE
						continue
					var/list/edges = label_cells[cell]
					if (!islist(edges))
						edges = list()
						label_cells[cell] = edges
					edges += callout
		return label_cells

	proc/place_labels(list/visible_atoms, list/placements)
		if (!length(placements) || src.label_limit <= 0 || src.label_attempt_limit <= 0)
			return
		var/list/label_cells = src.build_label_cells(visible_atoms, placements)
		var/label_count = 0
		var/attempts = 0
		var/list/unplaced = list()
		for (var/atom/movable/target as anything in placements)
			if (++attempts > src.label_attempt_limit)
				break
			var/datum/classifier_callout/callout = src.callouts[target]
			// Try the old corner first so labels don't jump around.
			var/corner = callout.side
			if (!corner || !src.claim_label_cells(target, callout, corner, label_cells))
				if (target != src.focused_target)
					unplaced += target
					continue
				corner = src.find_label_corner(target, callout, label_cells)
			if (corner)
				placements[target] = corner
				if (++label_count >= src.label_limit)
					return
		for (var/atom/movable/target as anything in unplaced)
			var/corner = src.find_label_corner(target, src.callouts[target], label_cells)
			if (corner)
				placements[target] = corner
				if (++label_count >= src.label_limit)
					return

	proc/find_label_corner(atom/movable/target, datum/classifier_callout/callout, list/label_cells)
		var/static/list/east_first = list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
		var/static/list/west_first = list(NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
		var/list/corners = target.x > src.wearer.x ? west_first : east_first
		for (var/corner in corners)
			if (corner != callout.side && src.claim_label_cells(target, callout, corner, label_cells))
				return corner
		return CLASSIFIER_BRACKETS

	proc/claim_label_cells(atom/movable/target, datum/classifier_callout/callout, corner, list/label_cells)
		var/tile_size = world.icon_size
		var/left = callout.tile_left + callout.label_left(corner)
		var/bottom = callout.tile_bottom + callout.label_bottom(corner)
		var/first_x = target.x + floor(left / tile_size)
		var/last_x = target.x + floor((left + CLASSIFIER_LABEL_WIDTH - 1) / tile_size)
		var/first_y = target.y + floor(bottom / tile_size)
		var/last_y = target.y + floor((bottom + CLASSIFIER_LABEL_HEIGHT - 1) / tile_size)
		for (var/tile_x in first_x to last_x)
			for (var/tile_y in first_y to last_y)
				var/turf/cell = locate(tile_x, tile_y, target.z)
				if (!label_cells[cell])
					return FALSE
				var/list/edges = label_cells[cell]
				if (islist(edges))
					for (var/datum/classifier_callout/edge as anything in edges)
						var/atom/anchor = edge.target
						var/edge_x = (anchor.x - target.x) * tile_size + edge.tile_left
						var/edge_y = (anchor.y - target.y) * tile_size + edge.tile_bottom
						if (left < edge_x + edge.frame_width && left + CLASSIFIER_LABEL_WIDTH > edge_x \
							&& bottom < edge_y + edge.frame_height && bottom + CLASSIFIER_LABEL_HEIGHT > edge_y)
							return FALSE
		for (var/tile_x in first_x to last_x)
			for (var/tile_y in first_y to last_y)
				label_cells[locate(tile_x, tile_y, target.z)] = FALSE
		return TRUE

	proc/sync_callouts(list/visible_atoms, list/placements, list/visible_spills, list/label_layout)
		var/max_frame_size = world.icon_size * max(1, src.max_frame_tiles)
		for (var/atom/movable/target as anything in src.callouts)
			if (isnull(placements[target]))
				src.remove_callout(target)
		for (var/atom/movable/target as anything in placements)
			var/datum/classifier_callout/callout = src.callouts[target]
			if (!callout)
				callout = new
				callout.target = target
				src.callouts[target] = callout
				src.RegisterSignal(target, COMSIG_ATOM_PROP_MOB_INVISIBILITY, PROC_REF(remove_callout))
				if (target != src.wearer)
					src.RegisterSignal(target, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(remove_callout))
			var/category = src.classify(target)
			if (callout.category != category)
				callout.category = category
				callout.delivery_changed = TRUE
				if (category == src.priority_category || ismob(target))
					callout.frame_flags &= ~RESET_ALPHA
				else
					callout.frame_flags |= RESET_ALPHA
			var/tint = src.class_color(category)
			if (callout.tint != tint)
				callout.tint = tint
				callout.delivery_changed = TRUE
			var/obj/fluid/fluid = target
			if (callout.measure(target, istype(fluid) ? visible_spills[fluid.group] : null, src.wearer, max_frame_size))
				src.last_label_layout = null
			label_layout += target
			label_layout += target.loc

		var/reuse_labels = (label_layout ~= src.last_label_layout)
		if (!reuse_labels)
			src.place_labels(visible_atoms, placements)
			src.last_label_layout = label_layout
		for (var/atom/movable/target as anything in placements)
			var/datum/classifier_callout/callout = src.callouts[target]
			var/corner = reuse_labels ? callout.side : placements[target]
			var/caption
			var/glitch_chance = 0
			if (corner)
				caption = src.caption_for(target, callout.category)
				if (callout.tile_count > 1)
					caption = "[caption] [callout.tile_count]T"
				glitch_chance = src.glitch_chance_for(target)
			var/focused = target == src.focused_target
			callout.present(src.viewer, corner, focused, caption, glitch_chance, focused ? src.projection : null)

	proc/can_mark(atom/movable/target, category)
		if (!category || QDELETED(target) || target.invisibility || !target.alpha || !isturf(target.loc) || target.plane == PLANE_UNDERFLOOR || !target.icon)
			return FALSE
		if (ismob(target))
			var/mob/creature = target
			return creature.alpha == 255 && !isdead(creature)
		if (istype(target, /obj/critter))
			var/obj/critter/critter = target
			return target.alpha == 255 && critter.alive
		var/obj/fluid/fluid = target
		if (istype(fluid))
			var/turf/tile = fluid.loc
			return tile.active_liquid == fluid && !QDELETED(fluid.group) && fluid.group.reagents?.total_volume > 0
		return TRUE

	proc/invalidate_rules()
		src.categories_by_type = null
		src.flavor_rule_by_type = null

	proc/classify(atom/movable/target)
		if (isnull(src.categories_by_type))
			src.build_rules()
		return src.categories_by_type[target.type]

	proc/build_rules()
		src.categories_by_type = list()
		for (var/category in src.category_types)
			src.register_types(src.category_types[category], category)
		src.register_types(src.excluded_types, FALSE)
		src.unindexed_categories = list()
		for (var/atom/movable/path as anything in src.categories_by_type)
			var/category = src.categories_by_type[path]
			if (category && !IS_CLASSIFIER_INDEXED_TYPE(path) && !ispath(path, /obj/fluid))
				src.unindexed_categories[category] = TRUE

	proc/register_types(list/roots, category)
		if (!islist(roots))
			return
		for (var/root_type in roots)
			if (!ispath(root_type, /atom/movable))
				continue
			for (var/subtype in typesof(root_type))
				src.categories_by_type[subtype] = category

	proc/caption_for(atom/movable/target, category)
		if (islist(src.flavor_labels) && length(src.flavor_labels))
			LAZYLISTINIT(src.flavor_rule_by_type)
			var/rule = src.flavor_rule_by_type[target.type]
			if (isnull(rule))
				rule = FALSE
				for (var/path in src.flavor_labels)
					if (ispath(path, /atom/movable) && istype(target, path) && (!rule || ispath(path, rule)))
						rule = path
				src.flavor_rule_by_type[target.type] = rule
			if (rule && istext(src.flavor_labels[rule]) && length(src.flavor_labels[rule]))
				return src.flavor_labels[rule]
		return src.category_labels[category] || category

	proc/class_color(category)
		return src.category_colors[category] || "#ffffff"

	proc/glitch_chance_for(atom/movable/target)
		return src.label_glitch_chance

/datum/classifier_spill
	var/obj/fluid/anchor
	var/anchor_rank
	/// Wet tile to center the frame on. The image stays attached to anchor.
	var/obj/fluid/sample
	var/sample_rank
	var/tile_count = 0
	var/min_x
	var/max_x
	var/min_y
	var/max_y

	proc/include_tile(obj/fluid/fluid, datum/component/visual_classifier/classifier)
		if (!src.tile_count)
			src.min_x = src.max_x = fluid.x
			src.min_y = src.max_y = fluid.y
		else
			src.min_x = min(src.min_x, fluid.x)
			src.max_x = max(src.max_x, fluid.x)
			src.min_y = min(src.min_y, fluid.y)
			src.max_y = max(src.max_y, fluid.y)
		src.tile_count++
		var/rank = max(abs(fluid.x - classifier.wearer.x), abs(fluid.y - classifier.wearer.y))
		if (fluid == classifier.focused_target)
			rank = -2
		if (!src.sample || rank < src.sample_rank)
			src.sample = fluid
			src.sample_rank = rank
		if (rank >= 0 && classifier.callouts[fluid])
			rank = -1
		if (!src.anchor || rank < src.anchor_rank)
			src.anchor = fluid
			src.anchor_rank = rank

#undef CLASSIFIER_CELL_FREE
#undef CLASSIFIER_BRACKETS
