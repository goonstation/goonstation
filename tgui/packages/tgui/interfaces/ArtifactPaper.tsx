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
const paperColor = 'AliceBlue';

interface ArtifactPaperData {
  artifactName: string;
  artifactOrigin: string;
  artifactType: string;
  artifactTriggers: string;
  artifactFaults: string;
  artifactDetails: string;
  allArtifactOrigins: string[];
  allArtifactTypes: [string, number][];
  allArtifactTriggers: string[];
  crossed: string[];
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
                key={x}
                onClick={(e, value) => act('origin', { newOrigin: x })}
              >
                <Button.Checkbox checked={artifactOrigin === x} />
                <span>{crossed.includes(x) ? <s>{x}</s> : x}</span>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Type</h3>
          <Flex
            direction={'column'}
            wrap={'wrap'}
            height={23}
            // justify={'space-evenly'}
          >
            {allArtifactTypes.map(([name, size]) => (
              <Flex.Item
                className={'artifactType' + size}
                backgroundColor={getArtifactSizeColor(size)}
                key={name}
                onClick={(e, value) => act('type', { newType: name })}
              >
                <Button.Checkbox checked={artifactType === name} />
                <span>{crossed.includes(name) ? <s>{name}</s> : name}</span>
              </Flex.Item>
            ))}
          </Flex>
          <h3>Artifact Triggers (If Applicable)</h3>
          <Flex direction={'column'} wrap={'wrap'} height={5}>
            {allArtifactTriggers.map((x) => (
              <Flex.Item
                key={x}
                onClick={(e, value) => act('trigger', { newTriggers: x })}
              >
                <Button.Checkbox checked={artifactTriggers === x} />
                <span>{crossed.includes(x) ? <s>{x}</s> : x}</span>
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

const getArtifactSizeColor = (size: number): string => {
  switch (size) {
    case 3: // ARTIFACT_SIZE_LARGE
      return '#c9acac';
    case 2: // ARTIFACT_SIZE_MEDIUM
      return '#ccc6b0';
    case 1: // ARTIFACT_SIZE_TINY
      return '#adc2d3';
    default:
      return 'lightgray';
  }
};
