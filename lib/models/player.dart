class Request {
  String id = '';
  String borrower = '';
  String lender = '';
  String desc = '';
  DateTime paybackDate = DateTime.now();
  String amount = '';

  Request();

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    borrower = json['borrower'];
    lender = json['lender'];
    desc = json['desc'];
    paybackDate =
        DateTime.fromMicrosecondsSinceEpoch(json['paybackTimestamp'] / 1000);
    amount = yoctoToNear(json['amount']);
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
