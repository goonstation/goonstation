
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { Button, Collapsible, Image, Section, Stack } from '../../components';
import { truncate } from '../../format';

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


const BlueprintButton = (props, context) => {
  const { act } = useBackend(context);
  const { blueprintData } = props;

  return (
    <Button
      ellipsis
      width={15.2}
      height={5.3}
      mr={1}
      pl={0}
      pb={0}
      pt={0}
      mt={0}
      onClick={() => act("product", { "blueprint_ref": blueprintData.ref })}
    >
      <Stack>
        <Stack.Item
          ml={0}
          pt={0}
          mt={0}
          style={{
            "background": "rgba(0,0,0,0.1)",
          }}
        >
          <Image pixelated src={blueprintData.img} width={5} />
        </Stack.Item>
        <Stack.Item>
          <Stack vertical pt={1}>
            <Stack.Item><Button align="center" width={2} height={1.8} icon="gear" /></Stack.Item>
            <Stack.Item><Button align="center" width={2} height={1.8} icon="question" /></Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack
            vertical
            fill
            style={{
              "align-items": "center",
            }}
          >
            <Stack.Item
              width={6}
              textAlign="center"
              verticalAlign="center"
              style={{
                "white-space": "normal",
              }}
            >
              {truncate(blueprintData.name, 30)}
            </Stack.Item>
          </Stack>
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
    <Window width={1200} height={600}>
      <Section width={79.75} pl={0.5}>
        {dropdowns}
      </Section>
      <Image pixelated src={data.available_blueprints["Resource"]["Machine Translator Implant"]["img"]} width={5} />
    </Window>
  );
};

//
