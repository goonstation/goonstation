/**
 * @file
 * @copyright 2021 AndrewL97 (https://github.com/AndrewL97)
 * @author Original AndrewL97 (https://github.com/AndrewL97)
 * @author Changes Azrun
 * @license MIT
 */

import { toFixed } from 'common/math';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, ColorBox, Flex, Input, LabeledList, NoticeBox, NumberInput, Section, Tooltip } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

const ParticleIntegerEntry = (props, context) => {
  const { value, name } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      stepPixelSize={5}
      width="39px"
      onDrag={(e, value) => act('modify_particle_value', {
        new_data: {
          name: name,
          value: value,
          type: 'int',
        },
      })} />
  );
};

const ParticleMatrixEntry = (props, context) => {
  let { value, name } = props;
  const { act } = useBackend(context);


  // Actual matrix, or matrix of 0
  value = value || [0, 0, 0, 0, 0, 0];
  return (
    <Flex>
      <Flex.Item>
        {value.map((val, i) => (
          <NumberInput
            value={val}
            key={i}
            onDrag={(e, v) =>
            {
              value[i] = v;
              act('modify_particle_value', {
                new_data: {
                  name: name,
                  value: value,
                  type: 'matrix',
                },
              }); }}
          />))}
      </Flex.Item>
    </Flex>

  );
};

const ParticleFloatEntry = (props, context) => {
  const { value, name } = props;
  const { act } = useBackend(context);
  const [step, setStep] = useLocalState(context, 'particleFloatStep', 0.01);
  return (
    <>
      <NumberInput
        value={value}
        stepPixelSize={4}
        step={step}
        format={value => toFixed(value, 2)}
        width="80px"
        onDrag={(e, value) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'float',
            },
          })} />
      <Box
        inline
        ml={2}
        mr={1}>
        Step:
      </Box>
      <NumberInput
        value={step}
        step={0.001}
        format={value => toFixed(value, 2)}
        width="70px"
        onChange={(e, value) => setStep(value)} />
    </>
  );
};

// array for our working varz
// let genWorking = [];

const ParticleGeneratorEntry = (props, context) => {
  const { value, name } = props;
  const { act } = useBackend(context);
  const generatorTypes = ["num", "vector", "box", "color", "circle", "sphere", "square", "cube"];
  const randTypes = ["UNIFORM_RAND", "NORMAL_RAND", "LINEAR_RAND", "SQUARE_RAND"];

  let tempGenType = '';
  let tempA = '';
  let tempB = '';
  let tempRand = '';

  logger.log(value);

  // Value will come through a binobj of the generator, i.e
  // "client generator(box, UNIFORM_RAND, list(-10,-10,-10), list(10,10,10))"
  // So do this hacky garbage to convert it back into values
  if (value) {
    // Get contents of brackets
    let params = value.match(/\((.*)\)/);
    params = params ? params : ["", "", "", ""];
    // Split into params
    params = params[1].split(', ');
    if (params.length === 4) {
      tempGenType = params[0];
      tempRand= params[1];

      // Try to get contents of list(), just pass value if null
      let aTemp = params[2].match(/\((.*)\)/);
      tempA = aTemp ? aTemp[1] : aTemp; // fermented soy beans

      let bTemp = params[3].match(/\((.*)\)/);
      tempB = bTemp ? bTemp[1] : params[3];
    }
  }

  const [genType, setGenType] = useLocalState(context, name + 'genType', tempGenType);
  const [a, setA] = useLocalState(context, name + 'a', tempA);
  const [b, setB] = useLocalState(context, name + 'b', tempB);
  const [rand, setRand] = useLocalState(context, name + 'rand', tempRand);

  const doAct = () => {
    logger.log(genType);
    act('modify_particle_value', {
      new_data: {
        name: name,
        value: {
          genType: genType,
          a: a,
          b: b,
          rand: rand,
        },
        type: 'generator',
      },
    }); };

  return (
    <Collapsible
      title="Generator Settings - Hit Set to save">
      <Section level={2}>
        <LabeledList>
          <LabeledList.Item label={genType}>
            <Tooltip position="bottom" content={`${generatorTypes.join(", ")}`}>
              <Input
                value={genType}
                onInput={(e, val) => setGenType(val)} />
            </Tooltip>
          </LabeledList.Item>
          <LabeledList.Item label="A"><Input
            value={a}
            onInput={(e, val) => setA(val)} />
          </LabeledList.Item>
          <LabeledList.Item label="B">
            <Input
              value={b}
              onInput={(e, val) => setB(val)} />
          </LabeledList.Item>
          <LabeledList.Item label="Rand Type">
            <Tooltip position="bottom" content={`${randTypes.join(", ")}`}>
              <Input
                value={rand}
                onInput={(e, val) => setRand(val)} />
            </Tooltip>
          </LabeledList.Item>

        </LabeledList>
        <Button
          content="Set"
          onClick={() => doAct()} />
      </Section >
    </Collapsible>

  );
};

const ParticleTextEntry = (props, context) => {
  const { value, name } = props;
  const { act } = useBackend(context);

  return (
    <Input
      value={value}
      width="250px"
      onInput={(e, value) => act('modify_particle_value', {
        new_data: {
          name: name,
          value: value,
          type: 'text',
        },
      })} />
  );
};

const ParticleNumListEntry = (props, context) => {
  const { value, name } = props;
  const { act } = useBackend(context);

  let valArr = value ? Object.keys(value).map((key) => value[key]) : [];

  return (
    <Input
      value={valArr.join(',')}
      width="250px"
      onInput={(e, val) => act('modify_particle_value', {
        new_data: {
          name: name,
          value: val,
          type: 'numList',
        },
      })} />
  );
};

const ParticleColorEntry = (props, context) => {
  const { value, name } = props;
  const { act } = useBackend(context);
  return (
    <>
      <Button
        icon="pencil-alt"
        onClick={() => act('modify_color_value')} />
      <ColorBox
        color={value}
        mr={0.5} />
      <Input
        value={value}
        width="90px"
        onInput={(e, value) => act('modify_particle_value', {
          new_data: {
            name: name,
            value: value,
            type: 'color',
          },
        })} />
    </>
  );
};

const ParticleIconEntry = (props, context) => {
  const { value } = props;
  const { act } = useBackend(context);
  return (
    <>
      <Button
        icon="pencil-alt"
        onClick={() => act('modify_icon_value')} />
      <Box inline ml={1}>
        {value}
      </Box>
    </>
  );
};


const particleEntryMap = {

  width: 'float',
  height: 'float',
  count: 'int',
  spawning: 'float',
  bound1: 'numlist',
  bound2: 'numlist',
  gravity: 'numlist',
  gradient: 'string',
  transform: 'matrix',
  lifespan: 'float',
  fade: 'float',
  fadein: 'float',
  icon: 'icon',
  icon_state: 'string',
  color: 'color',
  color_change: 'float',
  position: 'generator',
  velocity: 'generator',
  scale: 'generator',
  grow: 'generator',
  rotation: 'float',
  spin: 'float',
  friction: 'float',
  drift: 'generator',
};

const ParticleDataEntry = (props, context) => {
  const { name, value } = props;

  const particleEntryTypes = {
    int: <ParticleIntegerEntry {...props} />,
    float: <ParticleFloatEntry {...props} />,
    string: <ParticleTextEntry {...props} />,
    numlist: <ParticleNumListEntry {...props} />,
    color: <ParticleColorEntry {...props} />,
    icon: <ParticleIconEntry {...props} />,
    generator: <ParticleGeneratorEntry {...props} />,
    matrix: <ParticleMatrixEntry {...props} />,
  };

  return (
    <LabeledList.Item label={name}>
      {particleEntryTypes[particleEntryMap[name]] || "Not Found (This is an error)"}
    </LabeledList.Item>
  );
};

const ParticleEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { particle } = props;
  return (
    <LabeledList>
      {Object.keys(particleEntryMap).map(entryName => {
        const value = particle[entryName];
        return (
          <ParticleDataEntry
            key={entryName}
            name={entryName}
            value={value} />
        );
      })}
    </LabeledList>
  );
};


const GeneratorHelp = () => {
  return (
    <Collapsible title="Generator Help"><Section level={2} />
      <Section level={2}>
        <table>
          <tbody>
            <tr>
              <td>Generator type</td>
              <td>Result type</td>
              <td>Description</td>
            </tr>
            <tr>
              <td>num</td>
              <td>num</td>
              <td>A random number between A and B.</td>
            </tr>
            <tr>
              <td>vector</td>
              <td>vector</td>
              <td>A random vector on a line between A and B.</td>
            </tr>
            <tr>
              <td>box</td>
              <td>vector</td>
              <td>A random vector within a box whose corners are at A and B.</td>
            </tr>
            <tr>
              <td>color</td>
              <td>color (string) or color matrix</td>
              <td>Result type depends on whether A or B are matrices or not.
                The result is interpolated between A and B; components are not randomized separately.
              </td>
            </tr>
            <tr>
              <td>circle</td>
              <td>vector</td>
              <td>A random XY-only vector in a ring between radius A and B, centered at 0,0.</td>
            </tr>
            <tr>
              <td>sphere</td>
              <td>vector</td>
              <td>A random vector in a spherical shell between radius A and B, centered at 0,0,0.</td>
            </tr>
            <tr>
              <td>square</td>
              <td>vector</td>
              <td>A random XY-only vector between squares of sizes A and B.
                (The length of the square is between A*2 and B*2, centered at 0,0.)
              </td>
            </tr>
            <tr>
              <td>cube</td>
              <td>vector</td>
              <td>A random vector between cubes of sizes A and B.
                (The length of the cube is between A*2 and B*2, centered at 0,0,0.)
              </td>
            </tr>
          </tbody>
        </table>
      </Section>
    </Collapsible>); };



export const Particool = (props, context) => {
  const { act, data } = useBackend(context);
  const particles = data.target_particle || {};
  const hasParticles = particles && Object.keys(particles).length > 0;

  const [massApplyPath, setMassApplyPath] = useLocalState(context, 'massApplyPath', '');
  const [hiddenSecret, setHiddenSecret] = useLocalState(context, 'hidden', false);
  return (
    <Window
      title="Particool"
      width={700}
      height={500}>
      <Window.Content scrollable>
        <NoticeBox danger> {String(Date.now())} <br />
          Particles? {hasParticles.toString()} -
          {(data.target_particle === null).toString()} <br />
          Json - {JSON.stringify(data.target_particle)}
        </NoticeBox>
        <Section
          title={
            <Box
              inline
              onDblClick={() => setHiddenSecret(true)}>
              Particle
            </Box>
          }
          buttons={!hasParticles ? (
            <Button
              icon="plus"
              content="Add Particle"
              onClick={() => act('add_particle')} />
          ) : (<Button.Confirm
            icon="minus"
            content="Remove Particle"
            onClick={() => act("remove_particle")} />)} >
          <GeneratorHelp />
          {!hasParticles ? (
            <Box>
              No particle
            </Box>
          ) : (
            <ParticleEntry particle={particles} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
