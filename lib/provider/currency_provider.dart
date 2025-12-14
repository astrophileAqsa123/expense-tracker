import 'package:flutter/material.dart';

class CurrencyProvider extends ChangeNotifier {
  // DEFAULT = Rs
  String _currencySymbol = 'Rs';
  String _currencyLabel = 'PKR (Rs)';

  String get symbol => _currencySymbol;
  String get label => _currencyLabel;

  void setCurrency(String currency) {
    _currencyLabel = currency;

    if (currency.contains('USD')) _currencySymbol = '\$';
    else if (currency.contains('EUR')) _currencySymbol = '€';
    else if (currency.contains('GBP')) _currencySymbol = '£';
    else if (currency.contains('INR')) _currencySymbol = '₹';
    else if (currency.contains('PKR')) _currencySymbol = 'Rs';

    notifyListeners();
  }
}
