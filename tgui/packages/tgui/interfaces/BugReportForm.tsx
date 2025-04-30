/**
 * @file
 * @copyright 2022
 * @author pali (https://github.com/pali6)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { ChangeEventHandler, createRef, useCallback, useState } from 'react';
import { Button, Flex, Input, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Tag = [string, string, string];

const tags: Tag[] = [
  [
    'Trivial',
    'TRIVIAL',
    'A bug that is extremely trivial, such as a spelling issue.',
  ],
  [
    'Minor',
    'MINOR',
    'A bug that does not impact usage of a feature. These are often visual issues.',
  ],
  [
    'Major',
    'MAJOR',
    'A bug that significantly impacts the usage of a feature.',
  ],
  [
    'Critical',
    'CRITICAL',
    'A bug that significantly impacts the progression of the round.',
  ],
];

interface BugReportFormTextAreaProps {
  onChange: (value: string) => void;
  placeholder?: string;
  value?: string;
}

export const BugReportFormTextArea = (props: BugReportFormTextAreaProps) => {
  const { onChange, placeholder, value } = props;
  const handleChange = useCallback<ChangeEventHandler<HTMLTextAreaElement>>(
    (e) => onChange(e.target.value),
    [onChange],
  );
  const ref = createRef<HTMLTextAreaElement>();
  return (
    <textarea
      rows={4}
      style={{
        overflowY: 'hidden',
        width: '100%',
        backgroundColor: 'black',
        border: 'solid 1px #6992c2',
        color: 'white',
      }}
      onInput={() => {
        if (!ref.current) {
          return;
        }
        ref.current.style.height = 'auto';
        ref.current.style.height = ref.current.scrollHeight + 'px';
      }}
      onChange={handleChange}
      placeholder={placeholder}
      value={value || ''}
      ref={ref}
    />
  );
};

export const InputTitle = (props) => {
  return (
    <h2>
      {props.children}
      {props.required && <span style={{ color: 'red' }}>{' *'}</span>}
    </h2>
  );
};

interface FormState {
  additional: string;
  description: string;
  expectedBehavior: string;
  steps: string;
  title: string;
}

const initialFormState: FormState = {
  additional: '',
  description: '',
  expectedBehavior: '',
  steps: '',
  title: '',
};

export const BugReportForm = () => {
  const { act } = useBackend();

  const [isSecret, setIsSecret] = useState(false);
  const [chosenTag, setTag] = useState('MINOR');
  const [formState, setFormState] = useState(initialFormState);

  const handleSubmit = useCallback(() => {
    const submitData = {
      secret: isSecret,
      tags: [chosenTag],
      steps: formState.steps,
      additional: formState.additional,
      title: formState.title,
      description: formState.description,
      expected_behavior: formState.expectedBehavior,
    };
    if (
      !submitData.title ||
      !submitData.description ||
      !submitData.expected_behavior ||
      !submitData.steps
    ) {
      alert('Please fill out all required fields!');
      return;
    }
    act('confirm', submitData);
  }, [act, isSecret, chosenTag, formState]);
  const handleCancel = useCallback(() => act('cancel'), [act]);
  // TODO: reduce copy-paste
  const handleTitleChange = useCallback(
    (_e: unknown, value: string) =>
      setFormState((prevState) => ({ ...prevState, title: value })),
    [],
  );
  const handleDescriptionChange = useCallback(
    (_e: unknown, value: string) =>
      setFormState((prevState) => ({ ...prevState, description: value })),
    [],
  );
  const handleStepsChange = useCallback(
    (value: string) =>
      setFormState((prevState) => ({ ...prevState, steps: value })),
    [],
  );
  const handleExpectedBehaviorChange = useCallback(
    (_e: unknown, value: string) =>
      setFormState((prevState) => ({ ...prevState, expectedBehavior: value })),
    [],
  );
  const handleAdditionalChange = useCallback(
    (value: string) =>
      setFormState((prevState) => ({ ...prevState, additional: value })),
    [],
  );
  return (
    <Window title="Bug Report Form" width={600} height={750}>
      <Window.Content>
        <Section fill scrollable>
          <Flex direction="column" height="100%">
            <Flex.Item style={{ 'text-align': 'center' }}>
              <a
                href="https://github.com/goonstation/goonstation/issues/new?assignees=&labels=&template=bug_report.yml"
                target="_blank"
                rel="noreferrer"
                style={{
                  color: '#6992c2',
                }}
              >
                If you have a GitHub account click here instead
              </a>
            </Flex.Item>
            <Flex.Item>
              <InputTitle required>Title</InputTitle>
              <Input
                width="100%"
                value={formState.title}
                onChange={handleTitleChange}
              />
            </Flex.Item>
            <Flex.Item my={2}>
              <h2>Tags</h2>
              {tags.map((tag) => (
                <Button.Checkbox
                  key={tag[1]}
                  checked={tag[1] === chosenTag}
                  onClick={() => setTag(tag[1])}
                  tooltip={tag[2]}
                  tooltipPosition="bottom"
                >
                  {tag[0]}
                </Button.Checkbox>
              ))}
            </Flex.Item>
            <Flex.Item my={2}>
              <InputTitle required>Description</InputTitle>
              Give a short description of the bug
              <Input
                width="100%"
                value={formState.description}
                onChange={handleDescriptionChange}
              />
            </Flex.Item>
            <Flex.Item my={2}>
              <InputTitle required>Steps To Reproduce</InputTitle>
              Give a list of steps to reproduce this issue
              <BugReportFormTextArea
                onChange={handleStepsChange}
                value={formState.steps}
                placeholder={`1.
2.
3.`}
              />
            </Flex.Item>
            <Flex.Item my={2}>
              <InputTitle required>Expected Behavior</InputTitle>
              Give a short description of what you expected to happen
              <Input
                width="100%"
                value={formState.expectedBehavior}
                onChange={handleExpectedBehaviorChange}
              />
            </Flex.Item>
            <Flex.Item my={2}>
              <h2>Additional Information & Screenshots</h2>
              Add screenshots and any other information here
              <BugReportFormTextArea
                value={formState.additional}
                onChange={handleAdditionalChange}
              />
            </Flex.Item>
            <Flex.Item my={2}>
              <h2>Is this bug an exploit or related to secret content?</h2>
              <Button.Checkbox
                checked={isSecret}
                onClick={() => {
                  setIsSecret(!isSecret);
                }}
              >
                Exploit / Secret
              </Button.Checkbox>
            </Flex.Item>
            <Flex.Item my={2}>
              <Flex style={{ 'justify-content': 'center' }}>
                <Flex.Item mx={1}>
                  <div
                    className="Button Button--color--default"
                    onClick={handleSubmit}
                  >
                    Submit
                  </div>
                </Flex.Item>
                <Flex.Item mx={1}>
                  <div
                    className="Button Button--color--default"
                    onClick={handleCancel}
                  >
                    Cancel
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
