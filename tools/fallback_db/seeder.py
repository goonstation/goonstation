
#!/usr/bin/env python3

import argparse
from pathlib import Path
import sqlite3
from datetime import datetime, timedelta, timezone

DB_FILE = "../../fallback_db_local.sqlite"

SCHEMA_FILE = "fallback_db.schema"


def timestamp(days_ago=0):
	return (
		datetime.now(timezone.utc) - timedelta(days=days_ago)
	).isoformat(timespec="seconds")


def seed(conn):
	now = timestamp()

	# -------------------------------------------------
	# BANS
	# -------------------------------------------------

	bans = [
		(
			1, 45021, 1001, "local-1", 1,
			"Griefing and deliberate team sabotage",
			1, timestamp(-30), timestamp(30), now,
			"admin1", "Admin One"
		),
		(
			2, 45089, 1002, "local-1", 1,
			"Repeated metagaming",
			0, None, timestamp(25), now,
			"admin2", "Admin Two"
		),
		(
			3, 45102, 1001, "local-2", 2,
			"Harassment of other players",
			1, timestamp(-7), timestamp(20), now,
			"admin1", "Admin One"
		),
		(
			4, 45190, 1003, "local-1", 1,
			"Exploiting a known game bug",
			1, None, timestamp(15), now,
			"admin3", "Admin Three"
		),
		(
			5, 45210, 1002, "local-2", 2,
			"Repeated rule violations",
			0, timestamp(-14), timestamp(14), now,
			"admin2", "Admin Two"
		),
		(
			6, 45255, 1001, "local-1", 1,
			"Inappropriate player conduct",
			1, timestamp(-2), timestamp(10), now,
			"admin1", "Admin One"
		),
		(
			7, 45300, 1003, "local-3", 3,
			"Ban evasion",
			1, None, timestamp(5), now,
			"admin3", "Admin Three"
		),
		(
			8, 45342, 1002, "local-1", 1,
			"Intentional round disruption",
			0, timestamp(-1), timestamp(2), now,
			"admin2", "Admin Two"
		),
	]

	conn.executemany("""
		INSERT INTO bans (
			id, round_id, game_admin_id, server_id, server_group,
			reason, requires_appeal, expires_at, created_at,
			updated_at, admin_ckey, admin_alias
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	""", bans)

	# -------------------------------------------------
	# BAN DETAILS
	# -------------------------------------------------

	details = [
		(1, 1, "playerone", "COMP-A001", "192.0.2.10", 101, timestamp(30), now, "playerone"),
		(2, 1, "playerone_alt", "COMP-A001", "192.0.2.10", 101, timestamp(30), now, "playerone"),
		(3, 2, "playertwo", "COMP-B002", "192.0.2.20", 102, timestamp(25), now, "playertwo"),
		(4, 3, "playerthree", "COMP-C003", "192.0.2.30", 103, timestamp(20), now, "playerthree"),
		(5, 4, "playerfour", "COMP-D004", "192.0.2.40", 104, timestamp(15), now, "playerfour"),
		(6, 5, "playerfive", "COMP-E005", "192.0.2.50", 105, timestamp(14), now, "playerfive"),
		(7, 6, "playersix", "COMP-F006", "192.0.2.60", 106, timestamp(10), now, "playersix"),
		(8, 7, "playerseven", "COMP-G007", "192.0.2.70", 107, timestamp(5), now, "playerseven"),
		(9, 8, "playereight", "COMP-H008", "192.0.2.80", 108, timestamp(2), now, "playereight"),
	]

	conn.executemany("""
		INSERT INTO ban_details (
			id, ban_id, ckey, comp_id, ip, player_id,
			created_at, updated_at, player_ckey
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
	""", details)

	# -------------------------------------------------
	#  mentos
	# -------------------------------------------------

	mentors = [
		(1, 101, timestamp(60), now, "playerone"),
		(2, 103, timestamp(45), now, "playerthree"),
		(3, 109, timestamp(30), now, "playernine"),
		(4, 110, timestamp(20), now, "playerten"),
	]

	conn.executemany("""
		INSERT INTO player_mentors (
			id, player_id, created_at, updated_at, player_ckey
		) VALUES (?, ?, ?, ?, ?)
	""", mentors)

	# -------------------------------------------------
	# hosses
	# -------------------------------------------------

	hos = [
		(1, 102, timestamp(60), now, "playertwo"),
		(2, 105, timestamp(45), now, "playerfive"),
		(3, 111, timestamp(30), now, "playereleven"),
	]

	conn.executemany("""
		INSERT INTO player_hos (
			id, player_id, created_at, updated_at, player_ckey
		) VALUES (?, ?, ?, ?, ?)
	""", hos)

	# -------------------------------------------------
	# EXPORT METADATA
	# -------------------------------------------------

	conn.execute("""
		INSERT INTO export_metadata (
			schema_version, server_id, server_group_id, snapshot_at
		) VALUES (?, ?, ?, ?)
	""", (1, "local-1", 1, now))


def main():
	parser = argparse.ArgumentParser(description="SQLite database seeder")
	parser.add_argument(
		"--reset",
		action="store_true",
		help="Delete existing seeded data before inserting fresh data"
	)
	args = parser.parse_args()

	conn = sqlite3.connect(DB_FILE)
	conn.execute("PRAGMA foreign_keys = ON")

	try:
		with conn:
			schema = Path(SCHEMA_FILE).read_text(encoding="utf-8")
			conn.executescript(schema)

			if args.reset:
				conn.execute("DELETE FROM ban_details")
				conn.execute("DELETE FROM bans")
				conn.execute("DELETE FROM player_mentors")
				conn.execute("DELETE FROM player_hos")
				conn.execute("DELETE FROM export_metadata")

			elif conn.execute(
				"SELECT COUNT(*) FROM export_metadata"
			).fetchone()[0] > 0:
				print("Database already seeded. Use --reset to reseed.")
				return

			seed(conn)

		print(f"Successfully seeded {DB_FILE}")

	except sqlite3.Error as e:
		print(f"Seeding failed: {e}")
		raise

	finally:
		conn.close()


if __name__ == "__main__":
	main()
