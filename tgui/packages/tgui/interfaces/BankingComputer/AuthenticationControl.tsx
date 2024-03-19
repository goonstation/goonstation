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
        <Stack.Item>
          <Button icon="key"
            onClick={() => act("login")}
            title={(!data.authenticated && !data.cardInserted) ? "Please insert a valid ID card to login" : ""}
            disabled={!data.cardInserted && !data.authenticated}>
            {data.authenticated ? "Log out" : "Login"}
          </Button>
        </Stack.Item>
        <Stack.Item textColor={data.failedLogin ? "red" : ""}>
          {data.authenticated ? "Currently logged in as " + data.loggedInName : ""}
          {data.failedLogin ? "Login failed" : ""}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
