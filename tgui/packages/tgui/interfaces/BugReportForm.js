/**
 * @file
 * @copyright 2022 pali (https://github.com/pali6)
 * @license MIT
 */

import { useBackend, useLocalState } from '../backend';
import { Flex, Section, Input } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const Textarea = (props, context) => {
  return (
    <textarea
      rows={4}
      style={{
        "overflow-y": "hidden",
        "width": "100%",
        "background-color": "black",
        "border": "solid 1px #6992c2",
        "color": "white",
      }}
      onInput={(e) => {
        e.target.style.height = "auto";
        e.target.style.height = (e.target.scrollHeight) + "px";
      }}
      id={props.id}
      placeholder={props.placeholder}
    >
      {props.defaultText}
    </textarea>
  );
};

export const InputTitle = (props, context) => {
  return (
    <h2>
      {props.children}
      {props.required && (<span style={{ "color": "red" }}>{" *"}</span>)}
    </h2>
  );
};

export const BugReportForm = (props, context) => {
  const { act, data } = useBackend(context);

  const [isSecret, setIsSecret] = useLocalState(context, 'is_secret', false);
  const [chosenTag, setTag] = useLocalState(context, 'tag', 'MINOR');

  const tags = [
    ["Trivial", "TRIVIAL", "A bug that is extremely trivial, such as a spelling issue."],
    ["Minor", "MINOR", "A bug that does not impact usage of a feature. These are often visual issues."],
    ["Major", "MAJOR", "A bug that significantly impacts the usage of a feature."],
    ["Critical", "CRITICAL", "A bug that significantly impacts the progression of the round."],
  ];

  const submit = () => {
    let data = {};
    data.secret = isSecret;
    data.tags = [chosenTag];
    data.steps = document.getElementById("steps").value;
    data.additional = document.getElementById("additional").value;
    data.title = document.getElementById("title").getElementsByTagName('input')[0].value;
    data.description = document.getElementById("description").getElementsByTagName('input')[0].value;
    data.expected_behavior = document.getElementById("expected_behavior").getElementsByTagName('input')[0].value;
    if (!data.title || !data.description || !data.expected_behavior || !data.steps) {
      alert("Please fill out all required fields!");
      return;
    }
    act("confirm", data);
  };

  return (
    <Window
      title={"Bug Report Form"}
      width={600}
      height={700}>
      <Window.Content>
        <Section fill scrollable>
          <Flex direction="column" height="100%">
            <Flex.Item style={{ "text-align": "center" }}>
              <a
                href="https://github.com/goonstation/goonstation/issues/new?assignees=&labels=&template=bug_report.yml"
                target="_blank" rel="noreferrer"
                style={{
                  "color": "#6992c2",
                }}
              >
                If you have a GitHub account click here instead
              </a>
            </Flex.Item>
            <Flex.Item>
              <InputTitle required>{"Title"}</InputTitle>
              <Input width="100%" id="title" />
            </Flex.Item>
            <Flex.Item my={2}>
              <h2>{"Tags"}</h2>
              {tags.map(tag =>
                (
                  <ButtonCheckbox
                    key={tag[1]}
                    checked={tag[1] === chosenTag}
                    onClick={() => setTag(tag[1])}
                    tooltip={tag[2]}
                    tooltipPosition="bottom">
                    {tag[0]}
                  </ButtonCheckbox>
                )
              )}
            </Flex.Item>
            <Flex.Item my={2}>
              <InputTitle required>{"Description"}</InputTitle>
              {"Give a short description of the bug"}
              <Input width="100%" id="description" />
            </Flex.Item>
            <Flex.Item my={2}>
              <InputTitle required>{"Steps To Reproduce"}</InputTitle>
              {"Give a list of steps to reproduce this issue"}
              <Textarea id="steps" placeholder="1.\n2.\n3." />
            </Flex.Item>
            <Flex.Item my={2}>
              <InputTitle required>{"Expected Behavior"}</InputTitle>
              {"Give a short description of what you expected to happen"}
              <Input width="100%" id="expected_behavior" />
            </Flex.Item>
            <Flex.Item my={2}>
              <h2>{"Additional Information & Screenshots"}</h2>
              {"Add screenshots and any other information here"}
              <Textarea id="additional" />
            </Flex.Item>
            <Flex.Item my={2}>
              <h2>{"Is this bug an exploit or related to secret content?"}</h2>
              <ButtonCheckbox checked={isSecret} onClick={() => { setIsSecret(!isSecret); }}>
                {"Exploit / Secret"}
              </ButtonCheckbox>
            </Flex.Item>
            <Flex.Item my={2}>
              <Flex style={{ "justify-content": "center" }}>
                <Flex.Item mx={1}>
                  <div
                    className="Button Button--color--default"
                    onClick={submit}
                  >
                    {"Submit"}
                  </div>
                </Flex.Item>
                <Flex.Item mx={1}>
                  <div
                    className="Button Button--color--default"
                    onClick={() => act("cancel")}
                  >
                    {"Cancel"}
                  </div>
                </Flex.Item>
              </Flex>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
