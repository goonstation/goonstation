/datum/component/music_player_auto_linker
	var/list/music_players

TYPEINFO(/datum/component/music_player_auto_linker)
	initialization_args = list(
		ARG_INFO("initial_music_player", DATA_INPUT_REF, "The first music player to store", null),
		ARG_INFO("user", DATA_INPUT_REF, "The user who's using this", null)
	)

/datum/component/music_player_auto_linker/Initialize(atom/initial_music_player, atom/user)
	. = ..()
	if(
		!ispulsingtool(parent) ||
		initial_music_player == null ||
		user == null ||
		!istype(initial_music_player, /datum/text_to_music) ||
		!istype(user, /mob)
	)
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(store_music_player))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(finish_storing_music_players))
	src.music_players = list()
	src.start_storing_music_players(initial_music_player, user)

/datum/component/music_player_auto_linker/proc/can_store_music_player(datum/text_to_music/music_player, mob/user)
	if (music_player.is_busy)
		boutput(user, SPAN_ALERT("Can't link a busy music player!"))
		return FALSE
	if (!music_player.is_panel_exposed())
		boutput(user, SPAN_ALERT("Can't link without an exposed panel!"))
		return FALSE
	if (!music_player.is_comp_anchored())
		boutput(user, SPAN_ALERT("Can't link an unanchored music player!"))
		return FALSE
	if (length(music_player.linked_music_players))
		boutput(user, SPAN_ALERT("Can't link an already linked music player!"))
		return FALSE
	if (music_player in src.music_players)
		boutput(user, SPAN_ALERT("That music player is already stored!"))
		return FALSE
	if (music_player.is_stored)
		boutput(user, SPAN_ALERT("Another device has already stored that music player!"))
		return FALSE
	return TRUE

/datum/component/music_player_auto_linker/proc/link_music_players()
	var/list/linking_music_players = src.music_players.Copy()
	while (length(linking_music_players))
		var/datum/text_to_music/link_from = linking_music_players[1]
		linking_music_players.Cut(1,2)
		if (link_from == null)
			break
		for (var/datum/text_to_music/link_to as anything in linking_music_players)
			if (link_to == null)
				break
			link_from.add_music_player(link_to)
			link_to.add_music_player(link_from)
			sleep(0.1 SECOND)

/datum/component/music_player_auto_linker/proc/start_storing_music_players(var/datum/text_to_music/music_player, mob/user)
	boutput(user, SPAN_NOTICE("Now [parent] is storing music players to link. Use it in hand to link them."))
	music_player.is_stored = TRUE
	src.music_players.Add(music_player)
	boutput(user, SPAN_NOTICE("Stored music player."))
	return

/datum/component/music_player_auto_linker/proc/store_music_player(obj/item/pulser, atom/A, mob/user)
	if (!istype(A, /datum/text_to_music))
		return FALSE
	var/datum/text_to_music/music_player = A
	if (!src.can_store_music_player(music_player, user))
		return TRUE
	music_player.is_stored = TRUE
	src.music_players.Add(music_player)
	boutput(user, SPAN_NOTICE("Stored music player."))
	return TRUE

/datum/component/music_player_auto_linker/proc/finish_storing_music_players(obj/item/pulser, mob/user)
	if (length(src.music_players) < 2)
		boutput(user, SPAN_ALERT("You must have at least two music players to link!"))
		src.RemoveComponent()
		return TRUE
	boutput(user, SPAN_NOTICE("Linking [length(src.music_players)] music players..."))
	src.link_music_players()
	boutput(user, SPAN_NOTICE("Finished linking."))
	src.RemoveComponent()
	return TRUE

/datum/component/music_player_auto_linker/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACKBY_PRE)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	for (var/datum/text_to_music/music_player as anything in src.music_players)
		if (music_player != null)
			music_player.is_stored = FALSE
	. = ..()

// ----------------------------------------------------------------------------------------------------

/datum/component/music_player_auto_linker/player_piano

/datum/component/music_player_auto_linker/player_piano/store_music_player(obj/item/pulser, atom/A, mob/user)
	if (!istype(A, /obj/player_piano))
		return FALSE

	var/obj/player_piano/holder = A

	. = ..(pulser, holder.music_player, user)

// ----------------------------------------------------------------------------------------------------

/datum/component/music_player_auto_linker/mech_comp

/datum/component/music_player_auto_linker/mech_comp/store_music_player(obj/item/pulser, atom/A, mob/user)
	if (!istype(A, /obj/item/mechanics/text_to_music))
		return FALSE

	var/obj/item/mechanics/text_to_music/holder = A

	. = ..(pulser, holder.music_player, user)
