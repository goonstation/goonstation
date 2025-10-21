/// world Topic. This is where external shit comes into byond and does shit.
/world/Topic(T, addr, master, key)
	TGS_TOPIC	// logging for these is done in TGS

	var/cleanT = replacetext(T, regex(@"auth=[a-zA-Z0-9]*(;|&|$)"), "auth=***$1")
	logDiary("TOPIC: \"[cleanT]\", from:[addr], master:[master], key:[key]")
	Z_LOG_DEBUG("World", "TOPIC: \"[cleanT]\", from:[addr], master:[master], key:[key]")

	if (T == "ping")
		return src.total_player_count()
	else if(T == "players")
		return src.total_player_count()

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = (ticker?.hide_mode) ? "secret" : master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["station_name"] = station_name
		var/shuttle
		if (emergency_shuttle)
			if (emergency_shuttle.location == SHUTTLE_LOC_STATION) shuttle = 0 - emergency_shuttle.timeleft()
			else shuttle = emergency_shuttle.timeleft()
		else shuttle = "welp"
		s["shuttle_time"] = shuttle
		var/elapsed
		if (current_state < GAME_STATE_FINISHED)
			if (current_state <= GAME_STATE_PREGAME) elapsed = "pre"
			else if (current_state > GAME_STATE_PREGAME) elapsed = round(ticker.round_elapsed_ticks / 10)
		else if (current_state == GAME_STATE_FINISHED) elapsed = "post"
		else elapsed = "welp"
		s["elapsed"] = elapsed
		var/n = 0
		for(var/client/C in clients)
			if (C.stealth && !C.fakekey) // stealthed admins don't count
				continue
			s["player[n]"] = "[ckey((C.stealth || C.alt_key) ? C.fakekey : C.key)]"
			n++
		s["players"] = n
		s["map_name"] = getMapNameFromID(map_setting)
		s["map_id"] = map_setting
		return list2params(s)

	else // Discord bot communication (or callbacks)

		var/game_servers_response = game_servers?.topic(T, addr)
		if(!isnull(game_servers_response))
			return game_servers_response

#ifdef TWITCH_BOT_ALLOWED
		//boutput(world,"addres : [addr]     twitchbotaddr : [TWITCH_BOT_ADDR]")
		if (addr == TWITCH_BOT_ADDR)
			if (!twitch_mob || !twitch_mob.client)
				for (var/client/C in clients)
					if (C.ckey == TWITCH_BOT_CKEY)
						twitch_mob = C.mob
				if (!istype(twitch_mob))
					twitch_mob = 0
			//boutput(world,"twitch mob found? : [twitch_mob]")

			if (twitch_mob)
				var/list/plist = params2list(T)
				//boutput(world,"plist type? : [plist["type"]]")
				//boutput(world,"plist command? : [plist["command"]]")
				//boutput(world,"plist arg? : [plist["arg"]]")
				if (plist["type"] == "shittybill")
					switch(plist["command"])

						if("restart")
							if (twitch_mob.client)
								twitch_mob.client.restart_dreamseeker_js()
							return 1

						if("say")
							if (istype(twitch_mob,/mob/living/carbon/human/biker))
								var/mob/living/carbon/human/biker/H = twitch_mob
								H.speak()
							return 1

						if("move")
							if (!plist["arg"]) return 0

							var/dir = plist["arg"]
							dir = trimtext(copytext(sanitize(dir), 1, MAX_MESSAGE_LEN))
							dir = text2dir(dir)

							switch(dir)
								if(NORTH)
									twitch_mob.keys_changed(KEY_FORWARD, KEY_FORWARD)
								if(SOUTH)
									twitch_mob.keys_changed(KEY_BACKWARD, KEY_BACKWARD)
								if(EAST)
									twitch_mob.keys_changed(KEY_RIGHT, KEY_RIGHT)
								if(WEST)
									twitch_mob.keys_changed(KEY_LEFT, KEY_LEFT)
								if(NORTHEAST)
									twitch_mob.keys_changed(KEY_FORWARD|KEY_RIGHT, KEY_FORWARD|KEY_RIGHT)
								if(SOUTHEAST)
									twitch_mob.keys_changed(KEY_BACKWARD|KEY_RIGHT, KEY_BACKWARD|KEY_RIGHT)
								if(NORTHWEST)
									twitch_mob.keys_changed(KEY_FORWARD|KEY_LEFT, KEY_FORWARD|KEY_LEFT)
								if(SOUTHWEST)
									twitch_mob.keys_changed(KEY_BACKWARD|KEY_LEFT, KEY_BACKWARD|KEY_LEFT)

							SPAWN(1 DECI SECOND)
								twitch_mob.keys_changed(0,0xFFFF)

							return 1

						if("intent")
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							if (msg == INTENT_HELP || msg == INTENT_DISARM || msg == INTENT_GRAB || msg == INTENT_HARM)
								twitch_mob.set_a_intent(lowertext(msg))
							return 1

						if("attack")
							if (!plist["arg"]) return 0
							if (twitch_mob.next_click > world.time) return 1

							var/dir = plist["arg"]
							dir = trimtext(copytext(sanitize(dir), 1, MAX_MESSAGE_LEN))
							dir = text2dir(dir)

							if (dir == 0)
								if (ishuman(twitch_mob))
									var/mob/living/carbon/human/H = twitch_mob
									var/trg = plist["arg"]
									trg = trimtext(copytext(sanitize(trg), 1, MAX_MESSAGE_LEN))
									H.auto_interact(trg)

							var/turf/target = get_ranged_target_turf(twitch_mob, dir, 7)
							//twitch_mob.click(get_edge_target_turf(twitch_mob, dir), location = "map")
							//twitch_mob.client.Click(target,target)

							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob

								if (twitch_mob.a_intent != INTENT_HARM && twitch_mob.a_intent != INTENT_DISARM)
									twitch_mob.set_a_intent(INTENT_HARM)

								var/obj/item/equipped = H.equipped()
								var/list/p = list()
								p["left"] = 1
								if (equipped)
									H.weapon_attack(target, equipped, reach = 0, params = p)
								else
									H.hand_range_attack(target, params = p)
								twitch_mob.next_click = world.time + twitch_mob.combat_click_delay

							return 1

						if("throw")
							if (!plist["arg"]) return 0

							var/dir = plist["arg"]
							dir = trimtext(copytext(sanitize(dir), 1, MAX_MESSAGE_LEN))
							dir = text2dir(dir)

							if (ishuman(twitch_mob))
								if (istype(twitch_mob.loc, /turf/space) || twitch_mob.no_gravity) //they're in space, move em one space in the opposite direction
									twitch_mob.inertia_dir = turn(dir, 180)
									step(twitch_mob, twitch_mob.inertia_dir)

								twitch_mob.drop_item_throw_dir(dir)
							return 1

						if("switchhand")
							twitch_mob.hotkey("swaphand")
							return 1

						if("equip")
							twitch_mob.hotkey("equip")
							return 1

						if("drop")
							twitch_mob.hotkey("drop")
							return 1

						if("use")
							twitch_mob.hotkey("attackself")
							return 1

						if("target")
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							twitch_mob.hotkey(msg)
							return 1

						if("walk")
							if (twitch_mob.m_intent != "walk")
								twitch_mob.hotkey("walk")
							return 1

						if("run")
							if (twitch_mob.m_intent != "run")
								twitch_mob.hotkey("walk")
							return 1

						if("emote")
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							if (msg == "faint" || msg == "collapse") return 1 //nope!

							twitch_mob.emote(msg,voluntary = 0)
							return 1

						if("pickup")
							if (!plist["arg"]) return 0
							if (isdead(twitch_mob)) return 1

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							var/list/hudlist = list()
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								for (var/obj/item/I in H.contents)
									if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts) || istype(I,/atom/movable/screen/hud)) continue //FUCK
									hudlist += I
									if (I.storage)
										hudlist += I.storage.get_contents()

							var/list/close_match = list()
							for (var/obj/item/I in view(1,twitch_mob) + hudlist)
								if (!isturf(I.loc)) continue
								if (TWITCH_BOT_INTERACT_BLOCK(I)) continue
								if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts) || istype(I,/atom/movable/screen/hud)) continue //FUCK
								if (I.name == msg)
									close_match.len = 0
									close_match += I
									break
								else if (findtext(I.name,msg))
									close_match += I


							twitch_mob.put_in_hand(pick(close_match), twitch_mob.hand)
							return 1

						if("interact") //mostly same as above
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.auto_interact(msg)
							return 1

						if("pull")
							if (!plist["arg"])
								twitch_mob.set_pulling(null)
								return 0
							if (isdead(twitch_mob)) return 1

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

							var/list/close_match = list()
							for (var/atom/movable/I in view(1,twitch_mob))
								if (I.anchored || I.mouse_opacity == 0) continue
								if (I.name == msg)
									close_match.len = 0
									close_match += I
									break
								else if (findtext(I.name,msg))
									close_match += I

							twitch_mob.set_pulling(pick(close_match))
							return 1

						if("resist")
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.resist()
							return 1

						if("rest")
							if(ON_COOLDOWN(twitch_mob, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.setStatus("resting", INFINITE_STATUS)
								H.force_laydown_standup()
								H.hud.update_resting()
							return 1

						if("stand")
							if(ON_COOLDOWN(twitch_mob, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.delStatus("resting")
								H.force_laydown_standup()
								H.hud.update_resting()
							return 1

						if("eject")
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob

								if (istype(H.loc,/obj/machinery/vehicle))
									var/obj/machinery/vehicle/V = H.loc
									V.eject(twitch_mob)
								else if (istype(H.loc,/obj/vehicle))
									var/obj/vehicle/V = H.loc
									V.eject_rider(0, 1)

							return 1

						if("ooc") //this one is twitchadmins only
							if (!plist["arg"]) return 0

							var/msg = plist["arg"]
							msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
							if (ishuman(twitch_mob))
								var/mob/living/carbon/human/H = twitch_mob
								H.ooc(msg)
							return 1
#endif

		if (findtext(addr, ":")) // remove port if present
			addr = splittext(addr, ":")[1]
		if (addr != config.ircbot_ip && addr != config.goonhub_api_ip)
			return 0 //ip filtering

		var/list/plist = params2list(T)

		if (T == "admins")
			var/list/s = list()
			var/n = 0
			for(var/client/C)
				if(C.holder)
					s["admin[n]"] = (C.stealth ? "~" : "") + C.key
					n++
			s["admins"] = n
			return list2params(s)
		else if (T == "mentors")
			var/list/s = list()
			var/n = 0
			for(var/client/C)
				if(!C.holder && C.is_mentor())
					s["mentor[n]"] = C.key
					n++
			s["mentors"] = n
			return list2params(s)

		switch(plist["type"])
			if("irc")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]
				msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
				msg = discord_emojify(msg)

				logTheThing(LOG_OOC, null, "Discord OOC: [nick]: [msg]")

				if (nick == "buttbot")
					for (var/obj/machinery/bot/buttbot/B in machine_registry[MACHINES_BOTS])
						if(B.on)
							B.say(msg)
					return 1

				//This is important.
				else if (nick == "HeadSurgeon")
					for (var/obj/machinery/bot/medbot/head_surgeon/HS in machine_registry[MACHINES_BOTS])
						if (HS.on)
							HS.say(msg)
					for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/HS in world)
						LAGCHECK(LAG_LOW)
						HS.say(msg)
					return 1

				return 0

			if("ooc")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]

				msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
				msg = discord_emojify(msg)
				logTheThing(LOG_OOC, nick, "OOC: [msg]")
				logTheThing(LOG_DIARY, nick, ": [msg]", "ooc")
				var/rendered = SPAN_ADMINOOC("[SPAN_PREFIX("OOC:")] [SPAN_NAME("[nick]:")] [SPAN_MESSAGE("[msg]")]")

				for (var/client/C in clients)
					if (C.preferences && !C.preferences.listen_ooc)
						continue
					boutput(C, rendered)

				var/ircmsg[] = new()
				ircmsg["msg"] = msg
				return ircbot.response(ircmsg)

			if("asay")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]

				if(copytext(msg, 1, 2) == SPACEBEE_EXTENSION_ASAY_PREFIX)
					spacebee_extension_system?.process_asay(msg, nick)
					var/ircmsg[] = new()
					ircmsg["key"] = nick
					ircmsg["msg"] = msg
					return ircbot.response(ircmsg)

				msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
				msg = linkify(msg)
				msg = discord_emojify(msg)

				logTheThing(LOG_ADMIN, null, "Discord ASAY: [nick]: [msg]")
				logTheThing(LOG_DIARY, null, "Discord ASAY: [nick]: [msg]", "admin")
				var/rendered = SPAN_ADMIN("[SPAN_PREFIX("")] [SPAN_NAME("[nick]:")] <span class='message adminMsgWrap'>[msg]</span>")

				message_admins(rendered, 1, 1)

				var/ircmsg[] = new()
				ircmsg["key"] = nick
				ircmsg["msg"] = msg
				return ircbot.response(ircmsg)

			if("fpm")
				if (!plist["nick"] || !plist["msg"]) return 0

				var/server_name = plist["server_name"]
				if (!server_name)
					server_name = "GOON-???"
				var/nick = plist["nick"]
				var/msg = plist["msg"]
				msg = trimtext(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))

				logTheThing(LOG_ADMIN, null, "[server_name] PM: [nick]: [msg]")
				logTheThing(LOG_DIARY, null, "[server_name] PM: [nick]: [msg]", "admin")
				var/rendered = SPAN_ADMIN("[SPAN_PREFIX("[server_name] PM:")] [SPAN_NAME("[nick]:")] <span class='message adminMsgWrap'>[msg]</span>")

				for (var/client/C)
					if (C.holder)
						boutput(C.mob, rendered)

				var/ircmsg[] = new()
				ircmsg["key"] = nick
				ircmsg["msg"] = msg
				return ircbot.response(ircmsg)

			if("pm")
				// @TODO This is the other gross adminhelp stuff.
				// It should be combined with the crap in
				// code/modules/admin/adminhelp.dm
				// or something. ugh
				if (!plist["nick"] || !plist["msg"] || !plist["target"]) return 0

				var/nick = plist["nick"]
				var/msg = plist["msg"]
				var/who = lowertext(plist["target"])
				var/game_msg = linkify(msg)
				var/msgid = plist["msgid"]
				game_msg = discord_emojify(game_msg)

				var/mob/M = ckey_to_mob(who, exact=0)
				if (M?.client)
					boutput(M, {"
						<div style='border: 2px solid red; font-size: 110%;'>
							<div style="color: black; background: #f88; font-weight: bold; border-bottom: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
								Admin PM from <a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]&msgid=[msgid]\">[nick]</a>
							</div>
							<div style="padding: 0.2em 0.5em;">
								[game_msg]
							</div>
							<div style="font-size: 90%; background: #fcc; font-weight: bold; border-top: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
								<a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]&msgid=[msgid]" style='color: #833; font-weight: bold;'>&lt; Click to Reply &gt;</a></div>
							</div>
						</div>
						"}, forceScroll=TRUE)
					M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
					logTheThing(LOG_AHELP, null, "Discord: [nick] PM'd [constructTarget(M,"admin_help")]: [msg]")
					logTheThing(LOG_DIARY, null, "Discord: [nick] PM'd [constructTarget(M,"diary")]: [msg]", "ahelp")
					M.client.make_sure_chat_is_open()
					for (var/client/C)
						if (C.holder && C.key != M.key)
							if (C.player_mode && !C.player_mode_ahelp)
								continue
							else
								boutput(C, SPAN_AHELP("<b>PM: <a href=\"byond://?action=priv_msg_irc&nick=[ckey(nick)]&msgid=[msgid]\">[nick]</a> (Discord) <i class='icon-arrow-right'></i> [key_name(M, additional_url_data="&msgid=[msgid]")]</b>: [game_msg]"))

				if (M)
					var/ircmsg[] = new()
					ircmsg["key"] = nick
					ircmsg["key2"] = (M.client != null && M.client.key != null) ? M.client.key : "*no client*"
					ircmsg["name2"] = (M.real_name != null) ? stripTextMacros(M.real_name) : ""
					ircmsg["msg"] = html_decode(msg)
					return ircbot.response(ircmsg)
				else
					return 0

			if("mentorpm")
				if (!plist["nick"] || !plist["msg"] || !plist["target"]) return 0

				var/nick = plist["nick"]
				var/msg = html_encode(plist["msg"])
				var/who = lowertext(plist["target"])
				var/mob/M = ckey_to_mob(who, exact=0)
				var/game_msg = linkify(msg)
				var/msgid = plist["msgid"]
				game_msg = discord_emojify(game_msg)

				if (M?.client)
					boutput(M, SPAN_MHELP("<b>MENTOR PM: FROM <a href=\"byond://?action=mentor_msg_irc&nick=[ckey(nick)]&msgid=[msgid]\">[nick]</a> (Discord)</b>: [SPAN_MESSAGE("[game_msg]")]"))
					M.playsound_local_not_inworld('sound/misc/mentorhelp.ogg', 100, flags = SOUND_IGNORE_SPACE | SOUND_SKIP_OBSERVERS | SOUND_IGNORE_DEAF, channel = VOLUME_CHANNEL_MENTORPM)
					logTheThing(LOG_ADMIN, null, "Discord: [nick] Mentor PM'd [constructTarget(M,"admin")]: [msg]")
					logTheThing(LOG_DIARY, null, "Discord: [nick] Mentor PM'd [constructTarget(M,"diary")]: [msg]", "admin")

					var/M_keyname = key_name(M, 0, 0, 1, additional_url_data="&msgid=[msgid]")
					for (var/client/C)
						if (C.can_see_mentor_pms() && C.key != M.key)
							if(C.holder)
								if (C.player_mode && !C.player_mode_mhelp)
									continue
								else
									boutput(C, SPAN_MHELP("<b>MENTOR PM: [nick] (Discord) <i class='icon-arrow-right'></i> [M_keyname][(C.mob.real_name ? "/"+M.real_name : "")] <A HREF='byond://?src=\ref[C.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [SPAN_MESSAGE("[game_msg]")]"))
							else
								boutput(C, SPAN_MHELP("<b>MENTOR PM: [nick] (Discord) <i class='icon-arrow-right'></i> [M_keyname]</b>: [SPAN_MESSAGE("[game_msg]")]"))

				if (M)
					var/ircmsg[] = new()
					ircmsg["key"] = nick
					ircmsg["key2"] = (M.client != null && M.client.key != null) ? M.client.key : "*no client*"
					ircmsg["name2"] = (M.real_name != null) ? stripTextMacros(M.real_name) : ""
					ircmsg["msg"] = html_decode(msg)
					return ircbot.response(ircmsg)
				else
					return 0

			if("whois")
				if (!plist["target"]) return 0

				var/list/whom = splittext(plist["target"], ",")
				if (length(whom))
					var/list/parsedWhois = list()
					var/count = 0
					var/list/whois_result
					for (var/who in whom)
						whois_result = whois(who)
						if (whois_result)
							for (var/mob/M in whois_result)
								count++
								var/role = getRole(M, 1)
								if (M.name) parsedWhois["name[count]"] = M.name
								if (M.key) parsedWhois["ckey[count]"] = M.key
								if (isdead(M)) parsedWhois["dead[count]"] = 1
								if (role) parsedWhois["role[count]"] = role
								if (M.mind?.is_antagonist()) parsedWhois["t[count]"] = 1
					parsedWhois["count"] = count
					return ircbot.response(parsedWhois)
				else
					return 0

			if ("antags")
				var/list/badGuys = list()
				var/count = 0

				for (var/client/C in clients)
					if (C.mob)
						var/mob/M = C.mob
						if (M.mind && M.mind.special_role != null)
							count++
							var/role = getRole(M, 1)
							if (M.name) badGuys["name[count]"] = M.name
							if (M.key) badGuys["ckey[count]"] = M.key
							if (isdead(M)) badGuys["dead[count]"] = 1
							if (role) badGuys["role[count]"] = role
							if (M.mind?.is_antagonist()) badGuys["t[count]"] = 1

				badGuys["count"] = count
				return ircbot.response(badGuys)

/*
			<ErikHanson> topic call, type=reboot reboots a server.. without a password, or any form of authentication.
			well there, i've fixed it. -drsingh

			if("reboot")
				var/ircmsg[] = new()
				ircmsg["msg"] = "Attempting to restart now"

				Reboot_server()
				return ircbot.response(ircmsg)
*/
			if ("heal")
				if (!plist["nick"] || !plist["target"]) return 0

				var/nick = plist["nick"]
				var/who = lowertext(plist["target"])
				var/list/found = list()
				for (var/mob/M in mobs)
					if (M.ckey && (findtext(M.real_name, who) || findtext(M.ckey, who)))
						M.full_heal()
						logTheThing(LOG_ADMIN, nick, "healed / revived [constructTarget(M,"admin")]")
						logTheThing(LOG_DIARY, nick, "healed / revived [constructTarget(M,"diary")]", "admin")
						message_admins(SPAN_ALERT("Admin [nick] healed / revived [key_name(M)] from Discord!"))

						var/ircmsg[] = new()
						ircmsg["type"] = "heal"
						ircmsg["who"] = who
						ircmsg["msg"] = "Admin [nick] healed / revived [M.ckey]"
						found.Add(ircmsg)

				if (length(found))
					return ircbot.response(found)
				else
					return 0

			if ("roundEnd")
				if (!plist["server"] || !plist["address"]) return 0

				var/server = plist["server"]
				var/address = plist["address"]
				var/msg = "<br><div style='text-align: center; font-weight: bold;' class='deadsay'>---------------------<br>"
				msg += "A round just ended on [server]<br>"
				msg += "<a href='[address]'>Click here to join the next one!</a><br>"
				msg += "---------------------</div><br>"
				for (var/client/C)
					if (isdead(C.mob))
						boutput(C.mob, msg)

				return 1

			if ("mysteryPrint")
				if (!plist["print_title"] || !plist["print_file"]) return 0

				var/msgTitle = plist["print_title"]
				var/msgFile = "strings/mysteryprint/"+plist["print_file"]
				if (!fexists(msgFile)) return 0
				var/msgText = file2text(msgFile)

				//Prints to every networked printer in the world
				for (var/obj/machinery/networked/printer/P as anything in machine_registry[MACHINES_PRINTERS])
					P.print_buffer += "[msgTitle]&title;[msgText]"
					P.print()

				return 1

			if ("numbersStation")
				if (!plist["numbers"]) return 0

				lincolnshire_numbers(plist["numbers"])

				return 1

			//Tells shitbee what the current AI laws are (if there are any custom ones)
			if ("ailaws")
				if (current_state > GAME_STATE_PREGAME)
					var/ircmsg[] = new()
					ircmsg["laws"] = ticker.ai_law_rack_manager.format_for_logs(glue = "\n", round_end = TRUE, include_link = FALSE)
					return ircbot.response(ircmsg)
				else
					return 0

			if ("health")
				var/ircmsg[] = new()
				ircmsg["cpu"] = world.cpu
				ircmsg["map_cpu"] = world.map_cpu
				ircmsg["clients"] = length(clients)
				ircmsg["queue_len"] = delete_queue ? delete_queue.count() : 0
				var/curtime = world.timeofday
				sleep(1 SECOND)
				ircmsg["time"] = (world.timeofday - curtime) / 10
				ircmsg["ticklag"] = world.tick_lag
				ircmsg["runtimes"] = global.runtime_count
				if(world.system_type == "UNIX")
					var/list/meminfos = list()
					try
						var/meminfo_file = "data/meminfo.txt"
						fcopy("/proc/meminfo", meminfo_file)
						var/list/memory_info = splittext(file2text(meminfo_file), "\n")
						if(length(memory_info) >= 3)
							memory_info.len = 3
							meminfos += memory_info
						fdel(meminfo_file)
					catch(var/exception/e)
						stack_trace("[e.name]\n[e.desc]")
					try
						var/statm_file = "data/statm.txt"
						fcopy("/proc/self/statm", statm_file)
						var/list/memory_info = splittext(file2text(statm_file), " ")
						var/list/field_names = list("size", "resident", "share", "text", "lib", "data", "dt")
						for(var/i = 1, i <= length(memory_info), i++)
							meminfos += field_names[i] + ": " + memory_info[i]
						fdel(statm_file)
					catch(var/exception/e2)
						stack_trace("[e2.name]\n[e2.desc]")
					if(length(meminfos))
						ircmsg["meminfo"] = jointext(meminfos, "\n")
				return ircbot.response(ircmsg)

			if ("rev")
				var/ircmsg[] = new()
				var/message_to_send = copytext(ORIGIN_REVISION, 1, 8) + " by " + ORIGIN_AUTHOR
				#ifdef TESTMERGE_PRS
				message_to_send += " + testmerges ([copytext(VCS_REVISION, 1, 8)] | [jointext(TESTMERGE_PRS, ", ")])"
				#endif
				ircmsg["msg"] = message_to_send
				return ircbot.response(ircmsg)

			if ("version")
				var/ircmsg[] = new()
				ircmsg["major"] = world.byond_version
				ircmsg["minor"] = world.byond_build
				ircmsg["goonhub_api"] = apiHandler.enabled ? "Enabled" : "Disabled"
				return ircbot.response(ircmsg)

			if ("youtube")
				if (!plist["data"]) return 0

				play_music_remote(json_decode(plist["data"]), from_topic = TRUE)

				// trigger cooldown so radio station doesn't interrupt our cool music
				var/duration = text2num(plist["duration"])
				EXTEND_COOLDOWN(global, "music", duration SECONDS)
				return 1

			if ("delay")
				var/ircmsg[] = new()

				if (game_end_delayed == 0)
					game_end_delayed = 1
					game_end_delayer = plist["nick"]
					logTheThing(LOG_ADMIN, null, "[game_end_delayer] delayed the server restart from Discord.")
					logTheThing(LOG_DIARY, null, "[game_end_delayer] delayed the server restart from Discord.", "admin")
					message_admins(SPAN_INTERNAL("[game_end_delayer] delayed the server restart from Discord."))
					ircmsg["msg"] = "Server restart delayed. Use undelay to cancel this."
				else
					ircmsg["msg"] = "The server restart is already delayed, use undelay to cancel this."

				return ircbot.response(ircmsg)

			if ("undelay")
				var/ircmsg[] = new()

				if (game_end_delayed == 0)
					ircmsg["msg"] = "The server restart isn't delayed."
					return ircbot.response(ircmsg)

				else if (game_end_delayed == 1)
					game_end_delayed = 0
					game_end_delayer = plist["nick"]
					logTheThing(LOG_ADMIN, null, "[game_end_delayer] removed the restart delay from Discord.")
					logTheThing(LOG_DIARY, null, "[game_end_delayer] removed the restart delay from Discord.", "admin")
					message_admins(SPAN_INTERNAL("[game_end_delayer] removed the restart delay from Discord."))
					game_end_delayer = null
					ircmsg["msg"] = "Removed the restart delay."
					return ircbot.response(ircmsg)

				else if (game_end_delayed == 2)
					game_end_delayer = plist["nick"]
					logTheThing(LOG_ADMIN, null, "[game_end_delayer] removed the restart delay from Discord and triggered an immediate restart.")
					logTheThing(LOG_DIARY, null, "[game_end_delayer] removed the restart delay from Discord and triggered an immediate restart.", "admin")
					message_admins("<span class='internal>[game_end_delayer] removed the restart delay from Discord and triggered an immediate restart.</span>")
					ircmsg["msg"] = "Removed the restart delay."

					SPAWN(1 DECI SECOND)
						ircbot.event("roundend")
						Reboot_server()

					return ircbot.response(ircmsg)

			if ("triggerMapSwitch")
				if (!plist["nick"] || !plist["map"])
					return 0

				if (!config.allow_map_switching)
					return ircbot.response(list("msg" = "Map switching is disabled on this server."))

				var/nick = plist["nick"]
				var/map = uppertext(plist["map"])
				var/mapName = getMapNameFromID(map)
				var/ircmsg[] = new()
				try
					mapSwitcher.setNextMap(nick, mapID = map)
					ircmsg["msg"] = "Map switched to [mapName]"
				catch (var/exception/e)
					ircmsg["msg"] = e.name

				logTheThing(LOG_ADMIN, nick, "set the next round's map to [mapName] from Discord")
				logTheThing(LOG_DIARY, nick, "set the next round's map to [mapName] from Discord", "admin")
				message_admins("[nick] set the next round's map to [mapName] from Discord")

				return ircbot.response(ircmsg)

			if ("whitelistChange")
				if (!plist["wlType"] || !plist["ckey"])
					return 0

				var/type = plist["wlType"]
				var/ckey = plist["ckey"]
				var/msg

				if (type == "add" && !(ckey in whitelistCkeys))
					whitelistCkeys += ckey
					msg = "Entry '[ckey]' added to whitelist"
				else if (type == "remove" && (ckey in whitelistCkeys))
					whitelistCkeys -= ckey
					msg = "Entry '[ckey]' removed from whitelist"

				if (msg)
					logTheThing(LOG_ADMIN, null, msg)
					logTheThing(LOG_DIARY, null, msg, "admin")

				return 1

			if ("getNotes")
				if (!plist["ckey"])
					return 0

				try
					var/datum/apiRoute/players/notes/get/getPlayerNotes = new
					getPlayerNotes.queryParams = list(
						"filters" = list(
							"ckey" = plist["ckey"]
						)
					)
					return apiHandler.queryAPI(getPlayerNotes)
				catch
					return FALSE

			if ("getPlayerStats")
				if (!plist["ckey"])
					return 0

				var/datum/apiModel/Tracked/PlayerStatsResource/playerStats
				try
					var/datum/apiRoute/players/stats/get/getPlayerStats = new
					getPlayerStats.queryParams = list("ckey" = plist["ckey"])
					playerStats = apiHandler.queryAPI(getPlayerStats)
				catch
					return FALSE

				var/list/response = list(
					"seen" = playerStats.connected,
					"seen_rp" = playerStats.connected_rp,
					"participated" = playerStats.played,
					"participated_rp" = playerStats.played_rp,
					"playtime" = playerStats.time_played
				)

				var/datum/player/player = make_player(plist["ckey"])
				if(!player.cached_round_stats)
					player.cache_round_stats_blocking()
				if(player)
					response["last_seen"] = player.last_seen
				player?.cloudSaves.fetch()
				for(var/kkey in player?.cloudSaves.data)
					if((kkey in list("admin_preferences", "buildmode")) || findtext(kkey, regex(@"^custom_job_\d+$")))
						continue
					response[kkey] = player?.cloudSaves.data[kkey]
				response["cloudsaves"] = player?.cloudSaves.saves

				return json_encode(response)

			if("profile")
				var/type = plist["profiler_type"]
				if(type != "sendmaps")
					type = null
				if(plist["action"] == "save")
					var/static/profilerLogID = 0
					var/output = world.Profile(PROFILE_REFRESH, type, "json")
					var/fname = "data/logs/profiling/[global.roundLog_date]_manual_[profilerLogID++].json"
					rustg_file_write(output, fname)
					return fname
				var/action = list(
					"stop" = PROFILE_STOP,
					"clear" = PROFILE_CLEAR,
					"start" = PROFILE_START,
					"refresh" = PROFILE_REFRESH,
					"restart" = PROFILE_RESTART
				)[plist["action"]]
				var/final_action = action
				if(plist["average"])
					final_action |= PROFILE_AVERAGE
				if(plist["action"] == "stop")
					lag_detection_process.manual_profiling_on = FALSE
				else if(plist["action"] == "start")
					lag_detection_process.manual_profiling_on = TRUE
				var/output = world.Profile(final_action, type, "json")
				if(plist["action"] == "refresh" || plist["action"] == "stop")
					SPAWN(1)
						var/n_tries = 3
						var/datum/http_response/response = null
						while(--n_tries > 0 && (isnull(response) || response.errored))
							var/datum/http_request/request = new()
							request.prepare(RUSTG_HTTP_METHOD_POST, "[config.irclog_url]/profiler_result", output, "")
							request.begin_async()
							UNTIL(request.is_complete(), 10 SECONDS)
							response = request.into_response()
				return 1

			if("persistent_canvases")
				var/list/response = list()
				for_by_tcl(canvas, /obj/item/canvas/big_persistent)
					response[canvas.id] = icon2base64(canvas.art)
				return json_encode(response)

			if("lazy_canvas_list")
				var/list/response = list()
				for_by_tcl(canvas, /obj/item/canvas/lazy_restore)
					response += canvas.id
				for_by_tcl(art_exhibit, /obj/decal/exhibit)
					if (art_exhibit.data?.art)
						response += art_exhibit.exhibit_id
				return json_encode(response)

			if("lazy_canvas_get")
				var/list/response = list()
				for_by_tcl(canvas, /obj/item/canvas/lazy_restore)
					if(canvas.id == plist["id"])
						if(!canvas.initialized)
							canvas.load_from_id(canvas.id)
						response[canvas.id] = icon2base64(canvas.art)
				for_by_tcl(art_exhibit, /obj/decal/exhibit)
					if(art_exhibit.exhibit_id == plist["id"])
						if (!art_exhibit.data?.art)
							break
						response[art_exhibit.exhibit_id] = icon2base64(art_exhibit.data.art)
				return json_encode(response)

			if("ban_added")
				bansHandler.add(
					plist["admin_ckey"],
					plist["server_id"],
					plist["ckey"],
					plist["comp_id"],
					plist["ip"],
					plist["reason"],
					text2num(plist["duration"]) * 10,
					text2num(plist["requires_appeal"]),
					TRUE
				)
				return 1

			if ("mapSwitchDone")
				if (!plist["map"] || !mapSwitcher.locked) return 0

				var/map = plist["map"]
				var/ircmsg[] = new()
				var/msg

				var/attemptedMap = mapSwitcher.next ? mapSwitcher.next : mapSwitcher.current
				if (map == "FAILED")
					msg = "Compilation of [attemptedMap] failed! Falling back to previous setting of [mapSwitcher.nextPrior ? mapSwitcher.nextPrior : mapSwitcher.current]"
				else
					msg = "Compilation of [attemptedMap] succeeded!"

				logTheThing(LOG_ADMIN, null, msg)
				logTheThing(LOG_DIARY, null, msg, "admin")
				message_admins(msg)
				ircmsg["msg"] = msg

				mapSwitcher.unlock(map)
				return ircbot.response(ircmsg)

			if ("auth_callback")
				var/preauth_ckey = plist["preauth_ckey"]
				var/data = plist["data"]

				for (var/client/C in pre_auth_clients)
					if (C.ckey == preauth_ckey)
						if (istype(C.client_auth_provider, /datum/client_auth_provider/goonhub))
							var/datum/client_auth_provider/goonhub/provider = C.client_auth_provider
							provider.on_auth(data)
							return TRUE

				var/msg = "Failed to find pre-auth client for [preauth_ckey] during auth callback"
				logTheThing(LOG_ADMIN, null, msg)
				logTheThing(LOG_DIARY, null, msg, "admin")
				return FALSE
