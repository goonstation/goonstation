/**
 * @file
 * @copyright 2024
 * @author mloccy (https://github.com/mloccy)
 * @license MIT
 */
export const CREDIT_SIGN = "⪽";

export type Transfer = {
  fromId: string,
  fromType: string,

  toId: string,
  toType: string,
}

export type Budget = {
  name: string,
  amount: number
}

export type CrewAccount = {
  id: string
  name: string,
  job: string,
  wage: number,
  balance: number
  frozen: boolean
}

export type PayrollData = {
  stipend: number,
  cost: number,
  surplus: number,
  total: number
}

export interface BankComputerStatus {
  budgets: Budget[],
  accounts: CrewAccount[],

  payroll: PayrollData,
  payrollActive: boolean,

  authenticated: boolean,
  failedLogin: boolean,
  loggedInName: string,

  cardInserted: boolean,
  cardName: string,
}
