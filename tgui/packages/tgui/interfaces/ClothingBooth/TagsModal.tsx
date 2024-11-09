/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useCallback, useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Modal } from '../../components';
import {
  ClothingBoothData,
  ClothingBoothGroupingTagsData,
  TagDisplayOrderType,
  TagsLookup,
} from './type';
import { buildFieldComparator, stringComparator } from './utils/comparator';

interface TagsModalProps {
  onApplyAndClose: (newFilters: TagsLookup) => void;
  onClose: () => void;
  initialTagFilters: TagsLookup;
}

export const TagsModal = (props: TagsModalProps) => {
  const { initialTagFilters, onApplyAndClose, onClose } = props;
  const [tagFilters, setTagFilters] = useState(initialTagFilters);
  const handleResetClick = useCallback(
    () => setTagFilters(initialTagFilters),
    [setTagFilters],
  );
  const handleApplyClick = useCallback(
    () => onApplyAndClose(tagFilters),
    [onApplyAndClose],
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
              tagType="Season"
              typeToDisplay={TagDisplayOrderType.Season}
            />
          </Stack.Item>
          <Stack.Item>
            <TagStackContainer
              tagType="Formality"
              typeToDisplay={TagDisplayOrderType.Formality}
            />
          </Stack.Item>
          <Stack.Item>
            <TagStackContainer
              tagType="Collection"
              typeToDisplay={TagDisplayOrderType.Collection}
            />
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <Stack justify="space-around">
          <Stack.Item>
            <Button
              disabled={!Object.values(tagFilters).includes(true)}
              onClick={handleResetClick}
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
  tagType: string;
  typeToDisplay: number;
}

const TagStackContainer = (props: TagStackContainerProps) => {
  const { data } = useBackend<ClothingBoothData>();
  const { tagType, typeToDisplay } = props;
  const groupingTags = Object.values(data.tags).filter(
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
          <TagCheckbox {...tag} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const TagCheckbox = (props: ClothingBoothGroupingTagsData) => {
  const { name } = props;

  const [tagFilters, setTagFilters] = useState<TagsLookup>({});
  const mergeTagFilter = (filter: string) =>
    setTagFilters({
      ...tagFilters,
      [filter]: !tagFilters[filter],
    });

  return (
    <Button.Checkbox
      fluid
      checked={!!tagFilters[name]}
      onClick={() => mergeTagFilter(name)}
    >
      {name}
    </Button.Checkbox>
  );
};
