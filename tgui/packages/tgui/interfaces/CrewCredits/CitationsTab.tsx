/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Fragment } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Section } from '../../components';
import { CitationTabData, CitationTargetData, CitationTargetListProps } from './type';

export const CitationsTab = (props, context) => {
  const { data } = useBackend<CitationTabData>(context);
  const { tickets, fines } = data;
  return (
    <Fragment>
      <CitationTargetList title="Tickets" citation_targets={tickets} />
      <CitationTargetList title="Fines" citation_targets={fines} />
    </Fragment>
  );
};

const CitationTargetList = (props: CitationTargetListProps) => {
  const { title, citation_targets } = props;
  return (
    <Section title={title}>
      {!citation_targets && <Box>No {title.toLowerCase()} were issued!</Box>}
      {
        !!citation_targets && citation_targets.length && citation_targets.map((target) => {
          return (
            <CitationList key={target.name} {...target} />
          );
        })
      }
    </Section>
  );
};

const CitationList = (props: CitationTargetData) => {
  const { name, citations } = props;
  return (
    <Section title={name}>
      {!!citations && citations.length && citations.map((citation, index) => {
        return (
          <Box
            mb={2}
            key={index}
            dangerouslySetInnerHTML={{ __html: citation }}
          />
        );
      })}
    </Section>
  );
};
