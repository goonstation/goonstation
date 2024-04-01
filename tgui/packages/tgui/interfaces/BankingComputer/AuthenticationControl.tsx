/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend } from "../../backend";
import { Button, Section, Stack } from "../../components";
import { BankComputerStatus } from "./type";

export const AuthenticationControl = (props, context) => {
  const { data, act } = useBackend<BankComputerStatus>(context);
  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Button
            icon="eject"
            onClick={() => act("card_insertion")}>
            {data.cardInserted ? data.cardName : "Insert Card"}
          </Button>
        </Stack.Item>
        <Stack.Item textColor={(!data.authenticated && data.cardInserted) ? "bad" : ""}>
          {(!data.authenticated && data.cardInserted) ? "Not authorized to use console" : ""}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
