import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Dimmer, Section, Stack } from '../../components';
import { ClothingBoothData, ClothingBoothGroupingTagsData, TagDisplayOrderType } from './type';
import { buildFieldComparator, stringComparator } from './utils/Comparator';

export const TagsModal = (_, context) => {
  const [tagModal, setTagModal] = useLocalState(context, 'tagModal', false);

  return (
    <Dimmer>
      <Section
        scrollable
        buttons={
          <Button icon="xmark" onClick={() => setTagModal(!tagModal)}>
            Close
          </Button>
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
  const tags = Object.values(data.tags).filter(tag => tag.display_order === typeToDisplay);
  const sortedTags = tags.sort(
    buildFieldComparator((tags) => tags.name, stringComparator)
  );

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
  const { colour, name } = props;
  return (
    <Button.Checkbox color="" fluid>
      <Box inline color={colour && colour}>
        {name}
      </Box>
    </Button.Checkbox>
  );
};
