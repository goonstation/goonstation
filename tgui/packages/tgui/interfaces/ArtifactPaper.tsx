/**
 * @file
 * @copyright 2021
 * @author zjdtmkhzt (https://github.com/zjdtmkhzt)
 * @license MIT
 */

import { Button, Flex, Section, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// TODO: change usages to be theme-based rather than override color here
const paperColor = 'white';

interface ArtifactPaperData {
  artifactName;
  artifactOrigin;
  artifactType;
  artifactTriggers;
  artifactFaults;
  artifactDetails;
  allArtifactOrigins;
  allArtifactTypes;
  allArtifactTriggers;
  crossed;
}

export const ArtifactPaper = () => {
  const { act, data } = useBackend<ArtifactPaperData>();
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
    crossed,
  } = data;

  return (
    <Window
      title="Nanotrasen Alien Artifact Analysis Form"
      theme="paper"
      width={800}
      height={835}
    >
      <Window.Content backgroundColor={paperColor}>
        <Section backgroundColor={paperColor}>
          <h3>Artifact Name</h3>
          <h4>{artifactName === '' ? 'unknown' : artifactName}</h4>
          <h3>Artifact Origin</h3>
          <Flex direction={'column'} wrap={'wrap'} height={3}>
            {allArtifactOrigins.map((x) => (
              <Flex.Item
                key={x.id}
                onClick={(e, value) => act('origin', { newOrigin: x })}
              >
                <Button.Checkbox checked={artifactOrigin === x} />
                <a>{crossed.includes(x) ? <s>{x}</s> : x}</a>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Type</h3>
          <Flex
            direction={'column'}
            wrap={'wrap'}
            height={25}
            justify={'space-evenly'}
          >
            {allArtifactTypes.map((x) => (
              <Flex.Item
                className={'artifactType' + x[1]}
                key={x[0].id}
                onClick={(e, value) => act('type', { newType: x[0] })}
              >
                <Button.Checkbox checked={artifactType === x[0]} />
                <a>{crossed.includes(x[0]) ? <s>{x[0]}</s> : x[0]}</a>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Triggers (If Applicable)</h3>
          <Flex direction={'column'} wrap={'wrap'} height={5}>
            {allArtifactTriggers.map((x) => (
              <Flex.Item
                key={x.id}
                onClick={(e, value) => act('trigger', { newTriggers: x })}
              >
                <Button.Checkbox checked={artifactTriggers === x} />
                <a>{crossed.includes(x) ? <s>{x}</s> : x}</a>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Faults</h3>
          <TextArea
            value={artifactFaults}
            fluid
            height={5}
            onBlur={(x) => act('fault', { newFaults: x })}
            backgroundColor={paperColor}
          />
          <h3>Additional Information</h3>
          <TextArea
            value={artifactDetails}
            fluid
            height={10}
            onBlur={(x) => act('detail', { newDetail: x })}
            backgroundColor={paperColor}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
