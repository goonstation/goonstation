/// Convert ISO 8601 to BYOND time format
proc/fromIso8601(iso8601)
	var/list/datetimeParts = splittext(iso8601, "T")
	var/date = datetimeParts[1]
	var/time = splittext(datetimeParts[2], "Z")[1]

	var/list/dateParts = splittext(date, "-")
	var/year = text2num(dateParts[1])
	var/month = text2num(dateParts[2])
	var/day = text2num(dateParts[3])

	if(year < 2000)
		return // invalid date range

	var/list/timeParts = splittext(time, ":")
	var/hour = text2num(timeParts[1])
	var/minute = text2num(timeParts[2])
	var/second = text2num(timeParts[3])

	// Calculate the total number of days for each year
	var/totalDays = 0
	for(var/y = 2000; y < year; y++)
		totalDays += isLeapYear(y) ? 366 : 365

	// Add the number of days for each month
	var/list/monthDays = list(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	if(isLeapYear(year))
		monthDays[2] = 29
	for(var/m = 1; m < month; m++)
		totalDays += monthDays[m]

	// Add the remaining days, hours, minutes, and seconds
	totalDays += day - 1
	return totalDays DAYS + hour HOURS + minute MINUTES + second SECONDS

/// returns true if the year is divisible by 4, except for years that are divisible by 100. However, years that are divisible by 400 are also leap years.
proc/isLeapYear(year)
	return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)

/// Convert BYOND time format to ISO 8601
proc/toIso8601(timeInByondFormat)
	var/timeString = time2text(timeInByondFormat, "YYYY-MM-DD hh:mm:ss")
	var/list/parts = splittext(timeString, " ")
	return parts[1] + "T" + parts[2] + "Z"

/// Add time to a given BYOND time format
proc/addTime(timeInByondFormat, years=0, months=0, days=0, hours=0, minutes=0, seconds=0)
	return timeInByondFormat + (seconds SECONDS + (minutes MINUTES) + (hours HOURS) + (days DAYS) + (months DAYS * 30) + (years DAYS * 365))

/// Subtract time from a given BYOND time format
proc/subtractTime(timeInByondFormat, years=0, months=0, days=0, hours=0, minutes=0, seconds=0)
	return addTime(timeInByondFormat, -years, -months, -days, -hours, -minutes, -seconds)
