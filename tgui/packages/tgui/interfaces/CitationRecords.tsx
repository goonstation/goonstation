/**
 * @file
 * @copyright 2024
 * @author glowbold (https://github.com/pgmzeta)
 * @license MIT
 */

import { BooleanLike } from "common/react";
import { useBackend } from "../backend";
import { Box, Section } from "../components";
import { Window } from "../layouts";

interface CitationRecordData {
  tickets: TicketTargetData[];
  fines: FineTargetData[];
}

interface Ticket {
  reason: string;
  issuer: string;
  issuer_job: string;
}

interface TicketTargetData {
  target_name: string;
  target_tickets: Ticket[];
}

interface FineTargetData {
  target_name :string;
  target_fines: Fine[];
}

interface Fine extends Ticket {
  approver?: string;
  approver_job?: string;
  paid: BooleanLike;
  amount: number;
}

export const CitationRecords = (props, context) => {
  const { data } = useBackend<CitationRecordData>(context);
  const { tickets, fines } = data;
  return (
    <Window title="Citation Records" width={600} height={600}>
      <Window.Content scrollable>
        <Section title="Tickets">
          {
            !tickets?.length
              ? <Box>No Tickets were issued!</Box>
              : tickets.map((ticket_target) => {
                return <TicketsByTarget key={ticket_target.target_name} {...ticket_target} />;
              })
          }
        </Section>
        <Section title="Fines">
          {
            !fines?.length
              ? <Box>No Fines were issued!</Box>
              : fines.map((fine_target) => {
                return <FinesByTarget key={fine_target.target_name} {...fine_target} />;
              })
          }
        </Section>
      </Window.Content>
    </Window>
  );
};

const TicketsByTarget = (ticket_target: TicketTargetData) => {
  const { target_name, target_tickets } = ticket_target;
  return (
    <Section title={target_name}>
      {
        target_tickets.map((ticket: Ticket) => {
          return <RenderTicket key={target_name} {...ticket} />;
        })
      }
    </Section>
  );
};

const RenderTicket = (ticket: Ticket) => {
  const { reason, issuer, issuer_job } = ticket;
  return (
    <Box mb={1}>
      <Box>Reason: {reason}</Box>
      <Box>Issued by: {issuer} - {issuer_job}</Box>
    </Box>
  );
};

const FinesByTarget = (fine_target: FineTargetData) => {
  const { target_name, target_fines } = fine_target;
  return (
    <Section title={target_name}>
      {
        target_fines.map((fine: Fine) => {
          return <RenderFine key={target_name} {...fine} />;
        })
      }
    </Section>
  );
};

const RenderFine = (fine: Fine) => {
  const { reason, issuer, issuer_job, approver, approver_job, amount, paid } = fine;
  return (
    <Box mb={1}>
      <Box>Reason: {reason}</Box>
      <Box>Issued by: {issuer} - {issuer_job}</Box>
      { !approver && <Box>Not approved.</Box>}
      { !!approver && <Box>Approved by: {approver} - {approver_job}</Box>}
      <Box>Amount: {amount}⪽ ({paid ? "Paid" : "Unpaid"})</Box>
    </Box>
  );
};
