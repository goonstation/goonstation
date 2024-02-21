var/currency_name = null
/proc/currency_name()
	if (currency_name) return currency_name
	else
		var/name = ""
		if (prob(20)) name += " Space "
		name += pick("Credits", "Dollars", "Bucks", "Francs", "Deutschmarks", "Roubles", "Peso", "Denarii")
		return name
