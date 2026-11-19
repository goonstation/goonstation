/datum/seeder/banSeeder
	Seed(handle)
		var/list/bans = list(
			list(
				1, 45021, 1001, "local", 1,
				"Griefing and deliberate team sabotage",
				1, toIso8601(TIME -30), toIso8601(TIME + 30), toIso8601(TIME),
				"admin1", "Admin One"
			),
			list(
				2, 45089, 1002, "local", 1,
				"Repeated metagaming",
				0, null, toIso8601(TIME +25), toIso8601(TIME),
				"admin2", "Admin Two"
			),
			list(
				3, 45102, 1001, "local-2", 2,
				"Harassment of other players",
				1, toIso8601(TIME -7), toIso8601(TIME +20), toIso8601(TIME),
				"admin1", "Admin One"
			),
			list(
				4, 45190, 1003, "local", 1,
				"Exploiting a known game bug",
				1, null, toIso8601(TIME + 15), toIso8601(TIME),
				"admin3", "Admin Three"
			),
			list(
				5, 45210, 1002, "local-2", 2,
				"Repeated rule violations",
				0, toIso8601(TIME -14), toIso8601(TIME + 14), toIso8601(TIME),
				"admin2", "Admin Two"
			),
			list(
				6, 45255, 1001, "local", 1,
				"Inappropriate player conduct",
				1, toIso8601(TIME -2), toIso8601(TIME + 10), toIso8601(TIME),
				"admin1", "Admin One"
			),
			list(
				7, 45300, 1003, "local-3", 3,
				"Ban evasion",
				1, null, toIso8601(TIME + 5), toIso8601(TIME),
				"admin3", "Admin Three"
			),
			list(
				8, 45342, 1002, "local", 1,
				"Intentional round disruption",
				0, toIso8601(TIME -1), toIso8601(TIME + 2), toIso8601(TIME),
				"admin2", "Admin Two"
			),
		)
		var/query = {"INSERT INTO bans (
				id, round_id, game_admin_id, server_id, server_group,
				reason, requires_appeal, expires_at, created_at,
				updated_at, admin_ckey, admin_alias
			) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"}
		rustg_sqlite_query_blocking(handle, query, bans)
