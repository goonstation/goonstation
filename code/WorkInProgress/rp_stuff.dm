
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-DESTINY-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/proc/get_random_station_turf()
	var/list/areas = get_areas(/area/station)
	if (!areas.len)
		return
	var/area/A = pick(areas)
	if (!A)
		return
	var/list/turfs = get_area_turfs(A, 1)
	if (!turfs.len)
		return
	var/turf/T = pick(turfs)
	if (!T)
		return
	return T

/obj/dummy_pad
	name = "teleport pad"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	anchored = 1
	density = 0

/client/proc/cmd_rp_rules()
	set name = "RP Rules"
	set category = "Commands"

	src.Browse( {"<center><h2>Goonstation RP Server Guidelines and Rules</h2></center><hr>
	Welcome to [station_name(1)]! Now, since as this server is intended for roleplay, there are some guidelines, rules and tips to make your time fun for everyone!<hr>
	<ul style='list-style-type:disc'>
		<li><b>These are extra rules.</b>
			<ul style='list-style-type:circle'>
				<li>The RP rules are an extension to the base rules, not a replacement for. Do not use roleplay as an excuse for rulebreaking behavior, such as bigoted language or sexual content. No, your character doesn�t get a free pass to be racist just because you�re trying to roleplay as a racist.</li>
			</ul>
		</li>
		<li><b>We're all here to have a good time.</b>
			<ul style='list-style-type:circle'>
				<li>Going out of your way to seriously negatively impact or end the round for someone with little to no justification is against the rules. Legitimate conflicts where people get upset do happen; however, these conflicts should escalate properly, and retribution must be proportionate. For example, this means you shouldn�t immediately escalate to murder when someone refuses to leave a certain area or give back something they stole.</li>
			</ul>
		</li>
		<li><b>Keep IC and OOC separate.</b>
			<ul style='list-style-type:circle'>
				<li>Do not use the OOC channel to spoil IC (In Character) events, such as the identity of an antagonist. Even if something seems minor to you, as long as it pertains to the current round and characters, you should not be mentioning it in OOC. Likewise, do not treat IC chat like OOC (saying things like ((this round is great)) over radio, etc).</li>
			</ul>
		</li>
		<li><b>Don�t use OOC information or knowledge that your character would not reasonably be aware of just to give yourself an advantage.</b>
			<ul style='list-style-type:circle'>
				<li>In other words, don�t powergame or metagame. This includes things such as shouting �LING!� right after you as a player realize that you�ve been stung, or rolling captain every round just to do genetics. Deadchat is considered OOC, and so you should not be using the information you learned from there to inform your IC decisions. Conversely, a changeling�s hivemind is considered IC, and so you should not be bringing in OOC content or information.</li>
			</ul>
		</li>
		<li><b>Play as a coherent, believable character that you enjoy portraying.</b>
			<ul style='list-style-type:circle'>
				<li>Real life realism is not required, and you are allowed to be silly within the context of the SS13 game world. (Clowns, farting on people, people spontaneously combusting and exploding are all non-serious things but yet a vital part of the game world.) <b>At the end of the day, it is very likely your character wants their employment with Nanotrasen to continue.</b> As such, they should act like it.</li>
				<li> Playing as a violent or otherwise psychologically unstable character is not a valid reason to cause harm to others or damage to the station unless you are an antagonist. Only minor criminal activity is permitted.</li>
			</ul>
		</li>
		<li><b>Chain of command and security are important.</b>
			<ul style='list-style-type:circle'>
				<li>The head of your department is your boss and they can fire you; security officers can arrest you for stealing or breaking into places. The preference would be that unless they're doing something unreasonable, such as spacing you for drawing bees on the floor, you shouldn't freak out over being punished for doing something that would get you fired or arrested in real life. This also means that if you are someone in the chain of command or security, you are expected to put in effort and try and do your job.</li>
			</ul>
		</li>
		<li><b>Stay in your lane.</b>
			<ul style='list-style-type:circle'>
				<li>While you are capable of doing anything within the game mechanics, allow those who have selected the relevant job to attempt the task first.</li>
				<li>As an example, busting into medical and self-treating would be a very strange real-life event if there are doctors literally standing there, and while a janitor mixing up some more space cleaner is believable, if there are scientists working in chemistry you should consider asking them to make you your space-cleaner beaker bombs. Choosing captain just to be sure you can go and work the genetics machine all round is not acceptable.</li>
			</ul>
		</li>
		<li><b>Self-defence is allowed to the extent of saving your own life.</b>
			<ul style='list-style-type:circle'>
				<li>Putting someone into critical condition is considered self-defence only if they attempted to severely harm or kill you. Preemptively disabling someone, responding with disproportionate force, or hitting someone while they are already downed is not self-defence. Minor assault and fistfights are acceptable, assuming that both players have a reasonable justification as to why the fight started. Assault without any provocation or warning is strictly disallowed under a majority of circumstances.</li>
			</ul>
		</li>
		<li><b>Look out for everyone. </b>
			<ul style='list-style-type:circle'>
				<li>Please be considerate of other players, as their experiences are just as important as your own. If you aren�t an antagonist and yet you really want to play out a hostage situation, or deep-fry someone, or be a rude dude in whatever way, confirm with the involved and affected players either IC or in LOOC first. If everyone agrees to being subjected to harm or terrorization, then you�re good to go. Please keep in mind that this rule does not protect you from IC consequences, such as getting arrested by security. </li>
				<li> If you are going to RP as a rude dude, given that your victims have given you the okay, you still have to own the responsibility that comes with your decision. This means, no, you can�t kill a security officer because they tried to arrest you for murdering the clown, even if the clown agreed to being murdered.</li>
			</ul>
		</li>
		<li><b>Have you been made an antagonist? </b>
			<ul style='list-style-type:circle'>
				<li>Treat your role as an interesting challenge and not an excuse to destroy other people�s game experience. Your actions should make the game more fun, more exciting and more enjoyable for everyone; you can treat your objectives as suggestions on what you should attempt to achieve but you are also allowed to ignore them if you have something more enjoyable in mind. You do NOT have to act in a nefarious or evil way, but you are not allowed to just go on a silent rampage and eliminate all the players in a power trip. It is the experience of everyone that matters, not just your own.</li>
			</ul>
		</li>
		<li><b>It is security�s job to stop antagonists.</b>
			<ul style='list-style-type:circle'>
				<li>If you are not part of the security team (HoS, Sec. Officer, Detective or Vice Officer), you should not go out of your way to hunt for potential antagonists. You are allowed to defend yourself and others from violent antagonists, but you should not act like a vigilante if a security force is present. The exception to this rule is when rare game modes such as blob or nuke ops appear on the RP server - you are free to fully engage with these antagonists, as they are considered stationwide threats.</li>
			</ul>
		</li>
		<li><b>Be kind to the bad guys.</b>
			<ul style='list-style-type:circle'>
				<li>Because antagonists are often the primary driver for rounds, some amount of goodwill should be extended to them. This means you should try to interact and communicate with antagonists and try to create an exciting narrative, rather than, say, immediately laser them to death when you see them. Communication and dialogue are expected on both ends.</li>
			</ul>
		</li>
	</ul>"}, "window=rprules;title=RP+Rules" )


/*
/obj/airlock_door
	icon = 'icons/obj/doors/animated.dmi'
	icon_state = "gen-left"
	density = 0
	opacity = 0
	var/obj/machinery/door/door = null

	attackby(obj/item/W, mob/M)
		if (src.door)
			src.door.attackby(W, M)

	attack_hand(mob/M)
		if (src.door)
			src.door.attack_hand(M)

	attack_ai(mob/user)
		if (src.door)
			src.door.attack_ai(user)

/obj/machinery/door/airlock/animated
	icon = 'icons/obj/doors/animated.dmi'
	icon_state = "track"
	var/obj/airlock_door/d_left = null
	var/d_left_state = "gen-left"
	var/obj/airlock_door/d_right = null
	var/d_right_state = "gen-right"

	New()
		..()
		src.d_right = new(src.loc)
		src.d_right.icon_state = src.d_right_state
		src.d_right.door = src
		// make left after right so it's on top
		src.d_left = new(src.loc)
		src.d_left.icon_state = src.d_left_state
		src.d_left.door = src

	update_icon()
		src.icon_state = "track"
		return
/*
		if (density)
			if (locked)
				icon_state = "[icon_base]_locked"
			else
				icon_state = "[icon_base]_closed"
			if (p_open)
				if (!src.panel_image)
					src.panel_image = image(src.icon, src.panel_icon_state)
				src.UpdateOverlays(src.panel_image, "panel")
			else
				src.UpdateOverlays(null, "panel")
			if (welded)
				if (!src.welded_image)
					src.welded_image = image(src.icon, src.welded_icon_state)
				src.UpdateOverlays(src.welded_image, "weld")
			else
				src.UpdateOverlays(null, "weld")
		else
			src.UpdateOverlays(null, "panel")
			src.UpdateOverlays(null, "weld")
			icon_state = "[icon_base]_open"
		return
*/
	play_animation(animation)
		switch (animation)
			if ("opening")
				animate(src.d_left, time = src.operation_time, pixel_x = -18, easing = BACK_EASING)
				animate(src.d_right, time = src.operation_time, pixel_x = 18, easing = BACK_EASING)
			if ("closing")
				animate(src.d_left, time = src.operation_time, pixel_x = 0, easing = ELASTIC_EASING)
				animate(src.d_right, time = src.operation_time, pixel_x = 0, easing = ELASTIC_EASING)
			if ("spark")
				flick("[d_left_state]_spark", d_left)
				flick("[d_right_state]_spark", d_right)
			if ("deny")
				flick("[d_left_state]_deny", d_left)
				flick("[d_right_state]_deny", d_right)
		return
*/
// TODO:
// - mailputt
// - mailputt pickup port

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-CONTROLLER=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
/datum/destiny_controller
	var/ship_direction = NORTH // the north of the ship should be on this side of the map, ex: cog2's north is to the east side of the map

/* outside the ship during start of warp:
 - throw them at direction opposite ship_direction
 - if they hit the edge and make it to z3, congrats!!
 - if they hit the ship, R  I  P
 - rad damage
 - wibbly effect for space
*/
	proc/enter_warp()
		for (var/mob/M in mobs)
			if (M.z != 1)
				continue
			var/turf/T = get_turf(M)
			if (!istype(T))
				continue
			var/area/A = T.loc
			if (A.type != /area) // not in empty space
				continue
*/
