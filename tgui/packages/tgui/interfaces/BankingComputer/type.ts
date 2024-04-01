/**
* @file
* @copyright 2024
* @author mloccy (https://github.com/mloccy)
* @license MIT
*/

import { SortDirection } from "../PlayerPanel/constant";

export enum TabState {
  BudgetStatus,
  PayrollDetails,
  CrewAccounts
}

export enum SearchFilter {
  Name = "Name",
  Job = "Job"
}

export enum ColumnSortField {
  Name,
  Job,
  Salary,
  Balance
}

export type CrewColumnSortConfig = {
  dir: SortDirection,
  field: ColumnSortField
}

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
  cardInserted: boolean,
  cardName: string,
  isSiliconUser: boolean,
}
