import { useBackend } from '../backend';
import { Button, Section, Flex, TextArea } from '../components';
import { Window } from '../layouts';

export const ArtifactPaper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    artifactName,
    artifactOrigin,
    artifactType,
    artifactTriggers,
    artifactFaults,
    artifactDetails,
    allArtifactOrigins,
    allArtifactTypes,
    allArtifactTriggers,
    hasPen,
  } = data;

  return (
    <Window
      title="Nanotrasen Alien Artifact Analysis Form"
      theme="paper"
      width={800}
      height={825}
    >
      <body overflow={"scroll"}>
        <Section>
          <h3>Artifact Name</h3>
          <h4>{ artifactName === "" ? "unknown" : artifactName }</h4>
          <h3>Artifact Origin</h3>
          <Flex direction={"column"} wrap={"wrap"} height={3}>
            {allArtifactOrigins.map(x => (
              <Flex.Item key={x.id}
                onClick={(e, value) => act("origin", { newOrigin: x, hasPen: hasPen })}>
                <Button.Checkbox
                  checked={artifactOrigin === x}
                />
                <a>{x}</a>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Type</h3>
          <Flex direction={"column"} wrap={"wrap"} height={25} justify={"space-evenly"}>
            {allArtifactTypes.map(x => (
              <Flex.Item key={x.id}
                onClick={(e, value) => act("type", { newType: x, hasPen: hasPen })}>
                <Button.Checkbox
                  checked={artifactType === x}
                />
                <a>{x}</a>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Triggers</h3>
          <Flex direction={"column"} wrap={"wrap"} height={5}>
            {allArtifactTriggers.map(x => (
              <Flex.Item key={x.id}
                onClick={(e, value) => act("trigger", { newTriggers: x, hasPen: hasPen })}>
                <Button.Checkbox
                  checked={artifactTriggers === x}
                />
                <a>{x}</a>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Faults</h3>
          <TextArea
            value={artifactFaults}
            fluid
            height={5}
            onChange={(_, x) => act("fault", { newFaults: x, hasPen: hasPen })} />

          <h3>Additional Information</h3>
          <TextArea
            value={artifactDetails}
            fluid
            height={10}
            onChange={(_, x) => act("detail", { newDetail: x, hasPen: hasPen })} />
        </Section>
      </body>
    </Window>
  );
};
