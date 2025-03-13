/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useCallback, useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { Modal } from '../../components';
import {
  ClothingBoothGroupingTagsData,
  TagDisplayOrderType,
  type TagFilterLookup,
} from './type';
import { buildFieldComparator, stringComparator } from './utils/comparator';

interface TagsModalProps {
  onApplyAndClose: (newFilters: TagFilterLookup) => void;
  onClose: () => void;
  initialTagFilters: TagFilterLookup;
  tags: Record<string, ClothingBoothGroupingTagsData>;
}

export const TagsModal = (props: TagsModalProps) => {
  const { initialTagFilters, onApplyAndClose, onClose, tags } = props;
  const [tagFilters, setTagFilters] = useState(initialTagFilters);
  const handleClearClick = useCallback(
    () => setTagFilters({}),
    [setTagFilters],
  );
  const handleApplyClick = useCallback(
    () => onApplyAndClose(tagFilters),
    [onApplyAndClose, tagFilters],
  );
  const handleToggle = useCallback(
    (tagName: string) =>
      setTagFilters((prev) => ({
        ...prev,
        [tagName]: !prev[tagName],
      })),
    [],
  );
  return (
    <Modal fitted>
      <Section
        title="Tags"
        buttons={
          <Button color="bad" icon="xmark" onClick={onClose} tooltip="Close" />
        }
      >
        <Stack mr={1}>
          <Stack.Item>
            <TagStackContainer
              onToggle={handleToggle}
              tagType="Season"
              typeToDisplay={TagDisplayOrderType.Season}
              tags={tags}
              tagFilters={tagFilters}
            />
          </Stack.Item>
          <Stack.Item>
            <TagStackContainer
              onToggle={handleToggle}
              tagType="Formality"
              typeToDisplay={TagDisplayOrderType.Formality}
              tags={tags}
              tagFilters={tagFilters}
            />
          </Stack.Item>
          <Stack.Item>
            <TagStackContainer
              onToggle={handleToggle}
              tagType="Collection"
              typeToDisplay={TagDisplayOrderType.Collection}
              tags={tags}
              tagFilters={tagFilters}
            />
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <Stack justify="space-around">
          <Stack.Item>
            <Button
              disabled={!Object.values(tagFilters).includes(true)}
              onClick={handleClearClick}
            >
              Clear Tags
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button color="good" icon="check" onClick={handleApplyClick}>
              Apply Tags
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};

interface TagStackContainerProps {
  onToggle: (tagName: string) => void;
  tagType: string;
  typeToDisplay: number;
  tags: Record<string, ClothingBoothGroupingTagsData>;
  tagFilters: TagFilterLookup;
}

const TagStackContainer = (props: TagStackContainerProps) => {
  const { onToggle, tagType, typeToDisplay, tags, tagFilters } = props;
  const groupingTags = Object.values(tags).filter(
    (groupingTag) => groupingTag.display_order === typeToDisplay,
  );
  const sortedTags = groupingTags.sort(
    buildFieldComparator((groupingTag) => groupingTag.name, stringComparator),
  );

  return (
    <Stack fill vertical mr={1}>
      <Stack.Item bold textAlign="center">
        {tagType}
      </Stack.Item>
      {sortedTags.map((tag) => (
        <Stack.Item key={tag.name}>
          <TagCheckbox
            name={tag.name}
            checked={!!tagFilters[tag.name]}
            onClick={onToggle}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

interface TagCheckboxProps {
  checked: boolean;
  name: string;
  onClick: (name: string) => void;
}

const TagCheckbox = (props: TagCheckboxProps) => {
  const { name, checked, onClick } = props;
  const handleClick = useCallback(() => onClick(name), [name, onClick]);
  return (
    <Button.Checkbox fluid checked={checked} onClick={handleClick}>
      {name}
    </Button.Checkbox>
  );
};
