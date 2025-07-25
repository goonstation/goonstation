#define MAX_DISKS 8
TYPEINFO(/obj/machinery/disk_rack)
	mats = list("metal" = 30, "conductive" = 10)

/obj/machinery/disk_rack
	name = "disk rack"
	desc = "A big clunky rack for storing floppy disks in."
	icon = 'icons/obj/disk_rack.dmi'
	icon_state = "disk_rack"
	layer = STORAGE_LAYER
	density = TRUE
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WIRECUTTERS | DECON_MULTITOOL
	requires_power = FALSE //we handle our own power stuff
	var/list/obj/item/disk/data/floppy/disks[MAX_DISKS]
	var/list/active_lights[MAX_DISKS]

/obj/machinery/disk_rack/was_deconstructed_to_frame(mob/user)
	. = ..()
	for (var/i in 1 to MAX_DISKS)
		if (disks[i])
			src.remove_disk(i)

/obj/machinery/disk_rack/update_icon(...)
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk)
			src.ClearSpecificOverlays("disks_[i]")
			continue
		var/image/overlay = image(src.icon, "disk_overlay")
		overlay.color = disk.disk_color
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, "disks_[i]")

/obj/machinery/disk_rack/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "DiskRack")
		ui.open()

/obj/machinery/disk_rack/ui_data(mob/user)
	var/list/disk_data[MAX_DISKS]
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (disk)
			var/name = disk.name_suffixes?[1] || disk.name
			var/regex/kill_brackets = regex(@"[\(\)]", "g")
			name = kill_brackets.Replace(name, "")
			disk_data[i] = list("name" = name, "color" = disk.disk_color)
			disk_data[i] += src.special_disk_data(disk, i)
	return list("disks" = disk_data)

/obj/machinery/disk_rack/proc/special_disk_data(obj/item/disk/data/floppy/disk, index)
	return list()

/obj/machinery/disk_rack/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .
	if (action == "action")
		var/index = text2num_safe(params["id"])
		if (index < 1 || index > MAX_DISKS) //nu
			return FALSE
		if (src.disks[index])
			src.remove_disk(index, ui.user)
			return TRUE
		var/obj/item/disk/data/floppy/disk = ui.user.equipped()
		if (!istype(disk))
			return FALSE
		src.insert_disk(index, disk, ui.user)
		return TRUE

/obj/machinery/disk_rack/proc/remove_disk(index, mob/user)
	var/obj/item/disk/data/floppy/disk = src.disks[index]
	disk.set_loc(get_turf(src))
	user?.put_in_hand_or_drop(disk)
	src.disks[index] = null
	playsound(src, 'sound/machines/law_insert.ogg', 60) //TODO: distinct sound for smaller disks?
	src.UpdateIcon()

/obj/machinery/disk_rack/proc/insert_disk(index, obj/item/disk/data/floppy/disk, mob/user)
	src.disks[index] = disk
	user.drop_item(disk)
	disk.set_loc(src)
	playsound(src, 'sound/machines/law_insert.ogg', 60) //TODO: distinct sound for smaller disks?
	src.UpdateIcon()

/obj/machinery/disk_rack/attackby(obj/item/disk/data/floppy/disk, mob/user)
	if (istype(disk))
		for (var/i in 1 to MAX_DISKS)
			if (src.disks[i])
				continue
			src.insert_disk(i, disk, user)
			tgui_process.update_uis(src)
			return
	. = ..()

/obj/machinery/disk_rack/clone
	name = "clone rack"
	desc = "A big clunky rack for storing cloning records in."
	icon_state = "clone_rack_med"
	var/emagged = FALSE

/// Does this disk have an active clone record of someone who is currently dead
/// AND do they have a cloning implant so we know about it?
/obj/machinery/disk_rack/clone/proc/cloneable_disk(obj/item/disk/data/floppy/disk)
	var/datum/computer/file/clone/clone_record = locate() in disk.root.contents
	if (!clone_record)
		return FALSE
	var/datum/mind/mind = clone_record.fields["mind"]
	var/mob/selected = mind?.current
	if (!selected || selected.mind?.get_player()?.dnr || !eligible_to_clone(mind))
		return FALSE
	if (isobserver(selected))
		var/mob/dead/ghost = selected
		selected = ghost.corpse
	if (!ishuman(selected)) //we don't know what the fuck that is, definitely can't clone it
		return FALSE
	var/mob/living/carbon/human/human = selected
	if (!locate(/obj/item/implant/cloner) in human.implant) //maybe they are cloneable but we don't know about it
		return FALSE
	return TRUE

/obj/machinery/disk_rack/clone/special_disk_data(obj/item/disk/data/floppy/disk, index)
	if (status & NOPOWER)
		return list("light" = FALSE)
	return list("light" = src.active_lights[index])

/obj/machinery/disk_rack/clone/ui_data(mob/user)
	return ..() + list("has_lights" = TRUE)

/obj/machinery/disk_rack/clone/process(mult)
	src.update_lights()

/obj/machinery/disk_rack/clone/remove_disk(index, mob/user)
	. = ..()
	src.update_lights()

#define LIGHT_KEY "angry_light_[i]"

/obj/machinery/disk_rack/clone/power_change()
	..()
	if (status & NOPOWER)
		for (var/i in 1 to MAX_DISKS)
			src.ClearSpecificOverlays(LIGHT_KEY)

/obj/machinery/disk_rack/clone/proc/update_lights()
	if (status & NOPOWER)
		return
	for (var/i in 1 to MAX_DISKS)
		var/obj/item/disk/data/floppy/disk = src.disks[i]
		if (!disk || !(src.cloneable_disk(disk) || src.emagged && prob(20)))
			src.active_lights[i] = FALSE
			src.ClearSpecificOverlays(LIGHT_KEY)
			continue
		src.active_lights[i] = TRUE
		if (src.GetOverlayImage(LIGHT_KEY))
			return
		var/image/overlay = image(src.icon, "angry_light")
		overlay.plane = PLANE_SELFILLUM
		overlay.pixel_y = (i-1) * 2
		src.UpdateOverlays(overlay, LIGHT_KEY)
#undef LIGHT_KEY

/obj/machinery/disk_rack/clone/emag_act(mob/user, obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	boutput(user, SPAN_ALERT("You short out [src]'s ImplantSense™ control module!"))
	src.emagged = TRUE
	src.processing_tier = PROCESSING_32TH
	return TRUE
