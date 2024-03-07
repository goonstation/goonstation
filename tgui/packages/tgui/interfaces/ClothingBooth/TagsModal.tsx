import { useBackend, useLocalState } from '../../backend';
import { Button, Dimmer, Section, Stack } from '../../components';
import { ClothingBoothData, ClothingBoothGroupingTagsData, TagDisplayOrderType } from './type';
import { buildFieldComparator, stringComparator } from './utils/Comparator';

export const TagsModal = (_, context) => {
  const [tagModal, setTagModal] = useLocalState(context, 'tagModal', false);
  const [tagFilters, setTagFilters] = useLocalState<Partial<Record<string, boolean>>>(context, 'tagFilters', {});

  return (
    <Dimmer>
      <Section
        scrollable
        buttons={
          <Stack>
            <Stack.Item>
              <Button icon="trash" onClick={() => setTagFilters({})}>
                Clear Tags
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button icon="xmark" onClick={() => setTagModal(!tagModal)}>
                Close
              </Button>
            </Stack.Item>
          </Stack>
        }
        title="Tags">
        <Stack fluid>
          <Stack.Item>
            <TagStackContainer tagType="Season" typeToDisplay={TagDisplayOrderType.Season} />
          </Stack.Item>
          <Stack.Item>
            <TagStackContainer tagType="Formality" typeToDisplay={TagDisplayOrderType.Formality} />
          </Stack.Item>
          <Stack.Item>
            <TagStackContainer tagType="Collection" typeToDisplay={TagDisplayOrderType.Collection} />
          </Stack.Item>
        </Stack>
      </Section>
    </Dimmer>
  );
};

interface TagStackContainerProps {
  tagType: string;
  typeToDisplay: number;
}

const TagStackContainer = (props: TagStackContainerProps, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const { tagType, typeToDisplay } = props;
  const groupingTags = Object.values(data.tags).filter((groupingTag) => groupingTag.display_order === typeToDisplay);
  const sortedTags = groupingTags.sort(buildFieldComparator((groupingTag) => groupingTag.name, stringComparator));

  return (
    <Stack fill vertical>
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

const TagCheckbox = (props: ClothingBoothGroupingTagsData, context) => {
  const { name } = props;

  const [tagFilters, setTagFilters] = useLocalState<Partial<Record<string, boolean>>>(context, 'tagFilters', {});
  const mergeTagFilter = (filter: string) =>
    setTagFilters({
      ...tagFilters,
      [filter]: !tagFilters[filter],
    });

  return (
    <Button.Checkbox fluid checked={!!tagFilters[name]} color="" onClick={() => mergeTagFilter(name)}>
      {name}
    </Button.Checkbox>
  );
};
