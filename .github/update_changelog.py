# Expected environment variables:
# TOKEN: ${{ secrets.GITHUB_TOKEN }}
# REPO: ${{ github.repository }}
# GITHUB_SHA - pushed commit (assigned automatically)
# CHANGELOG_PATH: strings/changelog.txt

import os
import datetime
import sys
import re
import time
import random
import traceback
from collections import OrderedDict
from github import Github

labels_to_emoji = {
	'ass-jam': '🍑',
	'balance': '⚖',
	'bug-major': '🐛',
	'bug-minor': '🐛',
	'bug-trivial': '🐛',
	'bug': '🐛',
	'enhancement': '🆕',
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
		try:
			repo.update_file(contents.path, message, changelog_text, contents.sha, branch=branch)
		except:
			completed = 0
			traceback.print_exc()
			time.sleep(random.random() * 2) # just in case multiple instances are fighting or something
		else:
			completed = 1
		tries -= 1
	return completed

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
	date_string = '(t)' + pr.merged_at.strftime("%a %b %d %y").lower()
	if pr_data is None: # no changelog
		print("No changelog provided.")
		return

	status = update_changelog(repo, os.environ["CHANGELOG_PATH"], date_string, pr_data, "Changelog for #{}".format(pr.number))

	if not status:
		sys.exit(1) # scream at people

if __name__ == '__main__':
	main()
