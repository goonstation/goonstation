
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Image, Section, Stack } from '../../components';

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
    <Box width={5} textAlign="center" as="span">
      <Button width={5}>
        {blueprintData.name}
        <Image pixelated src={blueprintData.img} width={6} />
      </Button>
    </Box>
  );
};

export const Manufacturer = (_, context) => {
  const { data } = useBackend<ManufacturerData>(context);
  return (
    <Window width={800} height={500}>
      <Section width={52}>
        <Stack pb={2} >
          {data.categories.map((name) => (<CategoryButton name={name} key={name} />))}
        </Stack>
        {data.available_blueprints.map((blueprint) =>
          (<BlueprintButton blueprintData={blueprint} key={blueprint.name} />))}
      </Section>

    </Window>
  );
};

