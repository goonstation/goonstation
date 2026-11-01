/**
 * @file
 * @copyright 2023
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { Box, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  CitationByTargetListProps,
  CitationData,
  CitationsByTargetData,
  CitationTabData,
  isFineData,
} from './type';

export const CitationsTab = () => {
  const { data } = useBackend<CitationTabData>();
  const { tickets, fines } = data;
  return (
    <>
      <CitationByTargetList title="Tickets" citation_targets={tickets} />
      <CitationByTargetList title="Fines" citation_targets={fines} />
    </>
  );
};

const CitationByTargetList = (props: CitationByTargetListProps) => {
  const { title, citation_targets } = props;
  return (
    <Section title={title}>
      {!citation_targets?.length ? (
        <Box>No {title.toLowerCase()} were issued!</Box>
      ) : (
        citation_targets.map((target) => {
          return <CitationList key={target.name} {...target} />;
        })
      )}
    </Section>
  );
};

const CitationList = (props: CitationsByTargetData) => {
  const { name, citations } = props;
  return (
    <Section title={name}>
      {citations?.map((citation, index) => {
        return <Citation key={index} {...citation} />;
      })}
    </Section>
  );
};

const Citation = (props: CitationData) => {
  const { reason, issuer, issuer_job } = props;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Cited by">
          {issuer}, {issuer_job}
        </LabeledList.Item>
        <LabeledList.Item label="Reason">{reason}</LabeledList.Item>

        {isFineData(props) && (
          <>
            <LabeledList.Item
              label="Approved by"
              color={!props.approver ? 'bad' : 'neutral'}
            >
              {props.approver && (
                <>
                  {props.approver}, {props.approver_job}
                </>
              )}
              {!props.approver && 'Not Approved'}
            </LabeledList.Item>
            <LabeledList.Item label="Amount">
              {props.amount}⪽&nbsp;
              {props.approver && !props.paid && (
                <>(Unpaid: {props.amount - props.paid_amount}⪽ remaining)</>
              )}
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};
