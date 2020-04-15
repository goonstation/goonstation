# Expected environment variables:
# PR_NUM: ${{ github.event.number }}
# TOKEN: ${{ secrets.GITHUB_TOKEN }}
# REPO: ${{ github.repository }}
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

def parse_pr_changelog(pr):
    entries = []
    author = None
    changelog_match = re.search(r"##\s*Changelog.*```(.*)```", pr.body, re.S | re.M)
    if changelog_match is None:
        return
    lines = changelog_match.group(1).split('\n')
    for line in lines:
        line = line.strip()
        if not line:
            continue
        major_match = re.match(r"(?:\*|\(\*\))\s*(.*)", line)
        minor_match = re.match(r"(?:\+|\(\+\))\s*(.*)", line)
        author_match = re.match(r"\(u\)\s*(.*?):?$", line)
        is_major = None
        content = None
        if major_match is not None:
            is_major = True
            content = major_match.group(1)
        elif minor_match is not None:
            is_major = False
            content = minor_match.group(1)
        elif author_match is not None:
            author = author_match.group(1)
            entries.append("(u){}".format(author))
        if not content:
            continue
        if not author:
            author = pr.user.name
            entries.append("(u){}".format(author))
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
        repo.update_file(contents.path, message, changelog_text, contents.sha, branch=branch)
        completed = 1
        tries -= 1
    return completed

def main():
    g = Github(os.environ["TOKEN"])
    repo = g.get_repo(os.environ["REPO"])
    pr_num = int(os.environ["PR_NUM"])
    pr = repo.get_pull(pr_num)

    pr_data = parse_pr_changelog(pr)
    date_string = '(t)' + pr.merged_at.strftime("%a %b %d %y").lower()
    if pr_data is None: # no changelog
        return

    status = update_changelog(repo, os.environ["CHANGELOG_PATH"],date_string, pr_data, "Changelog for #{}".format(pr_num))

    if not status:
        sys.exit(1) # scream at people

if __name__ == '__main__':
    main()
