class Request {
  String id = '';
  String borrower = '';
  String lender = '';
  String desc = '';
  num paybackTimestamp = 0;
  BigInt amount = BigInt.zero;

  Request(
      {required this.borrower,
      required this.lender,
      required this.desc,
      required this.paybackTimestamp,
      required this.amount});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    borrower = json['borrower'];
    lender = json['lender'];
    desc = json['desc'];
    paybackTimestamp = json['paybackTimestamp'];
    amount = json['amount'];
  }

  String yoctoToNear(String yocto) {
    if (yocto == '0') {
      return yocto;
    } else {
      double parsed = double.parse(yocto);
      double oneNear = 1000000000000000000000000.0;
      return (parsed / oneNear).toStringAsFixed(3);
    }
  }
}
