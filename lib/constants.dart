class Constants {
  static const String PRIVATE_KEY_STRING = "PRIVATE_KEY_STRING";
  static const String PUBLIC_KEY_STRING = "PUBLIC_KEY_STRING";
  static const String USER_ACCOUNT_ID = "USER_ACCOUNT_ID";

  //TODO replace with your own contract id and urls
  static const String WALLET_LOGIN_URL =
      'https://wallet.testnet.near.org/login/?';
  static const String WALLET_SIGN_URL =
      'https://wallet.testnet.near.org/sign/?';
  static const String CONTRACT_ID = 'goodfaith.testnet';
  static const String WEB_SUCCESS_URL =
      'https://near-transaction-serializer.herokuapp.com/success';
  static const String WEB_FAILURE_URL =
      'https://near-transaction-serializer.herokuapp.com/failure';
  static const APP_TITLE = 'Good faith';
  static const DEFAULT_GAS_FEES = 30000000000000;
}
