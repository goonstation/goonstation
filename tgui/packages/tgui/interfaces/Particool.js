/**
 * @file
 * @copyright 2021 Gomble (https://github.com/AndrewL97)
 * @author Original Gomble (https://github.com/AndrewL97)
 * @author Changes Azrun
 * @license MIT
 */

import { toFixed } from 'common/math';
import { numberOfDecimalDigits } from "../../common/math";
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, ColorBox, Flex, Input, LabeledList, NoticeBox, NumberInput, Section, Tooltip } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

const ParticleIntegerEntry = (props, context) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend(context);
  return (
    <Tooltip position="bottom" content={tooltip}>
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
    </Tooltip>
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
  const { value, tooltip, name } = props;
  const { act } = useBackend(context);
  const [step, setStep] = useLocalState(context, 'particleFloatStep', 0.01);
  return (
    <>
      <Tooltip position="bottom" content={tooltip}>
        <NumberInput
          value={value}
          stepPixelSize={4}
          step={step}
          format={value => toFixed(value, numberOfDecimalDigits(step))}
          width="80px"
          onDrag={(e, value) =>
            act('modify_particle_value', {
              new_data: {
                name: name,
                value: value,
                type: 'float',
              },
            })} />

      </Tooltip>
      <Box
        inline
        ml={2}
        mr={1}>
        Step:
      </Box>
      <NumberInput
        value={step}
        step={0.001}
        format={value => toFixed(value, numberOfDecimalDigits(step))}
        width="70px"
        onChange={(e, value) => setStep(value)} />
    </>
  );
};

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
  const { value, tooltip, name } = props;
  const { act } = useBackend(context);

  return (
    <Tooltip position="bottom" content={tooltip}>
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
    </Tooltip>
  );
};

const ParticleNumListEntry = (props, context) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend(context);

  let valArr = value ? Object.keys(value).map((key) => value[key]) : [];

  return (
    <Tooltip position="bottom" content={tooltip}>
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
    </Tooltip>
  );
};

const ParticleColorEntry = (props, context) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend(context);
  return (
    <Tooltip position="bottom" content={tooltip}>
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
    </Tooltip>
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

  width: { type: 'float', tooltip: 'Width of particle image in pixels' },
  height: { type: 'float', tooltip: 'Height of particle image in pixels' },
  count: { type: 'int', tooltip: "Maximum particle count" },
  spawning: { type: 'float', tooltip: "Number of particles to spawn per tick (can be fractional)" },
  bound1: { type: 'numlist', tooltip: "Minimum particle position in x,y,z space" },
  bound2: { type: 'numlist', tooltip: "Maximum particle position in x,y,z space" },
  gravity: { type: 'numlist', tooltip: "Constant acceleration applied to all particles in this set (pixels per squared tick)" },
  gradient: { type: 'string', tooltip: "Color gradient used, if any" },
  transform: { type: 'matrix', tooltip: "Transform done to all particles, if any (can be higher than 2D)" },
  lifespan: { type: 'float', tooltip: "Maximum life of the particle, in ticks" },
  fade: { type: 'float', tooltip: "Fade-out time at end of lifespan, in ticks" },
  fadein: { type: 'float', tooltip: "Fade-in time, in ticks" },
  icon: { type: 'icon', tooltip: "Icon to use, if any; no icon means this particle will be a dot" },
  icon_state: { type: 'string', tooltip: "Icon state to use, if any" },
  color: { type: 'color', tooltip: "Particle color; can be a number if a gradient is used" },
  color_change: { type: 'float', tooltip: "Color change per tick; only applies if gradient is used" },
  position: { type: 'generator', tooltip: "x,y,z position, from center in pixels" },
  velocity: { type: 'generator', tooltip: "x,y,z velocity, in pixels" },
  scale: { type: 'generator', tooltip: "(2D)	Scale applied to icon, if used; defaults to list(1,1)" },
  grow: { type: 'generator', tooltip: "Change in scale per tick; defaults to list(0,0)" },
  rotation: { type: 'float', tooltip: "Angle of rotation (clockwise); applies only if using an icon" },
  spin: { type: 'float', tooltip: "Change in rotation per tick" },
  friction: { type: 'float', tooltip: "Amount of velocity to shed (0 to 1) per tick, also applied to acceleration from drift" },
  drift: { type: 'generator', tooltip: "Added acceleration every tick; e.g. a circle or sphere generator can be applied to produce snow or ember effects" },
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
      {particleEntryTypes[particleEntryMap[name].type] || particleEntryMap[name].type || "Not Found (This is an error)"}
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
        const tooltip = particleEntryMap[entryName].tooltip || "Oh Bees! Tooltip is missing.";
        return (
          <ParticleDataEntry
            key={entryName}
            name={entryName}
            tooltip={tooltip}
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

  const [hiddenSecret, setHiddenSecret] = useLocalState(context, 'hidden', false);
  return (
    <Window
      title="Particool"
      width={700}
      height={500}>
      <Window.Content scrollable>
        {!!hiddenSecret && (
          <NoticeBox danger> {String(Date.now())} <br />
            Particles? {hasParticles.toString()} -
            {(data.target_particle === null).toString()} <br />
            Json - {JSON.stringify(data.target_particle)}
          </NoticeBox>
        )}
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
