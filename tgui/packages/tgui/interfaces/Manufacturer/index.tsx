
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Flex, Image, Section, Stack } from '../../components';

const CategoryButton = (props) => {
  const { name } = props;

  return (
    <Stack.Item textAlign={"center"}>
      <Button>
        {name}
      </Button>
    </Stack.Item>
  );
};

const BlueprintButton = (props) => {
  const { blueprintData } = props;

  return (
    <Button
      width="140px"
      height="100px"
    >
      <Box>
        abcdefghijklmnopqrstuvwxyzabcdefg
      </Box>
    </Button>
  );
};

// <Image pixelated src={blueprintData.img} width={5} />

export const Manufacturer = (_, context) => {
  const { data } = useBackend<ManufacturerData>(context);
  return (
    <Window width={800} height={1000}>
      <Section width={52}>
        <Stack pb={2}>
          {data.categories.map((name) => (<CategoryButton name={name} key={name} />))}
        </Stack>
        {data.available_blueprints.map((blueprint) =>
          (<BlueprintButton blueprintData={blueprint} key={blueprint.name} />))}
      </Section>

    </Window>
  );
};

