/// Convert ISO 8601 to BYOND time format (or epoch time if given argument for that)
proc/fromIso8601(iso8601, epoch = FALSE)
	var/list/datetimeParts = splittext(iso8601, "T")
	var/date = datetimeParts[1]
	var/time = splittext(datetimeParts[2], "Z")[1]

	var/list/dateParts = splittext(date, "-")
	var/year = text2num(dateParts[1])
	var/month = text2num(dateParts[2])
	var/day = text2num(dateParts[3])

	if(year < (epoch ? 1970 : 2000))
		return // invalid date range

	var/list/timeParts = splittext(time, ":")
	var/hour = text2num(timeParts[1])
	var/minute = text2num(timeParts[2])
	var/second = text2num(timeParts[3])

	// Calculate the total number of days for each year
	var/totalDays = 0
	for(var/y = (epoch ? 1970 : 2000); y < year; y++)
		totalDays += isLeapYear(y) ? 366 : 365

	// Add the number of days for each month
	var/list/monthDays = list(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	if(isLeapYear(year))
		monthDays[2] = 29
	for(var/m = 1; m < month; m++)
		totalDays += monthDays[m]

	// Add the remaining days, hours, minutes, and seconds
	totalDays += day - 1
	if(epoch) //yes I could just divide at the end but maybe this saves a little bit of inaccuracy?
		return totalDays DAYS/10 + hour HOURS/10 + minute MINUTES/10 + second SECONDS/10
	else
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

/// Validate ISO 8601 format
proc/validateIso8601(iso8601)
	var/regex/iso8601Pattern = new(@/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)

	if(!iso8601Pattern.Find(iso8601))
		return FALSE // Does not match the pattern

	// Extract components
	var/list/datetimeParts = splittext(iso8601, "T")
	var/date = datetimeParts[1]
	var/time = splittext(datetimeParts[2], "Z")[1]

	var/list/dateParts = splittext(date, "-")
	var/year = text2num(dateParts[1])
	var/month = text2num(dateParts[2])
	var/day = text2num(dateParts[3])

	// Validate year, month, and day
	if(year < 1 || month < 1 || month > 12 || day < 1 || day > 31)
		return FALSE

	var/list/timeParts = splittext(time, ":")
	var/hour = text2num(timeParts[1])
	var/minute = text2num(timeParts[2])
	var/second = text2num(timeParts[3])

	// Validate hour, minute, and second
	if(hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59)
		return FALSE

	// Additional validation for day of month
	var/list/monthDays = list(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	if(isLeapYear(year))
		monthDays[2] = 29
	if(day > monthDays[month])
		return FALSE

	return TRUE

///returns a string describing approximately how much time this represents, useful for when you want to be *vague*
///if this already exists somewhere else I apologise but I couldn't find it
proc/approx_time_text(time)
	var/number = null
	var/string = null
	if (time < 1 MINUTE)
		number = time / (1 SECOND)
		string = "second"
	else if (time < 1 HOUR)
		number = time / (1 MINUTE)
		string = "minute"
	else if (time < 1 DAY)
		number = time / (1 HOUR)
		string = "hour"
	else if (time < 1 WEEK)
		number = time / (1 DAY)
		string = "day"
	else if (time < 1 MONTH)
		number = time / (1 WEEK)
		string = "week"
	else if (time < 1 YEAR)
		number = time / (1 MONTH)
		string = "month"
	else
		number = time / (1 YEAR)
		string = "year"

	number = floor(number)
	return "[number] [string][number > 1 ? "s" : ""]"
