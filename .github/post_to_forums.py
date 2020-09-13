import requests
import os
import sys
import re
import hashlib
import time
import string
from random import randint
from github import Github

MAX_SUBJECT_LEN = 85 # maximum forum thread title length

URL = os.environ["FORUM_URL"]

LOGIN = {
	"url": URL + "/member.php",
	"action": "do_login",
	"submit": "Login",
	"quick_login": "1",
	"quick_username": os.environ["FORUM_USERNAME"],
	"quick_password": os.environ["FORUM_PASSWORD"]
}

LOGOUT = {
	"url": URL + "/member.php",
	"action": "logout",
	"logoutkey": os.environ["FORUM_LOGOUT_KEY"]
}

s = requests.Session()

def markdown_to_mybb(markdown):
	result = re.sub(r"<!--.*?-->", r"", markdown, flags=re.MULTILINE | re.DOTALL)
	result = re.sub(r"```(.*?)```", r"[code]\1[/code]", result, flags=re.MULTILINE | re.DOTALL)
	result = re.sub(r"##\s*(.*)\r?\n", r"[b]\1[/b]\n", result)
	return result

def post_thread(subject, contents, icon="-1"):
	rand_int = randint(0,1000000)
	random_string = str(rand_int)
	n = hashlib.md5()
	n.update(random_string.encode('utf-8'))
	posthash = n.hexdigest()

	s = requests.Session()

	r = s.post(LOGIN['url'], data=LOGIN)
	if "User CP" not in r.text:
		return None
	print("Logged in")

	POST_DATA = {
		"my_post_key": os.environ["FORUM_POST_KEY"],
		"subject": subject,
		"icon": str(icon),
		"message": contents,
		"submit": "Post Thread",
		"action": "do_newthread",
		"posthash": posthash,
		"tid": "0",
		"numpolloptions": "2",
		"postoptions[subscriptionmethod]": "",
		"attachmentaid": "",
		"attachmentact": "",
		"quoted_ids": ""
	}

	post_url = URL + "/newthread.php?fid={}&processed=1".format(os.environ["SUBFORUM_ID"])
	thread_url = None
	r = s.post(post_url, files={k: (None, v) for k, v in POST_DATA.items()})
	thread_url = r.url
	if thread_url == post_url:
		print("Failed to post a thread for some reason.")
		print(r.text)
		thread_url = None
	else:
		print("Posted thread {} with status code: {}".format(r.url, r.status_code))

	time.sleep(1)

	s.post(LOGOUT['url'], data=LOGOUT)
	print("Logged out")

	return thread_url

def post_pr_comment(body):
	g = Github(os.environ["TOKEN"])
	repo = g.get_repo(os.environ["REPO"])
	pull = repo.get_pull(int(os.environ["PR_NUM"]))
	pull_but_as_issue = pull.as_issue() # what the fuck github
	pull_but_as_issue.create_comment(body)

subject = os.environ["SUBJECT_PREFIX"] + os.environ["PR_TITLE"]
if len(subject) > MAX_SUBJECT_LEN:
	ellipsis = "..."
	subject = subject[:MAX_SUBJECT_LEN - len(ellipsis)] + ellipsis
pr_link = "[url={}]{}[/url]".format(os.environ["PR_URL"], "PULL REQUEST DETAILS")
content = pr_link + "\n\n" + markdown_to_mybb(os.environ["PR_BODY"]) + "\n\n" + pr_link

thread_url = None
attempts_left = 3
while not thread_url and attempts_left:
	thread_url = post_thread(subject, content, os.environ["POST_ICON"])

	if not thread_url:
		attempts_left -= 1
		time.sleep(1)

if thread_url:
	post_pr_comment("Created discussion thread: {}".format(thread_url))
else:
	print("All attempts failed. You are on your own, cowboy.")
	post_pr_comment("Failed to create a discussion thread. Try making your own: {}".format(URL + "/newthread.php?fid=" + os.environ["SUBFORUM_ID"]))
	sys.exit(1)
