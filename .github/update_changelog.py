# Expected environment variables:
# TOKEN: ${{ secrets.GITHUB_TOKEN }}
# REPO: ${{ github.repository }}
# GITHUB_SHA - pushed commit (assigned automatically)
# CHANGELOG_PATH: strings/changelog.txt
# GIT_NAME: Username of the GitHub account to be used as the commiter
# GIT_EMAIL: Email associated with the above username

import os
import datetime
import sys
import re
import time
import pytz
import random
import traceback
from github import Github, InputGitAuthor

labels_to_emoji = {
	'ass-jam': '🍑',
	'balance': '⚖',
	'bug-critical': '🐛',
	'bug-major': '🐛',
	'bug': '🐛',
	'bug-minor': '🐛',
	'bug-trivial': '🐛',
	'enhancement': '🆕',
	'feature': '🆕',
	'removal': '⛔',
	'sprites': '🎨',
	'mapping': '🗺',
	'rework': '🔄'
}

def parse_pr_changelog(pr):
	entries = []
	author = None
	changelog_match = re.search(r"##\s*Changelog.*```(.*)```", pr.body, re.S | re.M)
	if changelog_match is None:
		return
	lines = changelog_match.group(1).split('\n')
	emoji = ''.join(labels_to_emoji.get(label.name, '') for label in pr.labels)
	emoji += "|" + ', '.join(label.name for label in pr.labels if label.name in labels_to_emoji)
	for line in lines:
		line = line.strip()
		if not line:
			continue
		major_match = re.match(r"(?:\*|\(\*\))\s*(.*)", line)
		minor_match = re.match(r"(?:\+|\(\+\))\s*(.*)", line)
		author_match = re.match(r"\(u\)\s*(.*?):?$", line)
		is_major = None
		content = None
		new_author = False
		if major_match is not None:
			is_major = True
			content = major_match.group(1)
		elif minor_match is not None:
			is_major = False
			content = minor_match.group(1)
		elif author_match is not None:
			author = author_match.group(1)
			new_author = True
		if (content and not author) or new_author:
			if not author:
			  author = pr.user.name
			entries.append("(u){}".format(author))
			entries.append("(p){}".format(pr.number))
			if emoji:
				entries.append("(e){}".format(emoji))
		if not content:
			continue
		entry = "({}){}".format('*' if is_major else '+', content)
		entries.append(entry)
	return entries

def update_changelog(repo, file_path, date_string, lines, message, tries=5, branch="master"):
	completed = 0
	while not completed and tries > 0:
		contents = repo.get_contents(file_path, ref=branch)
		changelog_data = contents.decoded_content.decode('utf8').split('\n')
		if not changelog_data[0]: # removing empty first line
			changelog_data = changelog_data[1:]
		if changelog_data[0] == date_string:
			changelog_data = changelog_data[1:]
		changelog_data = [''] + [date_string] + lines + changelog_data
		changelog_text = '\n'.join(changelog_data)
		print("Adding changelog:")
		print('\n'.join([date_string] + lines))

		# Thanks Crossedfall for this bit.
		git_email = os.getenv("GIT_EMAIL")
		git_name = os.getenv("GIT_NAME")

		try:
			repo.update_file(contents.path, message, changelog_text, contents.sha, branch=branch, committer=InputGitAuthor(git_name, git_email))
		except:
			completed = 0
			traceback.print_exc()
			time.sleep(random.random() * 2) # just in case multiple instances are fighting or something
		else:
			completed = 1
		tries -= 1
	return completed

def utc_to_local(utc_dt):

	local_tz = pytz.timezone('US/Eastern')

	local_dt = utc_dt.replace(tzinfo=pytz.utc).astimezone(local_tz)
	return local_tz.normalize(local_dt)

def main():
	g = Github(os.environ["TOKEN"])
	repo = g.get_repo(os.environ["REPO"])

	commit = repo.get_commit(os.environ["GITHUB_SHA"])
	pulls = commit.get_pulls()
	if not pulls.totalCount:
		print("Not a PR.")
		return
	pr = pulls[0]

	pr_data = parse_pr_changelog(pr)
	pr_mergetime_local = utc_to_local(pr.merged_at)

	date_string = '(t)' + pr_mergetime_local.strftime("%a %b %d %y").lower()
	if pr_data is None: # no changelog
		print("No changelog provided.")
		return

	changelog_path = os.environ["ASS_CHANGELOG_PATH"] if any(label.name == 'ass-jam' for label in pr.labels) else os.environ["CHANGELOG_PATH"]
	status = update_changelog(repo, changelog_path, date_string, pr_data, "Changelog for #{} [skip travis]".format(pr.number))

	if not status:
		sys.exit(1) # scream at people

if __name__ == '__main__':
	main()
