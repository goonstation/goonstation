/**
 * @file
 * @copyright 2021 Gomble (https://github.com/AndrewL97)
 * @author Original Gomble (https://github.com/AndrewL97)
 * @author Changes Azrun
 * @author Changes Sovexe (https://github.com/Sovexe)
 * @author Changes ZeWaka (https://github.com/ZeWaka)
 * @author Changes Mordent (https://github.com/mordent-goonstation)
 * @license MIT
 */

import { numberOfDecimalDigits } from 'common/math';
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  ColorBox,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Tooltip,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';

interface ParticoolData {
  target_particle;
}

interface ParticleIntegerEntryProps {
  name;
  tooltip;
  value;
}

const ParticleIntegerEntry = (props: ParticleIntegerEntryProps) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <NumberInput
        value={value}
        stepPixelSize={5}
        width="39px"
        onDrag={(value) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'int',
            },
          })
        }
        step={1}
        maxValue={Infinity}
        minValue={-Infinity}
      />
    </Tooltip>
  );
};

interface ParticleMatrixEntryProps {
  name;
  tooltip;
  value;
}

const ParticleMatrixEntry = (props: ParticleMatrixEntryProps) => {
  let { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();

  // Actual matrix, or matrix of 0
  value = value || [1, 0, 0, 1, 0, 0]; // this doesn't make sense, it should be [1, 0, 0, 0, 1, 0] but it's not
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Flex>
        <Flex.Item>
          {value.map((val, i) => (
            <NumberInput
              value={val}
              key={i}
              maxValue={Infinity}
              minValue={-Infinity}
              step={1}
              onDrag={(v) => {
                value[i] = v;
                act('modify_particle_value', {
                  new_data: {
                    name: name,
                    value: value,
                    type: 'matrix',
                  },
                });
              }}
            />
          ))}
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

interface ParticleFloatEntryProps {
  name;
  particleFloatStep;
  tooltip;
  value;
}

const ParticleFloatEntry = (props: ParticleFloatEntryProps) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();
  let entry: React.JSX.Element | null = null;
  let isGen = typeof value === 'string';
  if (isGen) {
    entry = <ParticleGeneratorEntry {...props} />;
  } else {
    entry = <ParticleFloatNonGenEntry {...props} />;
  }
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Flex>
        <Flex.Item>{entry}</Flex.Item>
        <Flex.Item align="right">
          <Button.Checkbox
            checked={isGen}
            onClick={() =>
              act('modify_particle_value', {
                new_data: {
                  name: name,
                  value: isGen
                    ? 0
                    : {
                        genType: 'num',
                        a: value,
                        b: value,
                        rand: 'UNIFORM_RAND',
                      },
                  type: isGen ? 'float' : 'generator',
                },
              })
            }
          >
            Generator
          </Button.Checkbox>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

interface ParticleFloatNonGenEntryProps {
  name;
  particleFloatStep: number;
  tooltip;
  value;
}

const ParticleFloatNonGenEntry = (props: ParticleFloatNonGenEntryProps) => {
  const { value, tooltip, name, particleFloatStep } = props;
  const { act } = useBackend<ParticoolData>();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <NumberInput
        value={value ?? 0}
        stepPixelSize={4}
        step={particleFloatStep}
        maxValue={Infinity}
        minValue={-Infinity}
        format={(value) =>
          toFixed(value, numberOfDecimalDigits(particleFloatStep))
        }
        width="80px"
        onDrag={(value) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'float',
            },
          })
        }
      />
    </Tooltip>
  );
};

interface ParticleVectorEntryProps {
  name;
  tooltip;
  value;
}

const ParticleVectorEntry = (props: ParticleVectorEntryProps) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();
  let entry: React.JSX.Element | null = null;
  let isGen = typeof value === 'string';
  if (isGen) {
    entry = <ParticleGeneratorEntry {...props} />;
  } else {
    entry = <ParticleVectorNonGenEntry {...props} />;
  }
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Flex>
        <Flex.Item>{entry}</Flex.Item>
        <Flex.Item align="right">
          <Button.Checkbox
            checked={isGen}
            onClick={() =>
              act('modify_particle_value', {
                new_data: {
                  name: name,
                  value: isGen
                    ? [0, 0, 0]
                    : {
                        genType: 'box',
                        a: value,
                        b: value,
                        rand: 'UNIFORM_RAND',
                      },
                  type: isGen ? 'vector' : 'generator',
                },
              })
            }
          >
            Generator
          </Button.Checkbox>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const configureParticleVectorNonGenEntryVarLen = (len: number) => {
  return (props) => {
    let { value, tooltip, name } = props;
    const { act } = useBackend<ParticoolData>();

    value = value || Array(len).fill(0);
    if (!isNaN(value)) {
      value = Array(len).fill(value);
    }
    value = value.slice(0, len);
    return (
      <Tooltip position="bottom" content={tooltip}>
        <Flex>
          <Flex.Item>
            {value.map((val, i) => (
              <NumberInput
                value={val}
                key={i}
                width="40px"
                onDrag={(v) => {
                  value[i] = v;
                  act('modify_particle_value', {
                    new_data: {
                      name: name,
                      value: value,
                      type: 'vector',
                    },
                  });
                }}
                maxValue={Infinity}
                minValue={-Infinity}
                step={1}
              />
            ))}
          </Flex.Item>
        </Flex>
      </Tooltip>
    );
  };
};

const ParticleVectorNonGenEntry = configureParticleVectorNonGenEntryVarLen(3);

const ParticleVector2Entry = (props) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();
  let entry: React.JSX.Element | null = null;
  let isGen = typeof value === 'string';
  if (isGen) {
    entry = ParticleGeneratorEntry(props);
  } else {
    entry = configureParticleVectorNonGenEntryVarLen(2)(props);
  }
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Flex>
        <Flex.Item>{entry}</Flex.Item>
        <Flex.Item align="right">
          <Button.Checkbox
            checked={isGen}
            onClick={() =>
              act('modify_particle_value', {
                new_data: {
                  name: name,
                  value: isGen
                    ? [0, 0]
                    : {
                        genType: 'box',
                        a: value,
                        b: value,
                        rand: 'UNIFORM_RAND',
                      },
                  type: isGen ? 'vector' : 'generator',
                },
              })
            }
          >
            Generator
          </Button.Checkbox>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const ParticleGeneratorEntry = (props) => {
  const { value, name } = props;
  const { act } = useBackend<ParticoolData>();
  const generatorTypes = [
    'num',
    'vector',
    'box',
    'color',
    'circle',
    'sphere',
    'square',
    'cube',
  ];
  const randTypes = [
    'UNIFORM_RAND',
    'NORMAL_RAND',
    'LINEAR_RAND',
    'SQUARE_RAND',
  ];

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
    params = params ? params : ['', '', '', ''];
    // Split into params
    params = params[1].split(', ');
    if (params.length === 4) {
      tempGenType = params[0].replace(/['"]+/g, '');

      // Try to get contents of list(), just pass value if null
      let aTemp = params[1].match(/\((.*)\)/);
      tempA = aTemp ? aTemp[1] : params[1].replace(/['"]+/g, ''); // fermented soy beans

      let bTemp = params[2].match(/\((.*)\)/);
      tempB = bTemp ? bTemp[1] : params[2].replace(/['"]+/g, '');

      tempRand = params[3];
    }
  }

  const [genType, setGenType] = useState(tempGenType);
  const [a, setA] = useState(tempA);
  const [b, setB] = useState(tempB);
  const [rand, setRand] = useState(tempRand);

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
    });
  };

  return (
    <Collapsible title="Generator Settings - Hit Set to save">
      <Section>
        <LabeledList>
          <LabeledList.Item label="type">
            <Tooltip position="bottom" content={`${generatorTypes.join(', ')}`}>
              <Input value={genType} onChange={(val) => setGenType(val)} />
            </Tooltip>
          </LabeledList.Item>
          <LabeledList.Item label="A">
            <Input value={a} onChange={(val) => setA(val)} />
          </LabeledList.Item>
          <LabeledList.Item label="B">
            <Input value={b} onChange={(val) => setB(val)} />
          </LabeledList.Item>
          <LabeledList.Item label="Rand Type">
            <Tooltip position="bottom" content={`${randTypes.join(', ')}`}>
              <Input value={rand} onChange={(val) => setRand(val)} />
            </Tooltip>
          </LabeledList.Item>
        </LabeledList>
        <Button onClick={() => doAct()}>Set</Button>
      </Section>
    </Collapsible>
  );
};

const ParticleTextEntry = (props) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();

  return (
    <Tooltip position="bottom" content={tooltip}>
      <Input
        value={value}
        width="250px"
        onChange={(value) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'text',
            },
          })
        }
      />
    </Tooltip>
  );
};

const ParticleNumListEntry = (props) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();

  let valArr = value ? Object.keys(value).map((key) => value[key]) : [];

  return (
    <Tooltip position="bottom" content={tooltip}>
      <Input
        value={valArr.join(',')}
        width="250px"
        onChange={(val) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: val,
              type: 'numList',
            },
          })
        }
      />
    </Tooltip>
  );
};

const ParticleListEntry = (props) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();

  let valArr = value ? Object.keys(value).map((key) => value[key]) : [];

  return (
    <Tooltip position="bottom" content={tooltip}>
      <Input
        value={valArr.join(',')}
        width="250px"
        onChange={(val) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: val,
              type: 'list',
            },
          })
        }
      />
    </Tooltip>
  );
};

const ParticleColorNonGenEntry = (props) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button icon="pencil-alt" onClick={() => act('modify_color_value')} />
      <ColorBox color={value} mr={0.5} />
      <Input
        value={value}
        width="90px"
        onChange={(value) =>
          act('modify_particle_value', {
            new_data: {
              name: name,
              value: value,
              type: 'color',
            },
          })
        }
      />
    </Tooltip>
  );
};

const ParticleColorEntry = (props) => {
  const { value, tooltip, name } = props;
  const { act } = useBackend<ParticoolData>();
  let entry: React.JSX.Element | null = null;
  let isGen = typeof value === 'string' && value.charAt(0) !== '#';
  if (isGen) {
    entry = ParticleGeneratorEntry(props);
  } else {
    entry = ParticleColorNonGenEntry(props);
  }
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Flex>
        <Flex.Item>{entry}</Flex.Item>
        <Flex.Item align="right">
          <Button.Checkbox
            checked={isGen}
            onClick={() =>
              act('modify_particle_value', {
                new_data: {
                  name: name,
                  value: isGen
                    ? '#ffffff'
                    : {
                        genType: 'color',
                        a: value,
                        b: value,
                        rand: 'UNIFORM_RAND',
                      },
                  type: isGen ? 'color' : 'generator',
                },
              })
            }
          >
            Generator
          </Button.Checkbox>
        </Flex.Item>
      </Flex>
    </Tooltip>
  );
};

const ParticleIconEntry = (props) => {
  const { value, tooltip } = props;
  const { act } = useBackend<ParticoolData>();
  return (
    <Tooltip position="bottom" content={tooltip}>
      <Button icon="pencil-alt" onClick={() => act('modify_icon_value')} />
      <Box inline ml={1}>
        {value}
      </Box>
    </Tooltip>
  );
};

const particleEntryMap = {
  width: { type: 'float_nongen', tooltip: 'Width of particle image in pixels' },
  height: {
    type: 'float_nongen',
    tooltip: 'Height of particle image in pixels',
  },
  count: { type: 'int', tooltip: 'Maximum particle count' },
  spawning: {
    type: 'float_nongen',
    tooltip: 'Number of particles to spawn per tick (can be fractional)',
  },
  bound1: {
    type: 'vector_nongen',
    tooltip: 'Minimum particle position in x,y,z space',
  },
  bound2: {
    type: 'vector_nongen',
    tooltip: 'Maximum particle position in x,y,z space',
  },
  gravity: {
    type: 'vector_nongen',
    tooltip:
      'Constant acceleration applied to all particles in this set (pixels per squared tick)',
  },
  gradient: { type: 'list', tooltip: 'Color gradient used, if any' },
  transform: {
    type: 'matrix',
    tooltip: 'Transform done to all particles, if any (can be higher than 2D)',
  },
  lifespan: {
    type: 'float',
    tooltip: 'Maximum life of the particle, in ticks',
  },
  fade: {
    type: 'float',
    tooltip: 'Fade-out time at end of lifespan, in ticks',
  },
  fadein: { type: 'float', tooltip: 'Fade-in time, in ticks' },
  icon: {
    type: 'icon',
    tooltip: 'Icon to use, if any; no icon means this particle will be a dot',
  },
  icon_state: { type: 'list', tooltip: 'Icon state to use, if any' },
  color: {
    type: 'color',
    tooltip: 'Particle color; can be a number if a gradient is used',
  },
  color_change: {
    type: 'float',
    tooltip: 'Color change per tick; only applies if gradient is used',
  },
  position: {
    type: 'vector',
    tooltip: 'x,y,z position, from center in pixels',
  },
  velocity: { type: 'vector', tooltip: 'x,y,z velocity, in pixels' },
  scale: {
    type: 'vector2',
    tooltip: '(2D)	Scale applied to icon, if used; defaults to list(1,1)',
  },
  grow: {
    type: 'vector2',
    tooltip: 'Change in scale per tick; defaults to list(0,0)',
  },
  rotation: {
    type: 'float',
    tooltip: 'Angle of rotation (clockwise); applies only if using an icon',
  },
  spin: { type: 'float', tooltip: 'Change in rotation per tick' },
  friction: {
    type: 'float',
    tooltip:
      'Amount of velocity to shed (0 to 1) per tick, also applied to acceleration from drift',
  },
  drift: {
    type: 'vector',
    tooltip:
      'Added acceleration every tick; e.g. a circle or sphere generator can be applied to produce snow or ember effects',
  },
};

interface ParticleDataEntryProps {
  name;
  particleFloatStep;
  tooltip;
  value;
}

const ParticleDataEntry = (props: ParticleDataEntryProps) => {
  const { name } = props;

  const particleEntryTypes = {
    int: <ParticleIntegerEntry {...props} />,
    float: <ParticleFloatEntry {...props} />,
    float_nongen: <ParticleFloatNonGenEntry {...props} />,
    string: <ParticleTextEntry {...props} />,
    numlist: <ParticleNumListEntry {...props} />,
    list: <ParticleListEntry {...props} />,
    color: <ParticleColorEntry {...props} />,
    icon: <ParticleIconEntry {...props} />,
    generator: <ParticleGeneratorEntry {...props} />,
    matrix: <ParticleMatrixEntry {...props} />,
    vector: <ParticleVectorEntry {...props} />,
    vector_nongen: <ParticleVectorNonGenEntry {...props} />,
    vector2: <ParticleVector2Entry {...props} />,
  };

  return (
    <LabeledList.Item label={name}>
      {particleEntryTypes[particleEntryMap[name].type] ||
        particleEntryMap[name].type ||
        'Not Found (This is an error)'}
    </LabeledList.Item>
  );
};

interface ParticleEntryProps {
  particle;
  particleFloatStep;
}

const ParticleEntry = (props: ParticleEntryProps) => {
  const { particle, particleFloatStep } = props;
  return (
    <LabeledList>
      {Object.keys(particleEntryMap).map((entryName) => {
        const value = particle[entryName];
        const tooltip =
          particleEntryMap[entryName].tooltip || 'Oh Bees! Tooltip is missing.';
        return (
          <ParticleDataEntry
            key={entryName}
            name={entryName}
            tooltip={tooltip}
            value={value}
            particleFloatStep={particleFloatStep}
          />
        );
      })}
    </LabeledList>
  );
};

const GeneratorHelp = () => {
  return (
    <Collapsible title="Generator Help">
      <Section>
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
              <td>
                A random vector within a box whose corners are at A and B.
              </td>
            </tr>
            <tr>
              <td>color</td>
              <td>color (string) or color matrix</td>
              <td>
                Result type depends on whether A or B are matrices or not. The
                result is interpolated between A and B; components are not
                randomized separately.
              </td>
            </tr>
            <tr>
              <td>circle</td>
              <td>vector</td>
              <td>
                A random XY-only vector in a ring between radius A and B,
                centered at 0,0.
              </td>
            </tr>
            <tr>
              <td>sphere</td>
              <td>vector</td>
              <td>
                A random vector in a spherical shell between radius A and B,
                centered at 0,0,0.
              </td>
            </tr>
            <tr>
              <td>square</td>
              <td>vector</td>
              <td>
                A random XY-only vector between squares of sizes A and B. (The
                length of the square is between A*2 and B*2, centered at 0,0.)
              </td>
            </tr>
            <tr>
              <td>cube</td>
              <td>vector</td>
              <td>
                A random vector between cubes of sizes A and B. (The length of
                the cube is between A*2 and B*2, centered at 0,0,0.)
              </td>
            </tr>
          </tbody>
        </table>
      </Section>
    </Collapsible>
  );
};

export const Particool = () => {
  const { act, data } = useBackend<ParticoolData>();
  const particles = data.target_particle || {};
  const hasParticles = particles && Object.keys(particles).length > 0;
  const [particleFloatStep, setParticleFloatStep] = useState(0.01);

  const [hiddenSecret, setHiddenSecret] = useState(false);
  return (
    <Window title="Particool" width={700} height={500}>
      <Window.Content scrollable>
        {!!hiddenSecret && (
          <NoticeBox danger>
            {String(Date.now())} <br />
            Particles? {hasParticles.toString()} -
            {(data.target_particle === null).toString()} <br />
            Json - {JSON.stringify(data.target_particle)}
          </NoticeBox>
        )}
        <Section
          title={
            <Box inline onDoubleClick={() => setHiddenSecret(true)}>
              Particle
            </Box>
          }
          buttons={
            <>
              {!!hasParticles && (
                <>
                  <Button icon="save" onClick={() => act('save_particle')}>
                    Save Particle
                  </Button>
                  <Button
                    icon="file-image"
                    onClick={() => act('save_particle_with_icon')}
                  >
                    Save Particle + Icon
                  </Button>
                </>
              )}
              <Button icon="upload" onClick={() => act('load_particle')}>
                Load Particle
              </Button>
              {!hasParticles ? (
                <Button icon="plus" onClick={() => act('add_particle')}>
                  Add Particle
                </Button>
              ) : (
                <Button.Confirm
                  icon="minus"
                  onClick={() => act('remove_particle')}
                >
                  Remove Particle
                </Button.Confirm>
              )}
            </>
          }
        >
          <GeneratorHelp />
          <Box mt={2} mb={2}>
            <Box inline mr={1}>
              Float change step:
            </Box>
            <NumberInput
              value={particleFloatStep}
              step={0.001}
              format={(value) =>
                toFixed(value, numberOfDecimalDigits(particleFloatStep))
              }
              width="70px"
              maxValue={Infinity}
              minValue={-Infinity}
              onChange={(value) => setParticleFloatStep(value)}
            />
          </Box>
          {!hasParticles ? (
            <Box>No particle</Box>
          ) : (
            <ParticleEntry
              particle={particles}
              particleFloatStep={particleFloatStep}
            />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
