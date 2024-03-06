import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Dimmer, Section, Stack } from '../../components';
import type { ClothingBoothData, ClothingBoothGroupingTagsData } from './type';
import { ClothingBoothGroupingTagDisplayOrderType } from './type';

export const TagsModal = (_, context) => {
  const { data } = useBackend<ClothingBoothData>(context);
  const [tagModal, setTagModal] = useLocalState(context, 'tagModal', false);

  const tagList = Object.values(data.tags);

  const seasonTags = tagList.filter((tag) => tag.display_order === ClothingBoothGroupingTagDisplayOrderType.Season);
  const formalityTags = tagList.filter(
    (tag) => tag.display_order === ClothingBoothGroupingTagDisplayOrderType.Formality
  );
  const collectionTags = tagList.filter(
    (tag) => tag.display_order === ClothingBoothGroupingTagDisplayOrderType.Collection
  );

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
            <Stack fill vertical>
              <Stack.Item bold textAlign="center">
                Season
              </Stack.Item>
              {seasonTags.map((tag) => (
                <Stack.Item key={tag.name}>
                  <TagCheckbox {...tag} />
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack fill vertical>
              <Stack.Item bold textAlign="center">
                Formality
              </Stack.Item>
              {formalityTags.map((tag) => (
                <Stack.Item key={tag.name}>
                  <TagCheckbox {...tag} />
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Stack fill vertical>
              <Stack.Item bold textAlign="center">
                Collection
              </Stack.Item>
              {collectionTags.map((tag) => (
                <Stack.Item key={tag.name}>
                  <TagCheckbox {...tag} />
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    </Dimmer>
  );
};

const TagCheckbox = (props: ClothingBoothGroupingTagsData, context) => {
  const { act } = useBackend<ClothingBoothData>(context);
  const { colour, name } = props;
  return (
    <Button.Checkbox color="" fluid>
      <Box inline color={colour && colour}>
        {name}
      </Box>
    </Button.Checkbox>
  );
};
