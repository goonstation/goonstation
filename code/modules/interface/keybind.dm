

/client/proc/get_default_keymap(name)
	if (src.preferences.use_wasd)
		switch (name)
			if ("general")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"Z" = KEY_FORWARD,
							"S" = KEY_BACKWARD,
							"Q" = KEY_LEFT,
							"D" = KEY_RIGHT,
							"B" = KEY_POINT,
							"T" = "say",
							"Y" = "say_radio",
							"G" = "refocus",
							"F" = "fart",
							"R" = "flip",
							"O" = "ooc",
							"M" = "emote",
							"ESCAPE" = "mainfocus",
							"RETURN" = "mainfocus",
							"CTRL+A" = "salute",
							"CTRL+B" = "burp",
							"ALT+C" = "ooc",
							"CTRL+D" = "dance",
							"CTRL+E" = "eyebrow",
							"CTRL+F" = "fart",
							"CTRL+G" = "gasp",
							"CTRL+H" = "raisehand",
							"ALT+L" = "looc",
							"CTRL+L" = "laugh",
							"CTRL+N" = "nod",
							"CTRL+P" = "togglepoint",
							"CTRL+Q" = "wave",
							"CTRL+R" = "flip",
							"CTRL+S" = "scream",
							"ALT+T" = "dsay",
							"CTRL+T" = "asay",
							"ALT+W" = "whisper",
							"CTRL+W" = "wink",
							"CTRL+X" = "flex",
							"CTRL+Y" = "yawn",
							"CTRL+Z" = "snap",
							"F1" = "adminhelp",
							"CTRL+SHIFT+F1" = "options",
							"F2" = "autoscreenshot",
							"SHIFT+F2" = "screenshot",
							"F3" = "mentorhelp",
							"I" = "look_n",
							"K" = "look_s",
							"J" = "look_w",
							"L" = "look_e",
							"P" = "pickup"
						))
				else
					return new /datum/keymap(list(
							"W" = KEY_FORWARD,
							"S" = KEY_BACKWARD,
							"A" = KEY_LEFT,
							"D" = KEY_RIGHT,
							"B" = KEY_POINT,
							"NORTH" = KEY_FORWARD,
							"SOUTH" = KEY_BACKWARD,
							"WEST" = KEY_LEFT,
							"EAST" = KEY_RIGHT,
							"T" = "say",
							"Y" = "say_radio",
							"G" = "refocus",
							"F" = "fart",
							"R" = "flip",
							"O" = "ooc",
							"M" = "emote",
							"ESCAPE" = "mainfocus",
							"RETURN" = "mainfocus",
							"CTRL+A" = "salute",
							"CTRL+B" = "burp",
							"ALT+C" = "ooc",
							"CTRL+D" = "dance",
							"CTRL+E" = "eyebrow",
							"CTRL+F" = "fart",
							"CTRL+G" = "gasp",
							"CTRL+H" = "raisehand",
							"ALT+L" = "looc",
							"CTRL+L" = "laugh",
							"CTRL+N" = "nod",
							"CTRL+P" = "togglepoint",
							"CTRL+Q" = "wave",
							"CTRL+R" = "flip",
							"CTRL+S" = "scream",
							"ALT+T" = "dsay",
							"CTRL+T" = "asay",
							"ALT+W" = "whisper",
							"CTRL+W" = "wink",
							"CTRL+X" = "flex",
							"CTRL+Y" = "yawn",
							"CTRL+Z" = "snap",
							"F1" = "adminhelp",
							"CTRL+SHIFT+F1" = "options",
							"F2" = "autoscreenshot",
							"SHIFT+F2" = "screenshot",
							"F3" = "mentorhelp",
							"I" = "look_n",
							"K" = "look_s",
							"J" = "look_w",
							"L" = "look_e",
							"P" = "pickup"
						))
			if ("human")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"SHIFT" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"B" = KEY_POINT,
							"V" = "equip",
							"E" = "swaphand",
							"C" = "attackself",
							"A" = "drop"
						))
				else if (src.tg_controls)
					return new /datum/keymap(list(
							"SPACE" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"SHIFT" = KEY_EXAMINE,
							"R" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"B" = KEY_POINT,
							"E" = "equip",
							"X" = "swaphand",
							"Z" = "attackself",
							"Q" = "drop"
						))
				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"B" = KEY_POINT,
							"V" = "equip",
							"E" = "swaphand",
							"C" = "attackself",
							"Q" = "drop"
						))
			if ("robot")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"SHIFT" = KEY_BOLT,
							"CTRL" = KEY_OPEN,
							"SPACE" = KEY_SHOCK,
							"ALT" = KEY_EXAMINE,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"B" = KEY_POINT,
							"E" = "swaphand",
							"C" = "attackself",
							"A" = "unequip"
						))
				else if (src.tg_controls)
					return new /datum/keymap(list(
							"CTRL" = KEY_BOLT,
							"SHIFT" = KEY_OPEN,
							"ALT" = KEY_SHOCK,
							"SPACE" = KEY_EXAMINE,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"B" = KEY_POINT,
							"X" = "swaphand",
							"Z" = "attackself",
							"Q" = "unequip"
						))
				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_BOLT,
							"CTRL" = KEY_OPEN,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_SHOCK,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"B" = KEY_POINT,
							"E" = "swaphand",
							"C" = "attackself",
							"Q" = "unequip"
						))
			if ("drone")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"B" = KEY_POINT,
							"C" = "attackself",
							"A" = "unequip"
						))
				else if (src.tg_controls)
					return new /datum/keymap(list(
							"B" = KEY_POINT,
							"Z" = "attackself",
							"Q" = "unequip"
						))
				else
					return new /datum/keymap(list(
							"B" = KEY_POINT,
							"C" = "attackself",
							"Q" = "unequip"
						))
			if ("pod")
				return new /datum/keymap(list(
						"SPACE" = "fire"
					))
			if("colosseum_putt")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"Q" = "stop",
						"E" = "alt_fire",
						))
			if ("artillery")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"Q" = "cycle"
					))
			if ("torpedo")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"E" = "exit",
						"Q" = "exit"
					))
	else
		switch (name)
			if ("general")
				if(src.tg_controls)
					return new /datum/keymap(list(
						"NORTH" = KEY_FORWARD,
						"SOUTH" = KEY_BACKWARD,
						"WEST" = KEY_LEFT,
						"EAST" = KEY_RIGHT,
						"T" = "say",
						"Y" = "say_radio",
						"G" = "refocus",
						"F" = "fart",
						"R" = "flip",
						"ESCAPE" = "mainfocus",
						"RETURN" = "mainfocus",
						"CTRL+A" = "attackself",
						"CTRL+B" = "burp",
						"ALT+C" = "ooc",
						"CTRL+D" = "drop",
						"CTRL+E" = "eyebrow",
						"CTRL+F" = "fart",
						"CTRL+G" = "gasp",
						"CTRL+H" = "raisehand",
						"ALT+L" = "looc",
						"CTRL+L" = "laugh",
						"CTRL+N" = "nod",
						"CTRL+P" = "togglepoint",
						"CTRL+Q" = "wave",
						"CTRL+R" = "flip",
						"CTRL+S" = "swaphand",
						"ALT+T" = "dsay",
						"CTRL+T" = "asay",
						"ALT+W" = "whisper",
						"CTRL+W" = "togglethrow",
						"CTRL+X" = "flex",
						"CTRL+Y" = "yawn",
						"CTRL+Z" = "snap",
						"F1" = "adminhelp",
						"CTRL+SHIFT+F1" = "options",
						"F2" = "autoscreenshot",
						"SHIFT+F2" = "screenshot",
						"F3" = "mentorhelp",
						"I" = "look_n",
						"K" = "look_s",
						"J" = "look_w",
						"L" = "look_e",
						"P" = "pickup",
						"DELETE" = "stop_pull"
					))
				else
					return new /datum/keymap(list(
							"NORTH" = KEY_FORWARD,
							"SOUTH" = KEY_BACKWARD,
							"WEST" = KEY_LEFT,
							"EAST" = KEY_RIGHT,
							"T" = "say",
							"Y" = "say_radio",
							"G" = "refocus",
							"F" = "fart",
							"R" = "flip",
							"ESCAPE" = "mainfocus",
							"RETURN" = "mainfocus",
							"CTRL+A" = "salute",
							"CTRL+B" = "burp",
							"ALT+C" = "ooc",
							"CTRL+D" = "dance",
							"CTRL+E" = "eyebrow",
							"CTRL+F" = "fart",
							"CTRL+G" = "gasp",
							"CTRL+H" = "raisehand",
							"ALT+L" = "looc",
							"CTRL+L" = "laugh",
							"CTRL+N" = "nod",
							"CTRL+P" = "togglepoint",
							"CTRL+Q" = "wave",
							"CTRL+R" = "flip",
							"CTRL+S" = "scream",
							"ALT+T" = "dsay",
							"CTRL+T" = "asay",
							"ALT+W" = "whisper",
							"CTRL+W" = "wink",
							"CTRL+X" = "flex",
							"CTRL+Y" = "yawn",
							"CTRL+Z" = "snap",
							"F1" = "adminhelp",
							"CTRL+SHIFT+F1" = "options",
							"F2" = "autoscreenshot",
							"SHIFT+F2" = "screenshot",
							"F3" = "mentorhelp",
							"I" = "look_n",
							"K" = "look_s",
							"J" = "look_w",
							"L" = "look_e",
							"P" = "pickup"
						))
			if ("human")
				if(src.tg_controls)
					return new /datum/keymap(list(
							"SPACE" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"SHIFT" = KEY_EXAMINE,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"V" = "equip",
							"NORTHWEST" = "drop", /*HOME*/
							"SOUTHWEST" = "togglethrow", /*END*/
							"NORTHEAST" = "swaphand", /*PGUP*/
							"SOUTHEAST" = "attackself" /*PGDN*/
						))


				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"V" = "equip",
							"NORTHEAST" = "swaphand",
							"SOUTHEAST" = "attackself",
							"NORTHWEST" = "drop",
							"DELETE" = "togglethrow"
						))

			if ("robot")
				if(src.tg_controls)
					return new /datum/keymap(list(
						"CTRL" = KEY_BOLT,
						"SHIFT" = KEY_OPEN,
						"ALT" = KEY_SHOCK,
						"SPACE" = KEY_EXAMINE,
						"1" = "module1",
						"2" = "module2",
						"3" = "module3",
						"4" = "module4",
						"B" = KEY_POINT,
						"X" = "swaphand",
						"Z" = "attackself",
						"Q" = "unequip"
					))
				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_BOLT,
							"CTRL" = KEY_OPEN,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_SHOCK,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"NORTHEAST" = "swaphand",
							"SOUTHEAST" = "attackself",
							"NORTHWEST" = "unequip"
					))
			if ("drone")
				return new /datum/keymap(list(
						"SOUTHEAST" = "attackself",
						"NORTHWEST" = "unequip"
					))
			if ("pod")
				return new /datum/keymap(list(
						"SPACE" = "fire",

					))
			if("colosseum_putt")
				return new /datum/keymap(list(
						"SOUTHEAST" = "fire",
						"NORTHWEST" = "stop",
						"NORTHEAST" = "alt_fire",
						))
			if ("artillery")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"Q" = "cycle"
					))
			if ("torpedo")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"E" = "exit",
						"Q" = "exit"
					))