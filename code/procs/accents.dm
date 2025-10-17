proc/random_accent()
	RETURN_TYPE(/datum/bioEffect/speech)
	var/static/list/datum/bioEffect/speech/accents = null
	if(isnull(accents))
		for(var/bio_type in concrete_typesof(/datum/bioEffect/speech, FALSE))
			var/datum/bioEffect/speech/effect = new bio_type()
			if(!effect.acceptable_in_mutini || !effect.occur_in_genepools || !effect.mixingdesk_allowed)
				continue
			LAZYLISTADD(accents, effect)
	. = pick(accents)


/datum/parse_result
	var/string = ""
	var/chars_used = 0

/datum/text_roamer
	var/string = ""
	var/curr_char_pos = 0
	var/curr_char = ""
	var/prev_char = ""
	var/next_char = ""
	var/next_next_char = ""
	var/next_next_next_char = ""

	New(var/str)
		..()
		if(isnull(str))	qdel(src)
		string = str
		curr_char_pos = 1
		curr_char = copytext(string,curr_char_pos,curr_char_pos+1)
		if(length(string) > 1) next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
		if(length(string) > 2) next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
		if(length(string) > 3) next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
	proc

		in_word()
			if(prev_char != "" && prev_char != " " && next_char != "" && next_char != " ") return 1
			else return 0

		end_of_word()
			if(prev_char != "" && prev_char != " " && (next_char == "" || next_char == " ") ) return 1
			else return 0

		alone()
			if((prev_char == "" || prev_char == " ") && (next_char == "" || next_char == " ") ) return 1
			else return 0

		update()
			curr_char = copytext(string,curr_char_pos,curr_char_pos+1)

			if(curr_char_pos + 1 <= length(string))
				next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
			else
				next_char = ""

			if(curr_char_pos + 2 <= length(string))
				next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
			else
				next_next_char = ""

			if(curr_char_pos + 3 <= length(string))
				next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
			else
				next_next_next_char = ""

			if(curr_char_pos - 1  >= 1)
				prev_char = copytext(string,curr_char_pos-1,curr_char_pos)
			else
				prev_char = ""

			return

		next()
			if(curr_char_pos + 1 <= length(string))
				curr_char_pos++

			curr_char = copytext(string,curr_char_pos,curr_char_pos+1)

			if(curr_char_pos + 1 <= length(string))
				next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
			else
				next_char = ""

			if(curr_char_pos + 2 <= length(string))
				next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
			else
				next_next_char = ""

			if(curr_char_pos + 3 <= length(string))
				next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
			else
				next_next_next_char = ""

			if(curr_char_pos - 1  >= 1)
				prev_char = copytext(string,curr_char_pos-1,curr_char_pos)
			else
				prev_char = ""

			return

		prev()

			if(curr_char_pos - 1 >= 1)
				curr_char_pos--

			curr_char = copytext(string,curr_char_pos,curr_char_pos+1)

			if(curr_char_pos + 1 <= length(string))
				next_char = copytext(string,curr_char_pos+1,curr_char_pos+2)
			else
				next_char = ""

			if(curr_char_pos + 2 <= length(string))
				next_next_char = copytext(string,curr_char_pos+2,curr_char_pos+3)
			else
				next_next_char = ""

			if(curr_char_pos + 3 <= length(string))
				next_next_next_char = copytext(string,curr_char_pos+3,curr_char_pos+4)
			else
				next_next_next_char = ""

			if(curr_char_pos - 1  >= 1)
				prev_char = copytext(string,curr_char_pos-1,curr_char_pos)
			else
				prev_char = ""

			return

/proc/explode_string(text)
	if (!istext(text))
		CRASH("YOU HAVE TO PASS TEXT TO THE FUNCTIONS THAT DEAL WITH TEXT, IDIOT.")

	var/regex/our_regex = regex(@"([^&]|&(?:[a-z0-9_-]+|#x?[0-9a-f]+);)", "gi")
	. = list()

	while (our_regex.Find(text) != 0)
		. += our_regex.group[1]


/proc/elvis_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if("t")
			if(R.next_char == "i" && R.next_next_char == "o" && R.next_next_next_char == "n")
				new_string = "shun"
				used = 4
			else if(R.next_char == "h" && R.next_next_char == "e")
				new_string = "tha"
				used = 3
			else if(R.next_char == "h" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "t" + R.next_next_char
				used = 3
		if("T")
			if(R.next_char == "I" && R.next_next_char == "O" && R.next_next_next_char == "N")
				new_string = "SHUN"
				used = 4
			else if(R.next_char == "H" && R.next_next_char == "E")
				new_string = "THA"
				used = 3
			else if(R.next_char == "H" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "T" + R.next_next_char
				used = 3

		if("u")
			if (R.prev_char != " " || R.next_char != " ")
				new_string = "uh"
				used = 2
		if("U")
			if (R.prev_char != " " || R.next_char != " ")
				new_string = "UH"
				used = 2

		if("o")
			if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "aw"
				used = 2
			else if (R.prev_char != " " || R.next_char != " ")
				new_string = "ah"
				used = 1
		if("O")
			if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "AW"
				used = 2
			else if (R.prev_char != " " || R.next_char != " ")
				new_string = "AH"
				used = 1

		if("i")
			if (R.next_char == "r"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "ahr"
				used = 2
			else if(R.next_char == "n" && R.next_next_char == "g")
				new_string = "in'"
				used = 3
		if("I")
			if (R.next_char == "R"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "AHR"
				used = 2
			else if(R.next_char == "N" && R.next_next_char == "G")
				new_string = "IN'"
				used = 3

		if("e")
			if (R.next_char == "n"  && R.next_next_char == " ")
				new_string = "un "
				used = 3
			if (R.next_char == "r"  && R.next_next_char == " ")
				new_string = "ah "
				used = 3
			else if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "yew"
				used = 2
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "ee"
				used = 1
		if("E")
			if (R.next_char == "N"  && R.next_next_char == " ")
				new_string = "UN "
				used = 3
			if (R.next_char == "R"  && R.next_next_char == " ")
				new_string = "AH "
				used = 3
			else if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "YEW"
				used = 2
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "EE"
				used = 1

		if("a")
			if (R.next_char == "u")
				new_string = "ah"
				used = 2
			else if (R.next_char == "n")
				new_string = "ain"
				used =  (R.next_next_char == "d" ? 3 : 2)
		if("A")
			if (R.next_char == "U")
				new_string = "AH"
				used = 2
			else if (R.next_char == "N")
				new_string = "AIN"
				used =  (R.next_next_char == "D" ? 3 : 2)

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/borkborkbork_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if("f")
			if(R.prev_char != " " || R.next_char != " ")
				new_string = "ff"
				used = 1
		if("F")
			if(R.prev_char != " " || R.next_char != " ")
				new_string = "FF"
				used = 1

		if("w")
			new_string = "v"
			used = 1
		if("W")
			new_string = "V"
			used = 1

		if("v")
			new_string = "f"
			used = 1
		if("V")
			new_string = "F"
			used = 1

		if("b")
			if(R.next_char == "o" && R.next_next_char == "r" && R.next_next_next_char == "k")
				new_string = "bork"
				used = 4
		if("B")
			if(R.next_char == "o" && R.next_next_char == "r" && R.next_next_next_char == "k")
				new_string = "Bork"
				used = 4
			else if(R.next_char == "O" && R.next_next_char == "R" && R.next_next_next_char == "K")
				new_string = "BORK"
				used = 4

		if("t")
			if(R.next_char == "i" && R.next_next_char == "o" && R.next_next_next_char == "n")
				new_string = "shun"
				used = 4
			else if(R.next_char == "h" && R.next_next_char == "e")
				new_string = "zee"
				used = 3
			else if(R.next_char == "h" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "t" + R.next_next_char
				used = 3
		if("T")
			if(R.next_char == "I" && R.next_next_char == "O" && R.next_next_next_char == "N")
				new_string = "SHUN"
				used = 4
			else if(R.next_char == "H" && R.next_next_char == "E")
				new_string = "ZEE"
				used = 3
			else if(R.next_char == "H" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "T" + R.next_next_char
				used = 3

		if("u")
			if (R.prev_char != " " || R.next_char != " ")
				new_string = "oo"
				used = 1
		if("U")
			if (R.prev_char != " " || R.next_char != " ")
				new_string = "OO"
				used = 1

		if("o")
			if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "oo"
				used = 2
			else if (R.prev_char != " " || R.next_char != " ")
				new_string = "u"
				used = 1
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "oo"
				used = 1
		if("O")
			if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "OO"
				used = 2
			else if (R.prev_char != " " || R.next_char != " ")
				new_string = "U"
				used = 1
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "OO"
				used = 1

		if("i")
			if (R.next_char == "r"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "ur"
				used = 2
			else if(R.prev_char != " " || R.next_char != " ")
				new_string = "ee"
				used = 1
		if("I")
			if (R.next_char == "R"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "UR"
				used = 2
			else if(R.prev_char != " " || R.next_char != " ")
				new_string = "EE"
				used = 1

		if("e")
			if (R.next_char == "n"  && R.next_next_char == " ")
				new_string = "ee "
				used = 3
			else if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "oo"
				used = 2
			else if ((R.next_char == " " || R.next_char == "," || R.next_char == "." || R.next_char == "-") && R.prev_char != " ")
				new_string = "e-a" + R.next_char
				used = 2
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "i"
				used = 1
		if("E")
			if (R.next_char == "N"  && R.next_next_char == " ")
				new_string = "EE "
				used = 3
			else if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "OO"
				used = 2
			else if ((R.next_char == " " || R.next_char == "," || R.next_char == "." || R.next_char == "-")  && R.prev_char != " ")
				new_string = "E-A" + R.next_char
				used = 2
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "i"
				used = 1

		if("a")
			if (R.next_char == "u")
				new_string = "oo"
				used = 2
			else if ((R.next_char == "n" && R.prev_char == "c") || (R.next_char == "n" && (R.next_next_char == "t" || (R.next_next_char == "'" && R.next_next_next_char == "t"))))
				new_string = "een"
				used = 2
			else if (R.next_char == "n")
				new_string = "un"
				used = 2
			else
				new_string = "e" //{WC} ?
				used = 1
		if("A")
			if (R.next_char == "U")
				new_string = "OO"
				used = 2
			else if ((R.next_char == "N" && R.prev_char == "C") || (R.next_char == "N" && (R.next_next_char == "T" || (R.next_next_char == "'" && R.next_next_next_char == "T"))))
				new_string = "EEN"
				used = 2
			else if (R.next_char == "N")
				new_string = "UN"
				used = 2
			else
				new_string = "E" //{WC} ?
				used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/soviet_parse(var/datum/text_roamer/R)
	var/S = R.curr_char
	var/new_string = ""
	var/used = 1

	switch (S)
		if ("y")
			if (cmptext(R.next_char, "a"))
				new_string = "я"	//Ya
				used = 2
			else if (cmptext(R.next_char,"u"))
				new_string = "ю"
				used = 2
			else if (cmptext(R.next_char,"o"))
				new_string = "ё"
				used = 2
			else if (cmptext(R.next_char, "e"))
				new_string = "е"
				used = 2
			else
				new_string = "ы"
				used = 1
		if ("Y")
			if (cmptext(R.next_char, "a"))
				new_string = "Я"	//Ya
				used = 2
			else if (cmptext(R.next_char,"u"))
				new_string = "Ю"
				used = 2
			else if (cmptext(R.next_char,"o"))
				new_string = "Ё"
				used = 2
			else if (cmptext(R.next_char, "e"))
				new_string = "Е"
				used = 2
			else
				new_string = "Ы"
				used = 1
		if ("s")
			if (cmptext(R.next_char,"h"))
				if (cmptext(R.next_next_char, "c") && cmptext(R.next_next_next_char,"h"))
					new_string = "щ"
					used = 4
				else
					new_string = "ш"
					used = 2
			else
				new_string = "с"
				used = 1

		if ("S")
			if (cmptext(R.next_char,"h"))
				if (cmptext(R.next_next_char, "c") && cmptext(R.next_next_next_char,"h"))
					new_string = "Щ"
					used = 4
				else
					new_string = "Ш"
					used = 2
			else
				new_string = "С"
				used = 1

		if ("k")
			if (cmptext(R.next_char, "h"))
				new_string = "х"	//x
				used = 2
			else
				new_string = "к"	//k
				used = 1

		if ("K")
			if (cmptext(R.next_char, "h"))
				new_string = "Х"	//x
				used = 2
			else
				new_string = "К"	//k
				used = 1

		if ("c")
			if (cmptext(R.next_char, "h"))
				new_string = "ч"
				used = 2
			else if (cmptext(R.next_char, "z"))
				new_string = "ц"	//ts
				used = 2

		if ("C")
			if (cmptext(R.next_char, "h"))
				new_string = "Ч"
				used = 2
			else if (cmptext(R.next_char,"z"))
				new_string = "Ц"	//ts
				used = 2

		if ("t")
			if (cmptext(R.next_char, "s"))
				new_string = "ц"	//ts
				used = 2
			else
				new_string = "т"	//t
				used = 1

		if ("T")
			if (cmptext(R.next_char, "s"))
				new_string = "Ц"	//ts
				used = 2
			else
				new_string = "Т"	//t
				used = 1

		if ("i")
			new_string = "и"
		if ("I")
			new_string = "И"

		if ("z")
			if (cmptext(R.next_char, "h"))
				new_string = "ж"
				used = 2
			else
				new_string = "з"

		if ("Z")
			if (cmptext(R.next_char, "h"))
				new_string = "Ж"
				used = 2
			else
				new_string = "З"

		if ("e")
			if (!R.prev_char || R.prev_char == " ")
				new_string = "э"
			else
				new_string = "е"

		if ("E")
			if (!R.prev_char || R.prev_char == " ")
				new_string = "Э"
			else
				new_string = "Е"

		if ("t")
			new_string = "т"
		if ("T")
			new_string = "Т"

		if ("u")
			new_string = "у"
		if ("U")
			new_string = "У"

		if ("p")
			new_string = "п"
		if ("P")
			new_string = "П"

		if ("n")
			new_string = "н"
		if ("N")
			new_string = "Н"

		if ("m")
			new_string = "м"
		if ("M")
			new_string = "М"

		if ("l")
			new_string = "л"
		if ("L")
			new_string = "Л"

		if ("d")
			new_string = "д"
		if ("D")
			new_string = "Д"

		if ("g")
			new_string = "г"
		if ("G")
			new_string = "Г"

		if ("b")
			new_string = "б"
		if ("B")
			new_string = "Б"

		if ("v","w")
			new_string = "в"
		if ("V","W")
			new_string = "В"

		if ("r")
			new_string = "р"
		if ("R")
			new_string = "Р"

		if ("f")
			new_string = "ф"
		if ("F")
			new_string = "Ф"

		if ("o")
			new_string = "о"
		if ("O")
			new_string = "О"

		if ("j")
			new_string = "й"
		if ("J")
			new_string = "Й"

		if ("a")
			new_string = "а"
		if ("A")
			new_string = "А"

		if ("'")
			new_string = "ъ"

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/tommy_parse(var/datum/text_roamer/R)
	var/S = R.curr_char
	var/new_string = ""
	var/used = 1

	switch(S)
		if("a")
			new_string = "ah"
			used = 1
		if("A")
			new_string = "AH"
			used = 1
		if("e")
			switch(rand(1,2))
				if(1)
					new_string = "ee"
				if(2)
					new_string = "ea"
			used = 1
		if("E")
			switch(rand(1,2))
				if(1)
					new_string = "EE"
				if(2)
					new_string = "EA"
			used = 1
		if("i")
			new_string = "ii"
			used = 1
		if("I")
			new_string = "II"
			used = 1
		if("o")
			if(R.next_char == "u")
				new_string = "oou"
				used = 1
			else
				new_string = "oe"
				used = 1
		if("O")
			if(R.next_char == "U")
				new_string = "OOU"
				used = 1
			else
				new_string = "OE"
				used = 1
		if("u")
			if(R.next_char == " " || R.next_char == "." || R.next_char == "!" || R.next_char == "?" || R.next_char == ",")
				new_string = "ue"
				used = 1
			else if(prob(50))
				new_string = "uu"
				used = 1
		if("U")
			if(R.next_char == " " || R.next_char == "." || R.next_char == "!" || R.next_char == "?" || R.next_char == ",")
				new_string = "UE"
				used = 1
			else if(prob(50))
				new_string = "UU"
				used = 1
		if("h")
			if(R.next_char == "y")
				new_string = "hai"
				used = 2
		if("H")
			if(R.next_char == "Y")
				new_string = "HAI"
				used = 2
		if("r")
			if(R.next_char != "h")
				new_string = "wh"
				used = 2
			else if(R.prev_char != "h")
				new_string = "hw"
				used = 2
			else
				new_string = "w"
				used = 1
		if("R")
			if(R.next_char != "H")
				new_string = "WH"
				used = 2
			else if(R.prev_char != "H")
				new_string = "HW"
				used = 2
			else
				new_string = "W"
				used = 1

	if(!new_string)
		new_string = R.curr_char
		used = 1
	else if(prob(10))
		new_string = uppertext(new_string)

	var/datum/parse_result/P = new
	P.string = new_string
	P.chars_used = used
	return P

/proc/finnish_parse(var/datum/text_roamer/R)
	var/S = R.curr_char
	var/new_string = S
	var/used = 1
	// Case insensitivity
	var/upper = S == uppertext(S)
	S = lowertext(S)
	switch(S)
		// Unexplainable, but great
		if("p")
			new_string = "b"
		if("b")
			new_string = "p"

		/*
		if("u")
			if(isVowel(lowertext(R.next_char)))
				new_string = "a"
			else
				new_string = "o"
		*/
		if("e")
			if(isVowel(lowertext(R.next_char)))
				new_string = "ee"
				used = 2

		if("g")
			if(lowertext(R.prev_char) == "" || lowertext(R.prev_char) == " ")
				new_string = "k"
				used = 1

		if("c")
			// Common to pronounce schedule and scenario with hard C
			if(lowertext(R.prev_char) == "s")
				new_string = "k"
			// Authentic Finnish double consonant
			else if (lowertext(R.next_char) == "k")
				new_string = "kk"
				used = 2

		// Harden soft sh- or th- sounds
		if("s")
			if(lowertext(R.next_char)=="h")
				if(prob(50))
					new_string = "s"
					used = 2
				else
					new_string = "ch"
					used = 2
		if("t")
			if(lowertext(R.next_char)=="h")
				new_string = "t"
				used = 2

		// That legendary harsh R
		if("r")
			if(lowertext(R.next_char) != "r" && R.prev_char != ":") //stop duplicating the research radio shortcut
				new_string = "rr"
				used = 1
		if("i")
			if(lowertext(R.next_char) != "i")
				new_string = "ii"
				used = 1
		if("w")
			new_string = "v"
			used = 1

	var/datum/parse_result/P = new
	P.string = upper ? uppertext(new_string) : new_string
	P.chars_used = used
	return P

/proc/german_parse(var/datum/text_roamer/R)
	var/S = R.curr_char
	var/new_string = S
	var/used = 1
	// Case insensitivity
	var/upper = S == uppertext(S)
	S = lowertext(S)
	switch(S)

		if("w") //germans pronounce W like V, but generally keep the "ow" sound at the end of words and such.
			if (!is_null_or_space(lowertext(R.next_char)))
				new_string = "v"
				used = 1
		if("t") //unlinke the stereotypical zat- it's more like dat, because both the t and the h are pronounced in german. Of course, the Z still does happen quite often.
			if(lowertext(R.next_char) == "h")
				if(prob(50))
					new_string = "d"
					used = 2
				else
					new_string = "z"
					used = 2

		if("q")//qu is pronounced like kv, like in quatsch - kvahtch
			if(lowertext(R.next_char) == "u")
				new_string = "kv"
				used = 2

		if("r")
			if(lowertext(R.prev_char) == " "  || lowertext(R.prev_char) == ""|| isVowel(lowertext(R.next_char)) || !isVowel(lowertext(R.next_char) && lowertext(R.next_char) != "r" && R.prev_char != ":")) //tries to emulate the rolling of the R or the gutteral R
				new_string = "rr"
				used = 1

		if("e")
			if(lowertext(R.next_char) == "" || lowertext(R.next_char) == " " && prob(10))
				new_string = "eh"
			if(lowertext(R.prev_char) == "u")
				new_string = "ee"
				used = 1

		if("s")
			if(isVowel(lowertext(R.next_char)))
				new_string = "z"
				used = 1

	var/datum/parse_result/P = new
	P.string = upper ? uppertext(new_string) : new_string
	P.chars_used = used
	return P

/proc/russify(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for (var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = soviet_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	return modded


/proc/finnishify(var/string)
	if(prob(50))
		string = replacetextEx(string, " a ", "")
		string = replacetextEx(string, " an ", "")
	if(prob(25))
		string = replacetextEx(string, " the ", "")

	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for (var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = finnish_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()
	return modded

/proc/germify(var/string) // pretty much the same thing as scots and tyke, but instead with some common cognates between english and german. The list is significantly smaller, as scots and english are mutually intelligible while english and german are not.

	var/list/phrase = list(
		"excuse me" = "entschuldigung",
		"yes sir" = "jawohl",
		"yes maam" = "jawohl",
		"yes ma'am" = "jawohl",
		"good morning" = "guten morgen",
		"good day" = "guten tag",
		"good afternoon" = "guten tag",
		"good evening" = "guten abend",
		"good night" = "guten nacht",
		"thank you" = "danke",
		"that's too bad" = "schade",
		"thats too bad" = "schade",
		"too bad" = "schade",
		"no problem" = "kein problem"
	) //this list is seperate from the text document, as the current accent system does not support multi word phrases. This could use reworking.

	var/substitute = null
	for(var/i=1,i <= length(phrase),i++)
		substitute = phrase[i]
		string = replacetext(string, substitute, phrase[substitute])

	var/list/tokens = splittext(string, " ")
	var/list/modded_tokens = list()

	var/regex/punct_check = regex("\\W+\\Z", "i")
	for(var/token in tokens)

		var/modified_token = ""
		var/original_word = ""
		var/punct = ""
		var/punct_index = findtext(token, punct_check)
		if(punct_index)
			punct = copytext(token, punct_index)
			original_word = copytext(token, 1, punct_index)
		else
			original_word = token

		var/matching_token = strings("language/german.txt", lowertext(original_word), 1)
		if(matching_token)
			var/pre_parse_modified_token = replacetext(original_word, lowertext(original_word), matching_token)//grab the cognates, replace them, and then feed them into the parser for consistency
			var/datum/text_roamer/T = new/datum/text_roamer(pre_parse_modified_token)
			for(var/i = 0, i < length(pre_parse_modified_token), i=i)
				var/datum/parse_result/P = german_parse(T)
				modified_token += P.string
				i += P.chars_used
				T.curr_char_pos = T.curr_char_pos + P.chars_used
				T.update() //This runs the text through the cognate list first, then runs it through the parser to remain consistent.
		else
			var/datum/text_roamer/T = new/datum/text_roamer(original_word)
			for(var/i = 0, i < length(original_word), i=i)
				var/datum/parse_result/P = german_parse(T)
				modified_token += P.string
				i += P.chars_used
				T.curr_char_pos = T.curr_char_pos + P.chars_used
				T.update()

		modified_token += punct
		modded_tokens += modified_token

	var/modded = jointext(modded_tokens, " ")

	return modded





/proc/tommify(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = tommy_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	if(copytext(string, length(string)) == "!")
		modded = uppertext(modded) + "!!"
	else if(prob(50) && (copytext(string, length(string)) == "?"))
		modded = uppertext(modded) + "?[ prob(50) ? " HUH!?" : null]"
	return modded

/proc/borkborkbork(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = borkborkbork_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	if(prob(5))
		modded += " Bork Bork Bork!"
	if(prob(1))
		modded += " Bork."

	return modded

/proc/elvisfy(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = elvis_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	if(prob(15)) modded += pick(", uh huh.", ", alright?", ", mmhmm.", ", y'all.");

	return modded

/* it's 2020 come on.
/proc/wonkify(var/string)
	return wonk_parse(string)
*/
// REFACTOR - Cirrial
// it would be nice if these were in one fucking place
// say filters

/proc/say_drunk(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)
	for(var/i = 0, i < length(string), i++)
		var/digit_value = text2num(T.curr_char)
		if (digit_value && prob(50))
			modded += "[digit_value + rand(-1, 1)]"
			T.curr_char_pos++
			T.update()
			continue
		switch(T.curr_char)
			if("k")
				if(lowertext(T.prev_char) == "n" || lowertext(T.prev_char) == "c")
					modded += "gh"
				else
					modded += "k"
			if("K")
				if(lowertext(T.prev_char) == "N" || lowertext(T.prev_char) == "C")
					modded += "GH"
				else
					modded += "K"

			if("s")
				modded += "sh"
			if("S")
				modded += "SH"

			if("t")
				if(lowertext(T.next_char) == "h")
					modded += "du"
					T.curr_char_pos++
				else if(lowertext(T.prev_char) == "n")
					modded += "dh"
				else
					modded += "dd"
			if("T")
				if(lowertext(T.next_char) == "H")
					modded += "DU"
					T.curr_char_pos++
				else if(lowertext(T.prev_char) == "N")
					modded += "DH"
				else
					modded += "DD"
			else
				modded += T.curr_char
		T.curr_char_pos++
		T.update()

	return modded

// totally garbled drunk slurring

/proc/say_superdrunk(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i++)
		switch(T.curr_char)
			if("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")
				modded += pick(consonants_lower)
			if("B","C","D","F","G","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z")
				modded += pick(consonants_upper)
			else
				modded += T.curr_char
		T.curr_char_pos++
		T.update()

	return modded

// berserker proc thing

/proc/say_furious(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = say_furious_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	return modded

/proc/say_furious_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if(" ","!","?",".",",",";")
			used = 1
		else
			new_string = pick("A","R","G","H")
			used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

// genetically falling apart!

/proc/say_gurgle(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = say_gurgle_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	return modded

/proc/say_gurgle_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if(" ","!","?",".",",",";")
			used = 1
		else
			new_string = pick("g","u","b","l")
			used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/chavify(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = chav_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	if(prob(15))
		modded += pick(" innit"," like"," mate")

	return modded

/proc/chav_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if("w")
			if(R.next_char == "h" && R.next_next_char == "a")
				new_string = "wo"
				used = 3
		if("W")
			if(R.next_char == "H" && R.next_next_char == "A")
				new_string = "WO"
				used = 3

		if("o")
			if(R.next_char == "u" && R.next_next_char == "g" && R.next_next_next_char == "h")
				new_string = "uf"
				used = 4
			if(R.next_char == "r" && R.next_next_char == "r" && R.next_next_next_char == "y")
				new_string = "oz"
				used = 4
		if("O")
			if(R.next_char == "U" && R.next_next_char == "G" && R.next_next_next_char == "H")
				new_string = "UF"
				used = 4
			if(R.next_char == "R" && R.next_next_char == "R" && R.next_next_next_char == "Y")
				new_string = "OZ"
				used = 4

		if("t")
			if(R.next_char == "i" && R.next_next_char == "o" && R.next_next_next_char == "n")
				new_string = "shun"
				used = 4
			else if(R.next_char == "h" && R.next_next_char == "e")
				new_string = "zee"
				used = 3
			else if(R.next_char == "h" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "t" + R.next_next_char
				used = 3
		if("T")
			if(R.next_char == "I" && R.next_next_char == "O" && R.next_next_next_char == "N")
				new_string = "SHUN"
				used = 4
			else if(R.next_char == "H" && R.next_next_char == "E")
				new_string = "ZEE"
				used = 3
			else if(R.next_char == "H" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "T" + R.next_next_char
				used = 3

		if("u")
			if (R.prev_char != " " || R.next_char != " ")
				new_string = "oo"
				used = 1
		if("U")
			if (R.prev_char != " " || R.next_char != " ")
				new_string = "OO"
				used = 1

		if("o")
			if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "oo"
				used = 2
			else if (R.prev_char != " " || R.next_char != " ")
				new_string = "u"
				used = 1
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "oo"
				used = 1
		if("O")
			if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "OO"
				used = 2
			else if(R.prev_char != " " || R.next_char != " ")
				new_string = "U"
				used = 1
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "OO"
				used = 1

		if("i")
			if (R.next_char == "r"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "ur"
				used = 2
			else if((R.prev_char != " " || R.next_char != " "))
				new_string = "ee"
				used = 1
		if("I")
			if (R.next_char == "R"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "UR"
				used = 2
			else if((R.prev_char != " " || R.next_char != " "))
				new_string = "EE"
				used = 1

		if("e")
			if (R.next_char == "n"  && R.next_next_char == " ")
				new_string = "ee"
				used = 3
			else if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "oo"
				used = 2
			else if ((R.next_char == " " || R.next_char == "," || R.next_char == "." || R.next_char == "-")  && R.prev_char != " ")
				new_string = "e-a" + R.next_char
				used = 2
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "i"
				used = 1
		if("E")
			if (R.next_char == "N"  && R.next_next_char == " ")
				new_string = "EE "
				used = 3
			else if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "OO"
				used = 2
			else if ((R.next_char == " " || R.next_char == "," || R.next_char == "." || R.next_char == "-")  && R.prev_char != " ")
				new_string = "E-A" + R.next_char
				used = 2
			else if(R.next_char == " " && R.prev_char == " ") ///!!!
				new_string = "I"
				used = 1

		if("a")
			if (R.next_char == "u")
				new_string = "oo"
				used = 2
			else if ((R.next_char == "n" && R.prev_char == "c") || (R.next_char == "n" && (R.next_next_char == "t" || (R.next_next_char == "'" && R.next_next_next_char == "t"))))
				new_string = "een"
				used = 2
			else if (R.next_char == "n")
				new_string = "un"
				used = 2
			else
				new_string = "e" //{WC} ?
				used = 1
		if("A")
			if (R.next_char == "U")
				new_string = "OO"
				used = 2
			else if (R.next_char == "N")
				new_string = "UN"
				used = 2
			else
				new_string = "E" //{WC} ?
				used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/smilify(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = smile_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	modded += " :)"

	return modded

/proc/smile_parse(var/datum/text_roamer/R)
	var/used = 0
	var/new_string = ""
	if(R.next_char && lowertext(R.next_char) != " ")
		if(R.next_next_char != " ") new_string = "[R.curr_char] [R.next_char] "
		else new_string = "[R.curr_char] [R.next_char]"
		used = 2

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/voidSpeak(message, mutable_tags = FALSE)
	if (!message)
		return

	var/fontIncreasing = 1
	var/fontSizeMax = 140
	var/fontSizeMin = 70
	var/fontSize = rand(fontSizeMin, fontSizeMax)
	var/processedMessage = ""

	var/list/L = explode_string(message)
	var/randomPos = ""

	for (var/c in L)
		fontSize += rand(5,15) * fontIncreasing
		if (fontSize > fontSizeMax)
			fontIncreasing = -1
		else if (fontSize < fontSizeMin)
			fontIncreasing = 1

		// It turns out that this makes browsers lag really, really bad. Or at least IE.
		// IE is still a pain in the ass in 2019, who would have guessed.
		// (may be fixed if, at some point in E_FUTURE, the whole message is relative-pos instead of each span.)
		if (prob(33))
			randomPos = " position: relative; top: [rand(-3,3)]px; left: [rand(-3,3)]px;"
		else
			randomPos = ""

		if (mutable_tags)
			processedMessage += MAKE_CONTENT_IMMUTABLE("<span style='font-size: [fontSize]%;[randomPos]'>")
			processedMessage += c
			processedMessage += MAKE_CONTENT_IMMUTABLE("</span>")

		else
			processedMessage += "<span style='font-size: [fontSize]%;[randomPos]'>[c]</span>"


	if (mutable_tags)
		return "[MAKE_CONTENT_IMMUTABLE("<em>")][processedMessage][MAKE_CONTENT_IMMUTABLE("</em>")]"
	else
		return "<em>[processedMessage]</em>"

// zalgo text proc, borrowed from eeemo.net

//those go UP
var/list/zalgo_up = list(
	"\u030d", 		"\u030e", 		"\u0304", 		"\u0305",
	"\u033f", 		"\u0311", 		"\u0306", 		"\u0310",
	"\u0352", 		"\u0357", 		"\u0351", 		"\u0307",
	"\u0308", 		"\u030a", 		"\u0342", 		"\u0343",
	"\u0344", 		"\u034a", 		"\u034b", 		"\u034c",
	"\u0303", 		"\u0302", 		"\u030c", 		"\u0350",
	"\u0300", 		"\u0301", 		"\u030b", 		"\u030f",
	"\u0312", 		"\u0313", 		"\u0314", 		"\u033d",
	"\u0309", 		"\u0363", 		"\u0364", 		"\u0365",
	"\u0366", 		"\u0367", 		"\u0368", 		"\u0369",
	"\u036a", 		"\u036b", 		"\u036c", 		"\u036d",
	"\u036e", 		"\u036f", 		"\u033e", 		"\u035b",
	"\u0346", 		"\u031a"
)

//those go DOWN
var/list/zalgo_down = list(
	"\u0316", 		"\u0317", 		"\u0318", 		"\u0319",
	"\u031c", 		"\u031d", 		"\u031e", 		"\u031f",
	"\u0320", 		"\u0324", 		"\u0325", 		"\u0326",
	"\u0329", 		"\u032a", 		"\u032b", 		"\u032c",
	"\u032d", 		"\u032e", 		"\u032f", 		"\u0330",
	"\u0331", 		"\u0332", 		"\u0333", 		"\u0339",
	"\u033a", 		"\u033b", 		"\u033c", 		"\u0345",
	"\u0347", 		"\u0348", 		"\u0349", 		"\u034d",
	"\u034e", 		"\u0353", 		"\u0354", 		"\u0355",
	"\u0356", 		"\u0359", 		"\u035a", 		"\u0323"
)

//those always stay in the middle
var/list/zalgo_mid = list(
	"\u0315", 		"\u031b", 		"\u0340", 		"\u0341",
	"\u0358", 		"\u0321", 		"\u0322", 		"\u0327",
	"\u0328", 		"\u0334", 		"\u0335", 		"\u0336",
	"\u034f", 		"\u035c", 		"\u035d", 		"\u035e",
	"\u035f", 		"\u0360", 		"\u0362", 		"\u0338",
	"\u0337", 		"\u0361", 		"\u0489"
)

/proc/zalgoify(var/message, var/up, var/mid, var/down)
	if(!message)
		return

	var/new_string = ""
	var/list/L = explode_string(message)
	for (var/c in L)
		new_string += c
		for(var/j = 0, j < up, j++)
			new_string += pick(zalgo_up)
		for(var/j = 0, j < mid, j++)
			new_string += pick(zalgo_mid)
		for(var/j = 0, j < down, j++)
			new_string += pick(zalgo_down)

	return new_string



// REFACTOR - Cirrial
/proc/honk(var/string)
	var/modded = ""
	var/list/text_tokens = splittext(string, " ")
	for(var/token in text_tokens)
		modded += "HONK "
	modded += "HONK!"
	if(prob(15))
		modded += " - HOOOOOONNNKKK!!!"
	return modded


// FEATURE - Scots accent by Cirrial, who is english and knows fuck all about what he's doing
// NONE OF THE WORDS PASSED IN WILL HAVE PUNCTUATION AFTER THEM, JUST FOR FUTURE REFERENCE BECAUSE I AM A MORON
// to clarify: this is called for individual words, not for the full string
/proc/scots_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)

		if("e")
			if(lowertext(R.next_char) == "d" && R.next_next_char == "")
				new_string = "it"
				used = 2
		if("E")
			if(lowertext(R.next_char) == "d" && R.next_next_char == "")
				new_string = "IT"
				used = 2

		if("h")
			if(R.prev_char == "")
				new_string = "'"
				used= 1
		if("H")
			if(R.prev_char == "")
				new_string = "'"
				used= 1

		if("i")
			if(R.prev_char == "" && R.next_char == "")
				new_string = "ah"
				used = 1
			else if(R.prev_char == "" && R.next_char == "'")
				new_string = "a"
				used = 1
			else if(lowertext(R.next_char) == "g" && lowertext(R.next_next_char) == "h" && lowertext(R.next_next_next_char) == "t")
				new_string = "icht"
				used = 4
		if("I")
			if(R.prev_char == "" && R.next_char == "")
				new_string = "Ah"
				used = 1
			else if(R.prev_char == "" && R.next_char == "'")
				new_string = "a"
				used = 1
			else if(lowertext(R.next_char) == "g" && lowertext(R.next_next_char) == "h" && lowertext(R.next_next_next_char) == "t")
				new_string = "ICHT"
				used = 4


		if("l")
			if(lowertext(R.next_char) == "d" && R.next_next_char == "")
				new_string = "l"
				used = 3
		if("L")
			if(lowertext(R.next_char) == "d" && R.next_next_char == "")
				new_string = "L"
				used = 3


		if("n")
			if((lowertext(R.next_char) == "d" || lowertext(R.next_char) == "g") && R.next_next_char == "")
				new_string = "n'"
				used = 2
		if("N")
			if((lowertext(R.next_char) == "d" || lowertext(R.next_char) == "g") && R.next_next_char == "")
				new_string = "N'"
				used = 2


		if("o")
			if(R.next_char == "")
				new_string = "oa"
				used = 1

			if(lowertext(R.next_char) == "w" && R.next_next_char == "")
				new_string = "a"
				used = 2

			if(lowertext(R.next_char) == "u")
				new_string = "oo"
				used = 2
		if("O")
			if(R.next_char == "")
				new_string = "OA"
				used = 1

			if(lowertext(R.next_char) == "w" && R.next_next_char == "")
				new_string = "A"
				used = 2

		if("y")
			if(R.next_char == "")
				new_string = "ie"
				used = 1
		if("Y")
			if(R.next_char == "")
				new_string = "IE"
				used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

// english key, scots value
// not extensive, probably room for improvement
// http://www.cs.stir.ac.uk/~kjt/general/scots.html
// https://sco.wikipedia.org/wiki/Wikipedia:RRSSC_Common_wordleet_(Inglis_ti_Scots)
// http://mudcat.org/scots/display_all.cfm

// this list got too big to maintain as a list literal, so now it lives in strings/language/scots.txt

/proc/scotify(var/string) // plays scottish music on demand, harr harr i crack me up (shoot me)scot
	var/list/tokens = splittext(string, " ")
	var/list/modded_tokens = list()

	var/regex/punct_check = regex("\\W+\\Z", "i")
	for(var/token in tokens)
		// check to see if we can just swap out the token
		var/modified_token = ""
		var/original_word = ""
		var/punct = ""
		var/punct_index = findtext(token, punct_check)
		if(punct_index)
			punct = copytext(token, punct_index)
			original_word = copytext(token, 1, punct_index)
		else
			original_word = token

		var/matching_token = strings("language/scots.txt", lowertext(original_word), 1)
		if(matching_token)
			modified_token = replacetext(original_word, lowertext(original_word), matching_token)
		else // otherwise run it through the fallback roamer
			var/datum/text_roamer/T = new/datum/text_roamer(original_word)
			for(var/i = 0, i < length(original_word), i=i)
				var/datum/parse_result/P = scots_parse(T)
				modified_token += P.string
				i += P.chars_used
				T.curr_char_pos = T.curr_char_pos + P.chars_used
				T.update()

		modified_token += punct
		modded_tokens += modified_token

	var/modded = jointext(modded_tokens, " ")

	return modded




/proc/owo_parse(var/datum/text_roamer/R)
    var/new_string = ""
    var/used = 0

    if((R.curr_char == "l" || R.curr_char == "r") && R.next_char != " ")
        new_string = "w"
        used = 1

    if((R.curr_char == "L" || R.curr_char == "R") && R.next_char != " ")
        new_string = "W"
        used = 1

    if(new_string == "")
        new_string = R.curr_char
        used = 1

    var/datum/parse_result/P = new/datum/parse_result
    P.string = new_string
    P.chars_used = used
    return P

/**
* uwutalk
*
* owo-talk version 2.
* Nyo it's sewious!
*/
/proc/uwutalk(var/string)
	var/regex/a1 = new(@"r|l", "g")
	var/regex/a2 = new(@"R|L", "g")
	// These are so that "no", "No", and "NO" become "nyo", "Nyo", and "NYO".
	// Otherwise you end up with "nyoT wIKE THIS"
	var/regex/a3 = new(@"n([aeiou])", "g")
	var/regex/a4 = new(@"N([aeiou])", "g")
	var/regex/a5 = new(@"N([AEIOU])", "g")
	string = a1.Replace(string, "w")
	string = a2.Replace(string, "W")
	string = a3.Replace(string, @"ny$1")
	string = a4.Replace(string, @"Ny$1")
	string = a5.Replace(string, @"NY$1")
	return string

/proc/tabarnak(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = tabarnak_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()
	return modded

/proc/tabarnak_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)

		if("c")
			if(R.next_char == "h")
				new_string = "sh"
				used = 2
		if("C")
			if(R.next_char == "H")
				new_string = "SH"
				used = 2
		if("f")
			if(R.prev_char == " " || R.next_char == " ")
				new_string = "ef"
				used = 1
		if("F")
			if(R.prev_char == " " || R.next_char == " ")
				new_string = "EF"
				used = 1

		if("s")
			if(R.next_char == "t")
				new_string = "ss"
				used = 2
		if("S")
			if(R.next_char == "T")
				new_string = "SS"
				used = 2

		if("t")
			if(R.next_char == "i" && R.next_next_char == "o" && R.next_next_next_char == "n")
				new_string = "sion"
				used = 4
			else if(R.next_char == "h" && R.next_next_char == "e" && R.next_next_next_char == " ")
				new_string = "le"
				used = 3
			else if(R.next_char == "h" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "t" + R.next_next_char
				used = 3
			else if(R.next_char == "s")
				new_string = "ze"
				used = 1
			else if(R.next_char == " ")
				new_string = "tte"
				used = 1
		if("T")
			if(R.next_char == "I" && R.next_next_char == "O" && R.next_next_next_char == "N")
				new_string = "SION"
				used = 4
			else if(R.next_char == "H" && R.next_next_char == "E" && R.next_next_next_char == " ")
				new_string = "LE"
				used = 3
			else if(R.next_char == "H" && (R.next_next_char == " " || R.next_next_char == "," || R.next_next_char == "." || R.next_next_char == "-"))
				new_string = "T" + R.next_next_char
				used = 3
			else if(R.next_char == "S")
				new_string = "ZE"
				used = 1
			else if(R.next_char == " ")
				new_string = "TTE"
				used = 1
		if("o")
			if (R.next_char == "w"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "how"
				used = 2
			else if (R.prev_char == " " && R.next_char != " ")
				new_string = "ho"
				used = 1
			else if(R.next_char == " " && R.prev_char == " ")
				new_string = "crisse"
				used = 1
		if("O")
			if (R.next_char == "W"  && (R.prev_char != " " || R.next_next_char != " "))
				new_string = "HOW"
				used = 2
			else if (R.prev_char == " " && R.next_char != " ")
				new_string = "HO"
				used = 1
			else if(R.next_char == " " && R.prev_char == " ")
				new_string = "ZUT!"
				used = 1

		if("i")
			if(R.prev_char == " ")
				new_string = "hi"
				used = 1
		if("I")
			if(R.prev_char == " ")
				new_string = "HI"
				used = 1

		if("e")
			if (R.next_char != " "  && R.prev_char == " ")
				new_string = "he"
				used = 2
			else if(R.next_char == " " && R.prev_char == " ")
				new_string = "oeuf"
				used = 1
		if("E")
			if (R.next_char != " "  && R.prev_char == " ")
				new_string = "HE"
				used = 2
			else if(R.next_char == " " && R.prev_char == " ")
				new_string = "OEUF"
				used = 1

		if("a")
			if(R.prev_char == " ")
				new_string = "ha"
				used = 1
			else if (R.next_char == "u")
				new_string = "o"
				used = 2
			else if (R.next_char == "n")
				new_string = "hann"
				used = 2

		if("A")
			if(R.prev_char == " ")
				new_string = "HA"
				used = 1
			else if (R.next_char == "U")
				new_string = "O"
				used = 2
			else if (R.next_char == "N")
				new_string = "HANN"
				used = 2

		if("h")
			if (lowertext(R.next_char) == "o" && lowertext(R.next_next_char) == "n" && lowertext(R.next_next_next_char) == "k")
				new_string ="hon hon hon!"
				used = 4
			else if(R.prev_char == " " || R.curr_char_pos == 1)
				new_string = "'"
				used = 1

		if("H")
			if (lowertext(R.next_char) == "o" && lowertext(R.next_next_char) == "n" && lowertext(R.next_next_next_char) == "k")
				new_string ="Hon Hon Hon!"
				used = 4
			else if(R.prev_char == " " || R.curr_char_pos == 1)
				new_string = "'"
				used = 1


	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

/proc/mufflespeech(var/string)
	var/modded = ""
	var/datum/text_roamer/T = new/datum/text_roamer(string)

	for(var/i = 0, i < length(string), i=i)
		var/datum/parse_result/P = mufflespeech_parse(T)
		modded += P.string
		i += P.chars_used
		T.curr_char_pos = T.curr_char_pos + P.chars_used
		T.update()

	return modded


/proc/mufflespeech_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)
		if("q", "t", "k")
			new_string = "p"
			used = 1
		if("w","s","z","c")
			new_string = "h"
			used = 1

		if("e", "y", "i")
			new_string = "f"
			used = 1
		if("u", "o","a","d","g","j","l","x","v","b")
			new_string = "m"
			used = 1

		if("Q", "T", "K")
			new_string = "P"
			used = 1
		if("W","S","Z","C")
			new_string = "H"
			used = 1

		if("E", "Y", "I")
			new_string = "F"
			used = 1
		if("U", "O","A","D","G","J","L","X","V","B")
			new_string = "M"
			used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P



//Yorkshire AKA Tyke accent, wrought by Avack
//An amalgamation of a bunch of sources:
//http://www.yorkshiredialect.com/
//http://www.yorkshire-dialect.org/dictionary.htm & http://www.yorkshire-dialect.org/humour/yorkshire_humour.htm
//https://en.wikipedia.org/wiki/Yorkshire_dialect
/proc/tyke_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)

		if("a")
			//All of these are to represent the monophthongisation of the long E
			if(lowertext(R.next_char) == "y")
				new_string = "ey"
				used = 2
			if(lowertext(R.next_char) == "d" && lowertext(R.next_next_char) == "e")
				new_string = "ed"
				used = 3
			if(lowertext(R.next_char) == "v" && lowertext(R.next_next_char) == "e")
				new_string = "ev"
				used = 3
		if("A")
			if(lowertext(R.next_char) == "y")
				new_string = "EY"
				used = 2
			if(lowertext(R.next_char) == "d" && lowertext(R.next_next_char) == "e")
				new_string = "ED"
				used = 3
			if(lowertext(R.next_char) == "v" && lowertext(R.next_next_char) == "e")
				new_string = "EV"
				used = 3

		if("e")
			//Where, there, and many words with "ea" often diphthongised
			if(lowertext(R.next_char) == "a")
				new_string = "eea"
				used = 2
		if("E")
			if(lowertext(R.next_char) == "a")
				new_string = "EEA"
				used = 2

		if("h","H")
			//H-dropping is common - here, only at the start of the word, and not at the end, to allow people to quote the letter itself
			if(R.prev_char == "" && R.next_char != "")
				new_string = "'"
				used = 1

		if("i")
			//Seems to be common
			if(R.prev_char == "" && R.next_char == "")
				new_string = "ah"
				used = 1
			if(R.prev_char == "" && R.next_char == "'")
				new_string = "a"
				used = 1
			//i_e -> ah_e
			if(lowertext(R.next_next_char) == "e")
				new_string = "ah"
				used = 1
			//Some -ight words in dialect forms of -eet or -eyt
			if(lowertext(R.next_char) == "g" && lowertext(R.next_next_char) == "h" && lowertext(R.next_next_next_char) == "t")
				new_string = "eet"
				used = 4
		if("I")
			if(R.prev_char == "" && R.next_char == "")
				new_string = "Ah"
				used = 1
			if(R.prev_char == "" && R.next_char == "'")
				new_string = "A"
				used = 1
			//"It" with exact capitalisation to "'T", to try and catch it sentence-initially
			if(R.next_char == "t" && R.next_next_char == "")
				new_string = "'T"
				used = 2
			if(lowertext(R.next_next_char) == "e")
				new_string = "AH"
				used = 1
			if(lowertext(R.next_char) == "g" && lowertext(R.next_next_char) == "h" && lowertext(R.next_next_next_char) == "t")
				new_string = "EET"
				used = 4

		if("n")
			//As per many dialects, g dropped in -ng
			if(lowertext(R.next_char) == "g" && R.next_next_char == "")
				new_string = "n'"
				used = 2
		if("N")
			if(lowertext(R.next_char) == "g" && R.next_next_char == "")
				new_string = "N'"
				used = 2


		if("o")
			switch(lowertext(R.next_char))
				if("w")
					//ou and ow -> ah, as per a tendency common to the south half of Yorkshire, not done before "e" here so as not to obfuscate "power", "owe"
					if(lowertext(R.next_next_char) != "e")
						new_string = "ah"
						used = 2
				if("a")
					//This dipthong is common in the West Riding, which I seem to be basing this on??
					if(lowertext(R.next_next_char) == "r")
						new_string = "ooa"
						used = 2
					//Coal, coat, hole, etc. pronounced with "oi" seems to be common as per dictionaries and poetry
					else
						new_string = "oi"
						used = 2
				if("o")
					if(lowertext(R.next_next_char) == "r")
						new_string = "ooa"
						used = 2
					if(lowertext(R.next_next_char) == "t" || lowertext(R.next_next_char) == "l")
						new_string = "ooi"
						used = 2
				if("l")
					//See: oa -> oi
					if(lowertext(R.next_next_char) == "e")
						new_string = "oil"
						used = 3
				if("u")
					//Words which formally had a velar fricative (gh) may change vowels from ough -> ow
					if(lowertext(R.next_next_char) == "g" && lowertext(R.next_next_next_char) == "h")
						new_string = "ow"
						used = 4
					else
						new_string = "ah"
						used = 2
		if("O")
			switch(lowertext(R.next_char))
				if("w")
					if(lowertext(R.next_next_char) != "e")
						new_string = "AH"
						used = 2
				if("a")
					if(lowertext(R.next_next_char) == "r")
						new_string = "OOA"
						used = 2
					else
						new_string = "OI"
						used = 2
				if("o")
					if(lowertext(R.next_next_char) == "r")
						new_string = "OOA"
						used = 2
					if(lowertext(R.next_next_char) == "t" || lowertext(R.next_next_char) == "l")
						new_string = "OOI"
						used = 2
				if("l")
					//See: oa -> oi
					if(lowertext(R.next_next_char) == "e")
						new_string = "OIL"
						used = 3
				if("u")
					if(lowertext(R.next_next_char) == "g" && lowertext(R.next_next_next_char) == "h")
						new_string = "OW"
						used = 4
					else
						new_string = "AH"
						used = 2

		if("t","T")
			//Final stops d and t fricatives f and th often omitted at word end - only done some of the time here so that people can sometimes be almost understood, and also not done after apostrophes so they don't get doubled up
			if(R.prev_char != "" && R.prev_char != "'" && lowertext(R.next_char) == "h" && R.next_next_char == "" && prob(50))
				new_string = "'"
				used = 2
			else if(R.prev_char != "" && R.prev_char != "'" && R.next_char == "" && prob(50))
				new_string = "'"
				used = 1
		if("f","F")
			if(R.prev_char != "" && R.prev_char != "'" && lowertext(R.prev_char) != "f" && R.next_char == "" && prob(50))
				new_string = "'"
				used = 1
		if("d","D")
			if(R.prev_char != "" && R.prev_char != "'" && R.next_char == "" && prob(50))
				new_string = "'"
				used = 1

	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

//Kind thanks to Cirr for making this stuff down here & letting me use it. See by /proc/yorkify for lexicon sources.
/proc/yorkify(var/string)

	var/list/tokens = splittext(string, " ")
	var/list/modded_tokens = list()

	var/regex/punct_check = regex("\\W+\\Z", "i")
	for(var/token in tokens)
		var/modified_token = ""
		var/original_word = ""
		var/punct = ""
		var/punct_index = findtext(token, punct_check)
		if(punct_index)
			punct = copytext(token, punct_index)
			original_word = copytext(token, 1, punct_index)
		else
			original_word = token

		var/matching_token = strings("language/tyke.txt", lowertext(original_word), 1)
		if(matching_token)
			modified_token = replacetext(original_word, lowertext(original_word), matching_token)
		else
			var/datum/text_roamer/T = new/datum/text_roamer(original_word)
			for(var/i = 0, i < length(original_word), i=i)
				var/datum/parse_result/P = tyke_parse(T)
				modified_token += P.string
				i += P.chars_used
				T.curr_char_pos = T.curr_char_pos + P.chars_used
				T.update()

		modified_token += punct
		modded_tokens += modified_token

	var/modded = jointext(modded_tokens, " ")
	if((findtext(modded, (";")) != 1) && (findtext(modded, (":")) != 1) && prob(5)) //Adding the prefixes would break radio speech, so we don't add them if there's a colon or semicolon
		modded = pick("Ee, ","Nah then, ") + modded
	if(prob(2))
		modded += pick(" Bi 'eck!"," Ee ba gum!"," Gi' o'er!")

	return modded

// Ruh roh
/proc/scoob_parse(var/datum/text_roamer/R)
	var/new_string = ""
	var/used = 0

	switch(R.curr_char)

		if("a")
			if(lowertext(R.next_char) != "r")	// AI = rharhy, but harm =/= rghrahrm
				new_string = "rha"
				used = 4
		if("A")
			if(lowertext(R.next_char) != "r")	// AI = RhaRhy, but harm =/= rghrahrm
				new_string = "Rha"
				used = 4

		if("b")
			new_string = "brh"	// brhutt
			used = 3
		if("B")
			new_string = "Brh"	// Brhutt
			used = 3

		if("c")
			if(R.next_char == "e" || R.next_char == "i" || R.next_char == "y" ) // Soft "C"
				new_string = "rh"
				used = 2
			else
				// (R.next_char == "a" || R.next_char == "o" || R.next_char == "l" || R.next_char == "r" || R.next_char == "u" ) // Hard "C" default
				new_string = "rr"
				used = 2
		if("C")
			if(R.next_char == "e" || R.next_char == "i" || R.next_char == "y" ) // Soft "C"
				new_string = "Rh"
				used = 2
			else
				// (R.next_char == "a" || R.next_char == "o" || R.next_char == "l" || R.next_char == "r" || R.next_char == "u" ) // Hard "C" default
				new_string = "Rr"
				used = 2

		if("d")
			if(R.prev_char == "") // First "D" in a word
				new_string = "dhr"	// Ghreh
				used = 3
		if("D")
			if(R.prev_char == "")	// First "D" in a word
				new_string = "Dhr"	// Dhroor
				used = 3

		if("f")
			if(R.prev_char == "") 	// First "F" in a word
				new_string = "rh"	// Rhench "rhies"
				used = 2
		if("F")
			if(R.prev_char == "")	// First "F" in a word
				new_string = "Rh"	// "Rhench" rhies
				used = 2

		if("h")
			if(R.prev_char == "")	// First "h" in a word
				new_string = "rh"	// rhelp mre!
				used = 2
		if("H")
			if(R.prev_char == "")	// First "H" in a word
				new_string = "Rh"	// Rhr
				used = 2


		if("i")
			if(R.prev_char == "" && R.next_char == "")			// i
				new_string = "rhi"
				used = 3
			else if(R.prev_char == "" && R.next_char == "'")	// i'm
				new_string = "rhi"
				used = 3
			else if(R.prev_char == "" && R.next_char != "")		// First "i" in a word, and it ain't "i" or "i'm"
				new_string = "rhy"
				used = 3
		if("I")
			if(R.prev_char == "" && R.next_char == "")			// I
				new_string = "Rhi"
				used = 3
			else if(R.prev_char == "" && R.next_char == "'")	// I'm
				new_string = "Rhi"
				used = 3
			else if(R.prev_char == "" && R.next_char != "")		// First "i" in a word, and it ain't "I" or "I'm"
				new_string = "Rhy"
				used = 3

		if("j")
			new_string = "rrhr"
			used = 4
		if("J")
			new_string = "Rrhr"
			used = 4

		if("k")
			if(R.prev_char == "")	// First "k" in a word
				new_string = "r"	// krakken = rakken
				used = 1
		if("K")
			if(R.prev_char == "")	// First "K" in a word
				new_string = "R"	// Krakken = Rakken
				used = 1

		if("l")
			if(lowertext(R.next_char) == "l")		// "ll" - hello = herghlo
				new_string = "rghl"
				used = 4
			else if(R.prev_char == "")				// first "l" of a word - lightly = wrightly
				new_string = "wr"
				used = 2
			else
				new_string = "rrl"					// any other "l" - heal = hearrl
				used = 3
		if("L")
			if(lowertext(R.next_char) == "l")		// "ll" - hello = herghlo
				new_string = "Rghl"
				used = 4
			else if(R.prev_char == "")				// first "l" of a word - lightly = wrightly
				new_string = "Wr"
				used = 2
			else
				new_string = "Rrl"					// any other "l" - heal = hearrl
				used = 3

		if("m")
			if(R.prev_char == "")		// First "m" of a word
				new_string = "mr"		// mime = mrime
				used = 2
		if("M")
			if(R.prev_char == "")		// First "M" of a word
				new_string = "Mr"		// Mime = Mrime
				used = 2

		if("n")
			if(R.prev_char == "")		// First "n" of a word
				new_string = "rh"		// nine = rhine
				used = 2
		if("N")
			if(R.prev_char == "")		// First "N" of a word
				new_string = "Rh"		// Nine = Rhine
				used = 2

		if("o")
			if(lowertext(R.next_char) == "o")	// "oo"
				new_string = "rooh"				// oops = roohps
				used = 4
			else if(lowertext(R.next_char) == "h")	// "oh"
				new_string = "roh"				// oh = roh
				used = 3
			else								// all other "o"
				new_string = "rho"				// orange = rhorange
				used = 3
		if("O")
			if(lowertext(R.next_char) == "o")	// "Oo"
				new_string = "Rooh"				// Oops = Roohps
				used = 4
			else if(lowertext(R.next_char) == "h")	// "Oh"
				new_string = "Roh"				// Oh = Roh
				used = 3
			else								// all other "O"
				new_string = "Rho"				// Orange = Rhorange
				used = 3

		if("p")
			if(R.prev_char == "")		// First "p" of a word
				new_string = "rh"		// paul = rhaul
				used = 2
			else						// All other "p"
				new_string = "bh"		// tape = tabhe
				used = 2
		if("P")
			if(R.prev_char == "")		// First "p" of a word
				new_string = "Rh"		// Paul = Rhaul
				used = 2
			else						// All other "p"
				new_string = "Bh"		//
				used = 2

		if("q")
			if(R.prev_char == "" && lowertext(R.next_char) == "u")		// First "qu" of a word
				new_string = "rhu"										// quit = rhuit
				used = 3		// could probs leave out the u, looks like it'd work
			else if(R.prev_char != "" && lowertext(R.next_char) == "u")	// Other "qu" of a word
				new_string = "ghr"										// acquire = acghrire
				used = 3
			else														// All other "q"
				new_string = "grh"										// qi = grh
				used = 3												// triple dingus score
		if("Q")
			if(R.prev_char == "" && lowertext(R.next_char) == "u")		// First "Qu" of a word
				new_string = "Rhu"										// Quit = Rhuit
				used = 3		// could probs leave out the u, looks like it'd work
			else if(R.prev_char != "" && lowertext(R.next_char) == "u")	// Other "Qu" of a word
				new_string = "Ghr"										// acquire = acghrire
				used = 3
			else														// All other "q"
				new_string = "Grh"										// Qi = Grh
				used = 3												// triple dingus score

		if("s")
			if(lowertext(R.next_char) == "c")	// sc
				new_string = "rr"				// scope = rrope
				used = 2
			else 								// Other s
				new_string = "r"				// stab = rtab
				used = 1						// ew
		if("S")
			if(lowertext(R.next_char) == "c")	// sc
				new_string = "Rr"				// scope = rrope
				used = 2
			else 								// Other s
				new_string = "R"				// stab = rtab
				used = 1						// ew

		if("t")
			if(lowertext(R.next_char) == "e" && lowertext(R.next_next_char) == "e")	// tee
				new_string = "tree"											// teeth = treeth
				used = 4
			else if(lowertext(R.next_char) == "y" || lowertext(R.next_char) == "i")	// ty, ti
				new_string = "rhy"											// type = rhype
				used = 3
		if("T")
			if(lowertext(R.next_char) == "e" && lowertext(R.next_next_char) == "e")	// tee
				new_string = "Tree"											// teeth = treeth
				used = 4
			else if(lowertext(R.next_char) == "y" || lowertext(R.next_char) == "i")	// ty, ti
				new_string = "Rhy"											// type = rhype
				used = 3

		if("v")
			if(R.prev_char == "")		// First "v" of a word
				new_string = "rh"		// very = rhery
				used = 2
			else						// All other "v"
				new_string = "b"		// groovy = grooby
				used = 1
		if("V")
			if(R.prev_char == "")		// First "V" of a word
				new_string = "Rh"		// Very = Rhery
				used = 2
			else						// All other "V"
				new_string = "B"		// GROOVY = GROOBY
				used = 1

		if("w")
			new_string = "wr"		// w = wr
			used = 2
		if("W")
			new_string = "Wr"		// w = wr
			used = 2

		if("z")
			if(R.prev_char == "")		// First "z" of a word
				new_string = "zhr"		// zebra = zhrebra
				used = 3


	if(new_string == "")
		new_string = R.curr_char
		used = 1

	var/datum/parse_result/P = new/datum/parse_result
	P.string = new_string
	P.chars_used = used
	return P

// this whole thing was originally copied over from the Scots entry
// so its also gonna use a strings file: strings/language/scoob.txt

/proc/scoobify(var/string, var/less_shit)

	var/list/tokens = splittext(string, " ")
	var/list/modded_tokens = list()

	var/regex/punct_check = regex("\\W+\\Z", "i")
	for(var/token in tokens)
		// check to see if we can just swap out the token
		var/modified_token = ""
		var/original_word = ""
		var/punct = ""
		var/punct_index = findtext(token, punct_check)
		if(punct_index)
			punct = copytext(token, punct_index)
			original_word = copytext(token, 1, punct_index)
		else
			original_word = token

		var/matching_token = strings("language/scoob.txt", lowertext(original_word), 1)
		if(matching_token)
			modified_token = replacetext(original_word, lowertext(original_word), matching_token)
		else // otherwise run it through the fallback roamer
			var/datum/text_roamer/T = new/datum/text_roamer(original_word)
			for(var/i = 0, i < length(original_word), i=i)
				var/datum/parse_result/P = scoob_parse(T)
				if(less_shit && prob(50))
					modified_token = T.string
				else
					modified_token += P.string
				i += P.chars_used
				T.curr_char_pos = T.curr_char_pos + P.chars_used
				T.update()

		modified_token += punct
		modded_tokens += modified_token

	var/modded = jointext(modded_tokens, " ")
	if(prob(1))
		modded += pick(" rhaggy!"," rir bruddy."," rhoinks!"," rharoo!")

	return modded

/proc/thrall_parse(var/string)
	var/list/end_punctuation = list("!", "?", ".")
	var/pos = length(string)
	while (pos > 0 && (string[pos] in end_punctuation))
		string = copytext(string, 1, pos--)
	return string + "..."

/proc/pirateify(var/string)
	var/list/tokens = splittext(string, " ")
	var/list/modded_tokens = list()

	var/regex/punct_check = regex("\\W+\\Z", "i")
	for(var/token in tokens)
		var/modified_token = ""
		var/original_word = ""
		var/punct = ""
		var/punct_index = findtext(token, punct_check)
		if(punct_index)
			punct = copytext(token, punct_index)
			original_word = copytext(token, 1, punct_index)
		else
			original_word = token

		var/matching_token = strings("language/pirate.txt", lowertext(original_word), 1)
		if(matching_token)
			modified_token = replacetext(original_word, lowertext(original_word), matching_token)
			modified_token += punct
		else
			modified_token = token

		modded_tokens += modified_token
	var/modded = jointext(modded_tokens, " ")
	if(prob(33))
		modded += pick(" Arrr!"," Arr!", " Yarrrrr!")
	return modded


proc/accent_scramble(string)
	var/list/tokens = splittext(string, regex("\\b", "i"))
	var/regex/word_check = regex("^\\w+$", "i")
	var/list/modded_tokens = list()
	for(var/token in tokens)
		if (length(token) <= 2 || !word_check.Find(token))
			modded_tokens += token
		else
			var/list/letters = list()
			for(var/i = 1, i <= length(token), i++)
				letters += copytext(token, i, i + 1)
			shuffle_list_interval(letters, 2, length(letters) - 1)
			modded_tokens += jointext(letters, "")
	return jointext(modded_tokens, "")


proc/accent_shuffle_words(string)
	var/list/tokens = splittext(string, regex("\\b", "i"))
	var/regex/word_check = regex("^\\w+$", "i")
	var/list/just_words = list()
	var/sentence_ended = TRUE
	for(var/token in tokens)
		if (length(token) > 2 && word_check.Find(token))
			if (sentence_ended)
				token = lowertext(token)
			just_words += token
			sentence_ended = FALSE
		else
			var/last_char = copytext(token, length(token), 0)
			if (last_char in list(".", "!", "?"))
				sentence_ended = TRUE
			else
				sentence_ended = FALSE
	shuffle_list(just_words)
	sentence_ended = TRUE
	var/i = 1
	var/list/modded_tokens = list()
	for(var/token in tokens)
		if (length(token) > 2 && word_check.Find(token))
			var/word_to_add = just_words[i++]
			if (sentence_ended)
				word_to_add = capitalize(word_to_add)
			modded_tokens += word_to_add
			sentence_ended = FALSE
		else
			modded_tokens += token
			var/last_char = copytext(token, length(token), 0)
			if (last_char in list(".", "!", "?"))
				sentence_ended = TRUE
			else
				sentence_ended = FALSE
	return jointext(modded_tokens, "")


proc/accent_mocking(string)
	var/list/letters = list()
	var/letter_count = 0
	for(var/i = 1, i <= length(string), i++)
		var/letter = lowertext(copytext(string, i, i + 1))
		var/letter_ascii = text2ascii(letter)
		if (letter_ascii >= text2ascii("a") && letter_ascii <= text2ascii("z") && (letter_count++) % 2)
			letter = capitalize(letter)
		letters += letter
	return jointext(letters, "")

proc/accent_piglatin(string)
	var/list/tokens = splittext(string, regex(@"\b", "i"))
	var/list/modded_tokens = list()
	var/regex/consclust = regex(@"(^[bcdfghjklmnpqrstvwxys]+)?(\l+)", "i")
	for (var/token in tokens)
		if(length(token) > 1)
			token = consclust.Replace(token, GLOBAL_PROC_REF(piglatin_replace))
		modded_tokens += token
	return jointext(modded_tokens, "")

proc/piglatin_replace(match, one, two)
	if(!one && findtext(two, regex(@"[aeiou]", "i"), length(two)))
		return "[two]yay"
	else
		return "[two][one]ay"

proc/accent_hacker(string, leet_chance=100)
	var/static/list/leetspeak_suffix_translation = list(
		"and" = "&",
		"anned" = "&",
		"ant" = "&",
		"or" = "xor",
		"er" = "xor",
		"ed" = "d",
	)

	var/list/tokens = splittext(string, regex("\\b", "i"))
	var/list/modded_tokens = list()
	for (var/token in tokens)
		var/processed = FALSE
		var/maybe_replacement = strings("language/hacker.txt", lowertext(token), 1)
		if (maybe_replacement)
			token = replacetext(token, lowertext(token), maybe_replacement)
			processed = TRUE
		if (!processed)
			for (var/suffix in leetspeak_suffix_translation)
				if (endswith(token, suffix))
					token = copytext(token, 1, length(token) + 1 - length(suffix)) + leetspeak_suffix_translation[suffix]
				if (endswith(token, uppertext(suffix)))
					token = copytext(token, 1, length(token) + 1 - length(suffix)) + uppertext(leetspeak_suffix_translation[suffix])
		token = leetspeakify(token, processed ? leet_chance / 2 : leet_chance)
		modded_tokens += token

	return jointext(modded_tokens, "")

proc/leetspeakify(string, chance=100)
	var/static/list/leetspeak_translation = list(
		"a" = "4",
		"b" = "8",
		"e" = "3",
		"g" = "6",
		"i" = "1",
		"o" = "0",
		"s" = "5",
		"t" = "7",
		"z" = "2",
	)
	var/list/letters = list()
	for(var/i = 1, i <= length(string), i++)
		var/letter = copytext(string, i, i + 1)
		if ((lowertext(letter) in leetspeak_translation) && prob(chance))
			letter = leetspeak_translation[lowertext(letter)]
		letters += letter
	return jointext(letters, "")

/proc/bingus_parse(var/string)
	var/bingus_list = list(
		@{"\bbingus\b"} = "bingus my beloved",
		@{"\bantag\b"} = "floppa",
		@{"\bantagonist\b"} = "big floppa",
		@{"\bI love [a-zA-Z]+"} = "I love bingus"
	)
	for (var/pattern in bingus_list)
		string = replacetext(string, regex(pattern, "i"), bingus_list[pattern])
	return string

proc/frogify(var/string)

	if(prob(15))
		string += pick(" ribbit", " croak", " brp", " weh", " burup")

	return string
