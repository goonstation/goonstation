/datum/datetime
	var/timeInByondFormat

	New(timeInByondFormat)
		. = ..()
		src.timeInByondFormat = timeInByondFormat

/datum/datetime/proc/fromIso8601(iso8601)
	var/list/parts = splittext(iso8601, "-")
	var/year = text2num(parts[1])
	var/month = text2num(parts[2])
	var/day = text2num(parts[3])
	var/hour = text2num(parts[4])
	var/minute = text2num(parts[5])
	var/second = text2num(parts[6])
	timeInByondFormat = text2num(time2text(world.timeofday, "hh:mm:ss")) + second + (minute * 60) + (hour * 3600) + (day * 86400) + (month * 2592000) + (year * 31104000)

/datum/datetime/proc/toIso8601()
	var/year = text2num(time2text(timeInByondFormat, "YYYY"))
	var/month = text2num(time2text(timeInByondFormat, "MM"))
	var/day = text2num(time2text(timeInByondFormat, "DD"))
	var/hour = text2num(time2text(timeInByondFormat, "hh"))
	var/minute = text2num(time2text(timeInByondFormat, "mm"))
	var/second = text2num(time2text(timeInByondFormat, "ss"))
	return "[year]-[month]-[day]T[hour]:[minute]:[second]Z"

/datum/datetime/proc/addTime(years = 0, months = 0, days = 0, hours = 0, minutes = 0, seconds = 0)
	timeInByondFormat += seconds + (minutes * 60) + (hours * 3600) + (days * 86400) + (months * 2592000) + (years * 31104000)

/datum/datetime/proc/subtractTime(years = 0, months = 0, days = 0, hours = 0, minutes = 0, seconds = 0)
	timeInByondFormat -= seconds + (minutes * 60) + (hours * 3600) + (days * 86400) + (months * 2592000) + (years * 31104000)

/datum/datetime/proc/isBefore(datum/datetime/other)
	return timeInByondFormat < other.timeInByondFormat

/datum/datetime/proc/isAfter(datum/datetime/other)
	return timeInByondFormat > other.timeInByondFormat

/datum/datetime/proc/isEqual(datum/datetime/other)
	return timeInByondFormat == other.timeInByondFormat
