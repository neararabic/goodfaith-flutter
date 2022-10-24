import { u128 } from "near-sdk-as";

@nearBindgen
export class Request {
  id: string;
  borrower: string;
  lender: string;
  desc: string;
  paybackTimestamp: u64;
  amount: u128;

  constructor(
    id: string,
    borrower: string,
    lender: string,
    desc: string,
    paybackTimestamp: u64,
    amount: u128
  ) {
    this.id = id;
    this.borrower = borrower;
    this.lender = lender;
    this.desc = desc;
    this.paybackTimestamp = paybackTimestamp;
    this.amount = amount;
  }
}