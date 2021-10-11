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
    "action": "do_login",
    "url": URL + "/member.php",
    "quick_login": "1",
    "my_post_key": None,
    "quick_username": os.environ["FORUM_USERNAME"],
    "quick_password": os.environ["FORUM_PASSWORD"],
    "quick_remember": "yes",
    "submit": "Login"
}

LOGOUT = {
    "url": URL + "/member.php",
    "action": "logout",
    "logoutkey": "let's hope this wasn't necessary",
}

s = requests.Session()

def markdown_to_mybb(markdown):
    result = re.sub(r"<!--.*?-->", r"", markdown, flags=re.MULTILINE | re.DOTALL)
    result = re.sub(r"```(.*?)```", r"[code]\1[/code]", result, flags=re.MULTILINE | re.DOTALL)
    result = re.sub(r"##\s*(.*)\r?\n", r"[b]\1[/b]\n", result)
    result = re.sub(r"!\[[^]]*\]\(([^)]*)\)", r"[img]\1[/img]", result)
    return result

def parse_post_key(text):
    return re.search(r'var my_post_key = "([0-9a-f]*)";', text).groups()[0]

def get_post_key():
    response = s.get(URL)
    return parse_post_key(response.text)

def edit_thread(thread_id, subject, contents, icon="-1", edit_reason=""):
    post_key = get_post_key()
    LOGIN['my_post_key'] = post_key

    r = s.post(LOGIN['url'], data=LOGIN)
    if "User CP" not in r.text:
        print("Guest" in r.text)
        return None
    print("Logged in")

    r = s.post(URL + "/showthread.php?tid={}".format(thread_id))
    post_id = re.search(r'id="post_([0-9]*)', r.text).groups()[0]

    POST_DATA = {
        "my_post_key": parse_post_key(r.text),
        "subject": subject,
        "icon": str(icon),
        "message": contents,
        "editreason": edit_reason,
        "submitbutton": "Update Post",
        "action": "do_editpost",
        "numpolloptions": "2",
        "attachmentaid": "",
        "attachmentact": ""
    }

    edit_url = URL + "/editpost.php?pid={}&processed=1".format(post_id)
    thread_url = None
    r = s.post(edit_url, files={k: (None, v) for k, v in POST_DATA.items()})
    thread_url = r.url
    if thread_url == edit_url:
        print("Failed to edit a thread for some reason.")
        print(r.text)
        thread_url = None
    else:
        print("Edited thread {} with status code: {}".format(r.url, r.status_code))

    time.sleep(1)

    s.post(LOGOUT['url'], data=LOGOUT)
    print("Logged out")

    return thread_url

def post_thread(subject, contents, icon="-1"):
    rand_int = randint(0,1000000)
    random_string = str(rand_int)
    n = hashlib.md5()
    n.update(random_string.encode('utf-8'))
    posthash = n.hexdigest()

    post_key = get_post_key()
    LOGIN['my_post_key'] = post_key

    r = s.post(LOGIN['url'], data=LOGIN)
    if "User CP" not in r.text:
        return None
    print("Logged in")

    POST_DATA = {
        "my_post_key": parse_post_key(r.text),
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

def get_thread_id():
    g = Github(os.environ["TOKEN"])
    repo = g.get_repo(os.environ["REPO"])
    pull = repo.get_pull(int(os.environ["PR_NUM"]))
    pull_but_as_issue = pull.as_issue() # what the fuck github
    for comment in pull_but_as_issue.get_comments():
        if comment.body.startswith("Created discussion thread:"):
            return int(comment.body.split("=")[1])
    return None

icon = os.environ["POST_ICON"]
prefix = os.environ["SUBJECT_PREFIX"]
if os.environ["PR_MERGED"] == "true":
    prefix = os.environ["SUBJECT_PREFIX_MERGED"]
    icon = os.environ["POST_ICON_MERGED"]
elif os.environ["PR_STATE"] == "closed":
    prefix = os.environ["SUBJECT_PREFIX_CLOSED"]
    icon = os.environ["POST_ICON_CLOSED"]
subject = prefix + os.environ["PR_TITLE"]
if len(subject) > MAX_SUBJECT_LEN:
    ellipsis = "..."
    subject = subject[:MAX_SUBJECT_LEN - len(ellipsis)] + ellipsis
pr_link = "[url={}]{}[/url]".format(os.environ["PR_URL"], "PULL REQUEST DETAILS")
content = pr_link + "\n\n" + markdown_to_mybb(os.environ["PR_BODY"]) + "\n\n" + pr_link

existing_thread_id = get_thread_id()

if existing_thread_id:
    thread_url = None
    attempts_left = 3
    while not thread_url and attempts_left:
        thread_url = edit_thread(existing_thread_id, subject, content, icon)
        if not thread_url:
            attempts_left -= 1
            time.sleep(1)
    if not thread_url:
        print("All attempts failed. You are on your own, cowboy.")
        sys.exit(1)
else:
    thread_url = None
    attempts_left = 3
    while not thread_url and attempts_left:
        thread_url = post_thread(subject, content, icon)

        if not thread_url:
            attempts_left -= 1
            time.sleep(1)

    if thread_url:
        post_pr_comment("Created discussion thread: {}".format(thread_url))
    else:
        print("All attempts failed. You are on your own, cowboy.")
        post_pr_comment("Failed to create a discussion thread. Try making your own: {}".format(URL + "/newthread.php?fid=" + os.environ["SUBFORUM_ID"]))
        sys.exit(1)
