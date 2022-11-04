var
	kText/kText = new

kText
	var
		const
			// padText() sides
			PAD_LEFT					= 1
			PAD_RIGHT					= 2
			PAD_BOTH					= 3 // centers the text

			// ascii values, for convenience.
			ASCII_SPACE					= 32
			ASCII_LINEBREAK				= 10
			ASCII_TAB					= 9

	proc
		/**
		 * Gets the character at the given position in the string.
		 * @param string	The string to be queried.
		 * @param pos		The position of the character to be gotten.
		 * @return the character at the given position in the given string.
		 */
		getCharacter(string, pos=1)
			return ascii2text(text2ascii(string, pos))

		/**
		 * Check if the character at the given position in the string is whitespace.
		 * @param string	The string to be queried.
		 * @param pos		The position to be checked.
		 * @return TRUE if it is whitespace. FALSE otherwise.
		 */
		isWhitespace(string, pos=1)
			var/ascii = text2ascii(string, pos)
			if(	ascii == ASCII_SPACE ||\
				ascii == ASCII_LINEBREAK ||\
				ascii == ASCII_TAB)

				return TRUE

			return FALSE

		/**
		 * Capitalize the first character in a string.
		 * @param string	The string to be capitalized.
		 * @return the capitalized form of the string.
		 */
		capitalize(string)
			if(length(string)==1)
				return uppertext(string)

			return uppertext(ascii2text(text2ascii(string, 1)))+copytext(string, 2)

		/**
		 * Removes preceeding and following whitespace in a string.
		 * @param string	The string to be trimmed.
		 * @return the trimmed string.
		 * IE: trimWhitespace("   this is a string    ]   ") would return "this is a string    ]".
		 */
		trimWhitespace(string)
			var/start=1, end=length(string)

			for(start; start<end; start++)
				if(!isWhitespace(string, start))
					break

			for(end; end>start; end--)
				if(!isWhitespace(string, end))
					break

			return copytext(string, start, end+1)

		/**
		 * Finds the next occurrence of white space in a string, starting at the given position.
		 * @param string	The string to be queried.
		 * @param pos		Where to start searching for whitespace.
		 * @return the position of the next occurrence of whitespace, or null of there is no occurrence.
		 */
		findNextWhitespace(string, pos=1)
			for(var/i=pos; i<=length(string); i++)
				if(isWhitespace(string, i))
					return i

		/**
		 * Finds the xth occurence of a string within another string.
		 * @param string	The string to be queried.
		 * @param sub		The string to search for.
		 * @param which		Which occurrence of the string {sub} to look for.
		 * @return the starting position of the xth (which) occurrence of {sub} within {string}.
		 * 0 if nothing is found.
		 * IE: findWhich("a b a", "a", 2) would return 5 (where the second occurrence of "a" is).
		 * if which is -1, it will find the last occurrence of the substring.
		 */
		findWhich(string, sub, which=1)
			if(which==1)
				return findtext(string, sub)

			var/last = findtext(string, sub)
			if(!last)
				return 0

			// find the LAST occurrence
			if(which == -1)
				var/find = findtext(string, sub, last+length(sub)+1)
				while(find)
					last = find
					find = findtext(string, sub, last+length(sub)+1)

				return last

			// find whichever occurrence
			for(var/i=2 to which)
				var/find = findtext(string, sub, last+length(sub)+1)
				if(!find)
					return 0

				last = find

			return last

		/**
		 * The case-sensitive version of findWhich().
		 * @see kText.findWhich()
		 */
		findWhichCase(string, sub, which=1)
			if(which==1)
				return findtextEx(string, sub)

			var/last = findtextEx(string, sub)
			if(!last)
				return 0

			for(var/i=2 to which)
				var/find = findtextEx(string, sub, last+length(sub)+1)
				if(!find)
					return 0

				last=find

			return last

		/**
		 * Converts a string into a list, using a delimiter to determine where to separate entries.
		 * @param string	The string to be listified.
		 * @param delimiter	The string that will serve as a separator between entries in the list.
		 * @return the list form of the string.
		 * IE: text2list("this is a test", " ") would return list("this", "is", "a", "test").
		 */
		text2list(string, delimiter=" ")
			var/list/listified = new, last=1
			for(var/find=findtext(string, delimiter); find; find=findtext(string, delimiter, find+length(delimiter)))
				listified += copytext(string, last, find)
				last=find+length(delimiter)

			listified += copytext(string, last)

			return listified

		/**
		 * The case-sensitive version of text2list().
		 * @see kText.text2list()
		 */
		text2listCase(string, delimiter=" ")
			var/list/listified = new, last=1
			for(var/find=findtextEx(string, delimiter); find; find=findtextEx(string, delimiter, find+length(delimiter)))
				listified += copytext(string, last, find)
				last=find+length(delimiter)

			listified += copytext(string, last)

			return listified

		/**
		 * Converts a list into a string, placing a delimiter inbetween entries in the list.
		 * @param list		The list to be textified.
		 * @param delimiter	The string to place inbetween list entries.
		 * @return the string form of the list.
		 * IE: list2text(list("this", "is", "a", "test"), " ") would return "this is a test".
		 */
		list2text(list/list, delimiter=" ")
			if(!list || !islist(list) || list.len < 1)
				return null

			var/stringified = "[list[1]]"
			for(var/i=2 to list.len)
				stringified += "[delimiter][list[i]]"

			return stringified

		/**
		 * Replaces all occurrences of one string within another string, with another string.
		 * @param string	The string to be queried.
		 * @param sub		The string to be searched for.
		 * @param replace	The string to be used as a replacement.
		 * @return the given string, with all occurrences of {sub} replaced with {replace}.
		 * IE: replaceText("i love cake", "cake", "pie") would return "i love pie".
		 */
		replaceText(string, sub, replace)
			var/replacified, last=1
			for(var/find=findtext(string, sub); find; find=findtext(string, sub, find+length(sub)))
				replacified += copytext(string, last, find) + replace
				last=find+length(sub)

			replacified += copytext(string, last)

			return replacified

		/**
		 * The case-sensitive version of replaceText().
		 * @see kText.replaceText()
		 */
		replaceTextCase(string, sub, replace)
			var/replacified, last=1
			for(var/find=findtextEx(string, sub); find; find=findtextEx(string, sub, find+length(sub)))
				replacified += copytext(string, last, find) + replace
				last=find+length(sub)

			replacified += copytext(string, last)

			return replacified

		/**
		 * Pads a string so it is the given size.
		 * @param string	The string to be padded.
		 * @param size		The size the string should be padded to.
		 * @param padSide	The side to place the padding on the string.
		 * @param padText	The text to be used to pad the string.
		 * @return the padded form of the given string.
		 * IE: padText("Attributes:", 15, PAD_LEFT) would return "    Attributes:".
		 *
		 * note:	When using PAD_BOTH, the given text will attempt to be centered.
		 *			This function assumes a fixed-width font, which means if the size
		 *			of the padding is uneven, then one side (the right side) will be
		 *			given an extra padding.
		 *
		 *			For example, padText("ABC", 6, PAD_BOTH, "-") would require atleast 3
		 *			padding characters. Since this can't be split down the middle,
		 *			one of the padding characters will be added to the end of the string:
		 *			"-ABC--".
		 */
		padText(string, size=12, padSide=PAD_LEFT, padCharacter=" ")
			var/difference		= size - length(string)
			if(difference < 1)
				return string

			switch(padSide)
				// they both do the same thing, so just switch around the return values.
				if(PAD_RIGHT, PAD_LEFT)
					var/pad
					for(var/i=1 to difference)
						pad += padCharacter

					return (padSide == PAD_RIGHT ? "[string][pad]" : "[pad][string]")

				if(PAD_BOTH)
					var/pad
					for(var/i=1 to round(difference/2))
						pad += padCharacter

					return "[pad][string][pad][difference % 2 ? padCharacter : null]"

		/**
		 * Removes linebreaks from the given string, replacing them with spaces.
		 * @param string	The string to be modified.
		 * @return The string, with linebreaks replaced with spaces.
		 */
		noBreak(string)
			return replaceText(string, "\n", " ")

		/**
		 * Adds linebreaks to the string every X characters.
		 * If the character at the position we want to place the linebreak at isn't whitespace,
		 * it will look for the next whitespace character before placing it.
		 * @param string		The string to be modified.
		 * @param charsPerLine	How many characters should be on each separate line.
		 * @return The modified string, with linebreaks placed every X characters.
		 * IE: autoBreak("I am not a crook.", 5) would return "I am\nnot a\ncrook."
		 *
		 * note:	To keep the newly created lines consistent, this will also remove any
		 *			extra whitespace at the beginning and ends of newly added lines.
		 */
		autoBreak(string, charsPerLine=50)
			var/list/breakified = new

			var/last=1
			while(isWhitespace(string, last))
				last++

			for(var/i=last+charsPerLine; i<length(string); i+=charsPerLine)
				var/safeBreakPos = findNextWhitespace(string, i, last)
				if(!safeBreakPos)
					break

				var/line = copytext(string, last, safeBreakPos)
				if(line)
					breakified += line

				while(isWhitespace(string, safeBreakPos))
					safeBreakPos++

				i = safeBreakPos
				last = i

			breakified += copytext(string, last)

			return list2text(breakified, "\n")

		/**
		 * Check if the given needle's characters all match the string's characters.
		 * For example, the needle "ca" -- since "ca" begins the string "cake", "ca" is a match to it, thus "auto-completes"
		 * to it.
		 * @param string	The string to be matched against.
		 * @param needle	The string we want to know if matches.
		 * @return	if needle matches string, returns string.
		 *			otherwise, null.
		 * IE: autoComplete("hippo", "h") would return "hippo".
		 */
		autoComplete(string, needle)
			if(islist(string))
				for(var/entry in string)
					// to remain consistent, and allow for embedded lists, this is necessary.
					var/result = autoComplete(entry, needle)
					if(result)
						return result

			else if(istext(string))
				if(findtext(string, needle)==1)
					return string

		/**
		 * The case-sensitive version of autoComplete().
		 * @see kText.autoComplete()
		 */
		autoCompleteCase(string, needle)
			if(islist(string))
				for(var/entry in string)
					// to remain consistent, and allow for embedded lists, this is necessary.
					var/result = autoCompleteCase(entry, needle)
					if(result)
						return result

			else if(istext(string))
				if(findtextEx(string, needle)==1)
					return string

		/**
		 * Checks if any of the space-delimited words within {needle} match to the space-delimited words in {string}.
		 *
		 * This matching uses the same method of matching as autoComplete().
		 *
		 * Basically, "c p" matches "cake pie", because "c" and "p" autocomplete to "cake" and "pie", respectively.
		 *
		 * It should also be noted that if one of the keywords in {needle} does not have a match in {string}, the match will fail.
		 *
		 * * {string}	- The set of words to match against.
		 * * {needle} - The set of words to be searched for.
		 *
		 * * return	- if all the keywords in {needle} have a matching keyword in {string}, returns {string}. Otherwise, null.
		 *
		 * matchKeys("giant king monster", "giant monster") would return "giant king monster".
		 *
		 * matchKeys("giant king monster", "giant snail") would return null, because "snail" has no match.
		 */
		matchKeys(string, needle)
			var/list/needleKeywords		= text2list(needle, " ") // get space delimited list of needle keywords

			// for a list of keywords
			if(islist(string))
				for(var/entry in string)
					// to remain consistent, and allow for embedded lists, this is necessary.
					var/result = matchKeys(entry, needle)
					if(result)
						return result

			// for a string of keywords
			else if(istext(string))

				// get space-delimited list of string keywords
				var/list/stringKeywords	= text2list(string, " ")

				// for every keyword in the needle phrase...
				for(var/needleKeyword in needleKeywords)
					var/found = FALSE

					// match it to atleast on keyword in the string phrase
					for(var/stringKeyword in stringKeywords)
						if(findtext(stringKeyword, needleKeyword)==1)
							found = TRUE
							break

					// if none of the string keywords matched a needle keyword, this was a failure
					if(!found)
						return

				// string was a success!
				return string

		/**
		 * The case-sensitive version of matchKeys().
		 * @see kText.matchKeys()
		 */
		matchKeysCase(string, needle)
			var/list/needleKeywords		= text2list(needle, " ") // get space delimited list of match keywords

			// for a list of keywords
			if(islist(string))
				for(var/entry in string)
					// to remain consistent, and allow for embedded lists, this is necessary.
					var/result = matchKeysCase(entry, needle)
					if(result)
						return result

			// for a string of keywords
			else if(istext(string))

				// get space-delimited list of string keywords
				var/list/stringKeywords	= text2list(string, " ")

				// for every keyword in the needle phrase...
				for(var/needleKeyword in needleKeywords)
					var/found = FALSE

					// match it to atleast on keyword in the string phrase
					for(var/stringKeyword in stringKeywords)
						if(findtextEx(stringKeyword, needleKeyword)==1)
							found = TRUE
							break

					// if none of the string keywords matched a needle keyword, this was a failure
					if(!found)
						return

				// string was a success!
				return string

		/**
		 * Simply repeats the given string a certain amount of times.
		 * @param	string	The string to repeat.
		 * @param	count	The amount to be repeated.
		 * @return	The string, repeated [count] times.
		 */
		repeatText(string, count=2)
			for(var/i=1 to count)
				. += string

		/*///////////////////////////////////////////////////////////////////////////
		|* The Deadron Zone.
		|* These functions were added simply to be "feature complete," so I can claim
		|* the library does what Deadron's library does and then some.
		|* In this way, people who *want* these functions AND *want* the functions of
		|* kText, they can just include kText by itself.
		\*///////////////////////////////////////////////////////////////////////////

		/**
		 * Reads the contents of a file and separates it into a list, using the specified delimiter to
		 * separate entries.
		 * @param	file		The file object, or string referring to the file.
		 * @param	delimiter	The delimiter used to separate the text.
		 * @return	Returns the listified version of the file.
		 * null if a bad file was given.
		 */
		file2list(file, delimiter="\n")
			if(!isfile(file) || !fexists(file))
				return

			var/fileText = file2text(file)
			var/list/listified = new, last=1
			for(var/find=findtext(fileText, delimiter); find; find=findtext(fileText, delimiter, find+length(delimiter)))
				listified += copytext(fileText, last, find)
				last=find+length(delimiter)

			listified += copytext(fileText, last)

			return listified

		/**
		 * The case-sensitive version of file2list().
		 * @see kText.file2list()
		 */
		file2listCase(file, delimiter="\n")
			if(!isfile(file) || !fexists(file))
				return

			var/fileText = file2text(file)
			var/list/listified = new, last=1
			for(var/find=findtextEx(fileText, delimiter); find; find=findtextEx(fileText, delimiter, find+length(delimiter)))
				listified += copytext(fileText, last, find)
				last=find+length(delimiter)

			listified += copytext(fileText, last)

			return listified

		/**
		 * Attempts to determine if the string is prefixed with the given prefix.
		 * @param	string	The string to check against.
		 * @param	prefix	The prefix to check for.
		 * @return	1 if the prefix was found. Just think of it as TRUE.
		 * 0 if the prefix was not found.
		 */
		hasPrefix(string, prefix)
			return findtext(string, prefix, 1, length(prefix)+1)

		/**
		 * The case-sensitive version of hasPrefix().
		 * @see kText.hasPrefix()
		 */
		hasPrefixCase(string, prefix)
			return findtextEx(string, prefix, 1, length(prefix)+1)

		/**
		 * Attempts to determine if the string is suffixed with the given suffix.
		 * @param	string	The string to check against.
		 * @param	suffix	The suffix to check for.
		 * @return	The beginning of the suffix in the string (string's length - suffix's length + 1) if it is found.
		 * 0 if the suffix was not found.
		 */
		hasSuffix(string, suffix)
			var/start = length(string)-length(suffix)+1
			if(start<1)
				return 0

			return findtext(string, suffix, start)

		/**
		 * The case-sensitive version of hasSuffix().
		 * @see kText.hasSuffix()
		 */
		hasSuffixCase(string, suffix)
			var/start = length(string)-length(suffix)+1
			if(start<1)
				return 0

			return findtextEx(string, suffix, start)

		/**
		 * Limits the max length of a string.
		 * @param	length	The maximum length a string can be.
		 * @return	If the string is longer than the given string, returns the string after it is cut short.
		 * Otherwise, the entire string.
		 */
		limitText(string, length)
			if(length < 1)
				return null

			if(length(string) > length)
				return copytext(string, 1, length)
