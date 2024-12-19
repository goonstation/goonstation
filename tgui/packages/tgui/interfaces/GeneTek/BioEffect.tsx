/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../../backend';
import { Modal } from '../../components';
import { DNASequence } from './DNASequence';
import { GeneIcon } from './GeneIcon';
import { UnlockModal } from './modals/UnlockModal';
import type { GeneTekData } from './type';

export const ResearchLevel = {
  None: 0,
  InProgress: 1,
  Done: 2,
  Activated: 3,
};

export const haveDevice = (equipmentCooldown, name) => {
  for (const { label } of equipmentCooldown) {
    if (label === name) {
      return true;
    }
  }

  return false;
};

export const onCooldown = (equipmentCooldown, name) => {
  for (const { label, cooldown } of equipmentCooldown) {
    if (label === name) {
      return cooldown > 0;
    }
  }

  return true;
};

interface Booth {
  ref: string;
  price: number;
  desc: string;
}

export const BioEffect = (props) => {
  const { data, act } = useBackend<GeneTekData>();
  const [booth, setBooth] = useSharedState<Booth | null>('booth', null);
  const {
    materialCur,
    researchCost,
    equipmentCooldown,
    saveSlots,
    savedMutations,
    subject,
    boothCost,
    injectorCost,
    precisionEmitter,
    toSplice,
  } = data;
  const { gene, showSequence, isSample, isPotential, isActive, isStorage } =
    props;
  const {
    ref,
    name,
    desc,
    icon,
    research,
    canResearch,
    canInject,
    canScramble,
    canReclaim,
    spliceError,
    dna,
  } = gene;

  const dnaGood = dna.every((pair) => !pair.style);
  const dnaGoodExceptLocks = dna.every(
    (pair) => !pair.style || pair.marker === 'locked',
  );
  let activeOrStorage = isActive || isStorage; // haha, what a dumb way to reduce arrow function complexity
  return (
    <Section title={name} buttons={<GeneIcon name={icon} size={1.5} />}>
      {booth && booth.ref === ref && (
        <Modal full>
          <Section
            width={35}
            title={name}
            style={{
              margin: '-10px',
              marginRight: '2px',
            }}
            buttons={
              <GeneIcon
                name={icon}
                size={4}
                style={{
                  marginTop: '-2px',
                  marginRight: '-4px',
                }}
              />
            }
          >
            <LabeledList>
              <LabeledList.Item label="Price">
                <NumberInput
                  minValue={0}
                  maxValue={999999}
                  step={1}
                  width={'5'}
                  value={booth.price.toFixed()}
                  onChange={(price) =>
                    setBooth({
                      ref: booth.ref,
                      price: price,
                      desc: booth.desc,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Description">
                <Input
                  width={25}
                  value={booth.desc}
                  onChange={(_, desc) =>
                    setBooth({
                      ref: booth.ref,
                      price: booth.price,
                      desc: desc,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
            <Box inline width="50%" textAlign="center" mt={2}>
              <Button
                icon="person-booth"
                color="good"
                disabled={boothCost > materialCur}
                onClick={() => act('booth', booth)}
              >
                Send to Booth
              </Button>
            </Box>
            <Box inline width="50%" textAlign="center">
              <Button icon="times" color="bad" onClick={() => setBooth(null)}>
                Cancel
              </Button>
            </Box>
          </Section>
        </Modal>
      )}
      <UnlockModal />
      <Box textAlign="right">
        <Box mr={1} style={{ float: 'left' }}>
          <Icon
            color={
              research >= 3
                ? 'good'
                : research >= 2
                  ? 'teal'
                  : research >= 1
                    ? 'average'
                    : 'bad'
            }
            name={
              research >= 2 ? 'flask' : research >= 1 ? 'hourglass' : 'times'
            }
          />
          {research >= 2
            ? ' Researched'
            : research >= 1
              ? ' In Progress'
              : ' Not Researched'}
        </Box>
        {!isActive && !!canResearch && research === 0 && (
          <Button
            icon="flask"
            disabled={researchCost > materialCur}
            onClick={() =>
              act('researchmut', {
                ref: ref,
                sample: !!isSample,
              })
            }
            color="teal"
          >
            Research
          </Button>
        )}
        {isPotential && (
          <Button
            icon="check"
            disabled={!dnaGood}
            onClick={() => act('activate', { ref })}
            color="blue"
          >
            Activate
          </Button>
        )}
        {research >= 3 && !dnaGood && (
          <Button
            icon="magic"
            disabled={dnaGoodExceptLocks}
            onClick={() => act('autocomplete', { ref })}
          >
            Autocomplete DNA
          </Button>
        )}
        {haveDevice(equipmentCooldown, 'Analyzer') &&
          !dnaGood &&
          isPotential && (
            <Button
              disabled={onCooldown(equipmentCooldown, 'Analyzer')}
              icon="microscope"
              color="average"
              onClick={() => act('analyze', { ref })}
            >
              Check Stability
            </Button>
          )}
        {haveDevice(equipmentCooldown, 'Reclaimer') &&
          activeOrStorage &&
          !!canReclaim && (
            <Button
              disabled={onCooldown(equipmentCooldown, 'Reclaimer')}
              icon="times"
              color="bad"
              onClick={() => act('reclaim', { ref })}
            >
              Reclaim
            </Button>
          )}
        {boothCost >= 0 && research >= 2 && activeOrStorage && (
          <Button
            disabled={materialCur < boothCost}
            icon="person-booth"
            color="good"
            onClick={() => setBooth({ ref: ref, price: 200, desc: '' })}
          >
            Sell at Booth
          </Button>
        )}
        {!!precisionEmitter &&
          research >= 2 &&
          isPotential &&
          !!canScramble && (
            <Button
              icon="radiation"
              disabled={
                onCooldown(equipmentCooldown, 'Emitter') ||
                (subject && subject.stat > 0)
              }
              color="bad"
              onClick={() => act('precisionemitter', { ref })}
            >
              Scramble Gene
            </Button>
          )}
        {saveSlots > 0 && research >= 2 && isActive && (
          <Button
            disabled={saveSlots <= savedMutations.length}
            icon="save"
            color="average"
            onClick={() => act('save', { ref })}
          >
            Store
          </Button>
        )}
        {research >= 2 &&
          !!canInject &&
          haveDevice(equipmentCooldown, 'Injectors') && (
            <Button
              disabled={onCooldown(equipmentCooldown, 'Injectors')}
              icon="syringe"
              onClick={() => act('activator', { ref })}
            >
              Activator
            </Button>
          )}
        {research >= 2 &&
          !!canInject &&
          injectorCost >= 0 &&
          activeOrStorage && (
            <Button
              disabled={
                onCooldown(equipmentCooldown, 'Injectors') ||
                materialCur < injectorCost
              }
              icon="syringe"
              onClick={() => act('injector', { ref })}
              color="bad"
            >
              Injector
            </Button>
          )}
        {activeOrStorage && !!toSplice && (
          <Button
            disabled={!!spliceError}
            icon="map-marker-alt"
            onClick={() => act('splicegene', { ref })}
            tooltip={spliceError}
            tooltipPosition="left"
          >
            Splice
          </Button>
        )}
        {isStorage && subject && (
          <Button
            icon="check"
            onClick={() => act('addstored', { ref })}
            color="blue"
          >
            Add to Occupant
          </Button>
        )}
        {isStorage && (
          <Button
            icon="trash"
            onClick={() => act('deletegene', { ref })}
            color="bad"
          />
        )}
        <Box inline />
      </Box>
      <Description text={desc} />
      {showSequence && <DNASequence {...props} />}
    </Section>
  );
};

export const Description = (props, context) => {
  const lines = props.text?.split(/<br ?\/?>/g);

  return lines?.map((line, i) => <p key={i}>{line}</p>);
};

export const GeneList = (props) => {
  const { data, act } = useBackend<GeneTekData>();
  const { activeGene } = data;
  const { genes, noSelection, noGenes, ...rest } = props;
  const ag = genes.find((g) => g.ref === activeGene);

  const researchLevels = {
    [ResearchLevel.None]: {
      icon: 'question',
      color: 'grey',
    },
    [ResearchLevel.InProgress]: {
      icon: 'hourglass',
      color: 'average',
    },
    [ResearchLevel.Done]: {
      icon: 'flask',
      color: 'teal',
    },
    [ResearchLevel.Activated]: {
      icon: 'flask',
      color: 'good',
    },
  };

  return (
    <>
      <Flex wrap mb={1}>
        {genes.map((g) => (
          <Flex.Item key={g.ref} grow={1} textAlign="center">
            <Button
              icon={researchLevels[g.research].icon}
              color={
                g.ref === activeGene
                  ? 'black'
                  : researchLevels[g.research].color
              }
              onClick={() => act('setgene', { ref: g.ref })}
              tooltip={
                g.research === ResearchLevel.InProgress
                  ? 'Researching...'
                  : g.name
              }
              tooltipPosition="left"
              width="80%"
            />
          </Flex.Item>
        ))}
      </Flex>
      {!genes.length && (noGenes || 'No genes found.')}
      {!!genes.length && !ag && (noSelection || 'Select a gene to view it.')}
      {ag && <BioEffect key={ag.ref} gene={ag} showSequence {...rest} />}
    </>
  );
};
