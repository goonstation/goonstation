/**
 * @file
 * @copyright 2021
 * @author BenLubar (https://github.com/BenLubar)
 * @license ISC
 */

import { Button, Icon } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { BioEffectDNA } from './type';

const letterColor = {
  '?': 'grey',
  A: 'red',
  T: 'blue',
  C: 'yellow',
  G: 'green',
};

const typeColor = {
  '': 'good',
  X: 'grey',
  '1': 'good',
  '2': 'olive',
  '3': 'average',
  '4': 'orange',
  '5': 'bad',
};

export const DNASequence = (props) => {
  const { act } = useBackend();
  const { gene, isPotential } = props;

  const sequence = gene.dna;
  let allGood = true;

  const blocks: BioEffectDNA[][] = [];
  for (let i = 0; i < sequence.length; i++) {
    if (i % 4 === 0) {
      blocks.push([]);
    }

    blocks[blocks.length - 1].push(sequence[i]);

    if (sequence[i].style) {
      allGood = false;
    }
  }

  const advancePair = (i) => {
    if (isPotential) {
      act('advancepair', {
        ref: gene.ref,
        pair: i,
      });
    }
  };

  return blocks.map((block, i) => (
    <table
      key={i}
      style={{
        display: 'inline-table',
        marginTop: '1em',
        marginLeft: i % 4 === 0 ? '0' : '0.25em',
        marginRight: i % 4 === 3 ? '0' : '0.25em',
      }}
    >
      <tr>
        {block.map((pair, j) => (
          <td key={j}>
            <Nucleotide
              letter={pair.pair.charAt(0)}
              type={pair.style}
              mark={pair.marker}
              useLetterColor={allGood}
              onClick={() => advancePair(i * 4 + j + 1)}
            />
          </td>
        ))}
      </tr>
      <tr>
        {block.map((pair, j) => (
          <td key={j} style={{ textAlign: 'center' }}>
            {allGood ? (
              '|'
            ) : pair.marker === 'locked' ? (
              <Icon
                name="lock"
                color="average"
                onClick={() => advancePair(i * 4 + j + 1)}
              />
            ) : (
              <Icon
                name={
                  pair.style === ''
                    ? 'check' // correct
                    : pair.style === '5'
                      ? 'times' // incorrect
                      : 'question' // changed since last analyze
                }
                color={typeColor[pair.style]}
              />
            )}
          </td>
        ))}
      </tr>
      <tr>
        {block.map((pair, j) => (
          <td key={j}>
            <Nucleotide
              letter={pair.pair.charAt(1)}
              type={pair.style}
              mark={pair.marker}
              useLetterColor={allGood}
              onClick={() => advancePair(i * 4 + j + 1)}
            />
          </td>
        ))}
      </tr>
    </table>
  ));
};

export const Nucleotide = (props) => {
  const { letter, type, mark, useLetterColor, ...rest } = props;

  const color = useLetterColor ? letterColor[letter] : typeColor[type];

  return (
    <Button width="1.75em" textAlign="center" color={color} {...rest}>
      {letter}
    </Button>
  );
};
