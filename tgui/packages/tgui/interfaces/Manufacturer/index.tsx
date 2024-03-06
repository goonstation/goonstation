
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Box, Button, Collapsible, Image, Section, Stack } from '../../components';

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
      width={20}
      height={6.5}
      mr={1}
      pl={0}
    >
      <Stack
        style={{
          "white-space": "normal",
        }}
      >
        <Stack.Item
          ml={0}
          style={{
            "background": "rgba(0,0,0,0.1)",
          }}
        >
          <Image pixelated src={blueprintData.img} width={5} />
        </Stack.Item>
        <Stack.Item>
          <Section
            title={blueprintData.name}
          >
            <Stack fill>
              <Stack.Item>
                <Button icon="gear" />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Button>
  );
};

const CategoryDropdown = (props) => {
  const { category, blueprints } = props;
  let buttons = [];
  for (let i in blueprints) {
    buttons.push(<BlueprintButton blueprintData={blueprints[i]} />);
  }
  return (
    <Collapsible open title={category}>
      {buttons}
    </Collapsible>
  );
};
// {blueprints.map((data) => { <BlueprintButton key={data} blueprintData={data} />; })}
//

export const Manufacturer = (_, context) => {
  const { data } = useBackend<ManufacturerData>(context);
  let usable_blueprints = data.available_blueprints;
  let dropdowns = [];
  for (let i of data.all_categories) {
    dropdowns.push(<CategoryDropdown category={i} blueprints={usable_blueprints[i]} />);
  }
  return (
    <Window width={1111} height={600}>
      <Section width={62.5}>
        {dropdowns}
      </Section>
      <Image pixelated src={data.available_blueprints["Resource"]["Machine Translator Implant"]["img"]} width={5} />
    </Window>
  );
};

//
