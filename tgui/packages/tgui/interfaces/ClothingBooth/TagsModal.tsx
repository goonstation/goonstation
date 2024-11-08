/**
 * @file
 * @copyright 2024
 * @author DisturbHerb (https://github.com/disturbherb)
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useContext, useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Modal } from '../../components';
import {
  ClothingBoothData,
  ClothingBoothGroupingTagsData,
  TagDisplayOrderType,
} from './type';
import { UiStateContext } from './uiState';
import { buildFieldComparator, stringComparator } from './utils/comparator';

export const TagsModal = () => {
  const { setShowTagsModal } = useContext(UiStateContext);
  const [tagFilters, setTagFilters] = useState<
    Partial<Record<string, boolean>>
  >({});

  return (
    <Modal fitted>
      <Section
        buttons={
          <>
            <Button
              disabled={!Object.values(tagFilters).includes(true)}
              icon="trash"
              onClick={() => setTagFilters({})}
            >
              Clear Tags
            </Button>
            <Button icon="xmark" onClick={() => setShowTagsModal(false)}>
              Close
            </Button>
          </>
        }
        title="Tags"
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

  const [tagFilters, setTagFilters] = useState<
    Partial<Record<string, boolean>>
  >({});
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
