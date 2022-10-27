import { context, ContractPromiseBatch, PersistentMap, PersistentSet } from "near-sdk-as";
import { Request } from "./models";

@nearBindgen
export class Contract {

  requests: PersistentMap<string, Request> = new PersistentMap<string, Request>("requests");
  unfulfilledRequestIds: PersistentSet<string> = new PersistentSet<string>("unfulfilledRequestIds");
  fulfilledRequestIds: PersistentSet<string> = new PersistentSet<string>("fulfilledRequestIds");
  payedbackRequestIds: PersistentSet<string> = new PersistentSet<string>("payedbackRequestIds");

  @mutateState()
  postBorrowRequest(request: Request): Request {
    assert(request.paybackTimestamp > context.blockTimestamp, 'Payback time is in the past!');
    assert(request.lender != context.predecessor, 'Cannot borrow from yourself!');
    request.borrower = context.predecessor;
    request.id = context.predecessor + '_' + context.blockTimestamp.toString();
    this.requests.set(request.id, request);
    this.unfulfilledRequestIds.add(request.id);
    return request;
  }

  @mutateState()
  lend(requestId: string): Request {
    var request: Request = this.requests.getSome(requestId);
    assert(context.attachedDeposit == request.amount, "Attached deposit not equal to request amount!");
    ContractPromiseBatch.create(request.borrower).transfer(request.amount);
    this.unfulfilledRequestIds.delete(request.id);
    this.fulfilledRequestIds.add(request.id);
    return request;
  }

  @mutateState()
  payback(requestId: string): Request {
    var request: Request = this.requests.getSome(requestId);
    assert(context.attachedDeposit == request.amount, "Attached deposit not equal to request amount!");
    ContractPromiseBatch.create(request.lender).transfer(request.amount);
    this.fulfilledRequestIds.delete(request.id);
    this.payedbackRequestIds.add(request.id);
    return request;
  }

  getUnfulfilledRequests(): Array<Request> {
    var requests: Array<Request> = new Array<Request>();
    var unfulfilledRequestIds: string[] = this.unfulfilledRequestIds.values();
    for (let i = 0; i < unfulfilledRequestIds.length; i++) {
      requests.push(this.requests.getSome(unfulfilledRequestIds[i]));
    }
    return requests;
  }

  getAccountFulfilledRequests(accountId: string): Array<Request> {
    var requests: Array<Request> = new Array<Request>();
    var fulfilledRequestIds: string[] = this.fulfilledRequestIds.values();
    for (let i = 0; i < fulfilledRequestIds.length; i++) {
      var request = this.requests.getSome(fulfilledRequestIds[i]);
      if (request.borrower == accountId || request.lender == accountId) {
        requests.push(request);
      }
    }
    return requests;
  }
}