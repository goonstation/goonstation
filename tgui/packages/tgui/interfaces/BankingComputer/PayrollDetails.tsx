/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */

import { useBackend } from "../../backend";
import { Button, Divider, Stack } from "../../components";
import { CREDIT_SIGN, PayrollData } from "./type";

interface PayrollDetailsProps {
  data: PayrollData,
  payrollActive: boolean
}

export const PayrollDetails = (props: PayrollDetailsProps, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack vertical>
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Payroll Stipend</Stack.Item>
          <Stack.Item>{props.data.stipend}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Payroll Cost</Stack.Item>
          <Stack.Item>{props.data.cost.toLocaleString()}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Surplus</Stack.Item>
          <Stack.Item color={props.data.surplus < 0 ? "red" : ""}>{props.data.surplus.toLocaleString()}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack align="flex-end" justify="space-between">
          <Stack.Item bold>Total Stipend</Stack.Item>
          <Stack.Item>{props.data.total.toLocaleString()}{CREDIT_SIGN}</Stack.Item>
        </Stack>
      </Stack.Item>
      <Divider />
      <Stack.Item>
        <Stack>
          <Stack.Item bold>
            Payroll Status:
          </Stack.Item>
          <Stack.Item color={props.payrollActive ? "green" : "red"}>
            {props.payrollActive ? "Active" : "Suspended"}
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={props.payrollActive ? "xmark" : "check"}
          color={props.payrollActive ? "red" : "green"}
          onClick={() => act("togglePayroll")}>
          {props.payrollActive ? "Suspend Payroll" : "Resume Payroll"}
        </Button>
      </Stack.Item>
    </Stack>
  );
};
