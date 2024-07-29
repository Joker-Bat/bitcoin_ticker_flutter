import 'package:bitcoin_ticker/services/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'coin_data.dart';
import 'package:intl/intl.dart';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  PriceScreenState createState() => PriceScreenState();
}

class PriceScreenState extends State<PriceScreen> {
  late String selectedCurrency = 'USD';
  Map<String, String> rates = {};

  DropdownMenu<String> getAndroidPicker() {
    List<DropdownMenuEntry<String>> dropdownEntries =
        currenciesList.map<DropdownMenuEntry<String>>((String value) {
      return DropdownMenuEntry(value: value, label: value);
    }).toList();

    return DropdownMenu<String>(
      initialSelection: selectedCurrency,
      menuHeight: 230,
      dropdownMenuEntries: dropdownEntries,
      onSelected: (value) {
        if (value != null) {
          selectedCurrency = value;
          getData(selectedCurrency);
        }
      },
    );
  }

  CupertinoPicker getIosPicker() {
    List<Text> dropdownEntries =
        currenciesList.map((String value) => Text(value)).toList();

    return CupertinoPicker(
      itemExtent: 40,
      scrollController: FixedExtentScrollController(
        initialItem: currenciesList.indexOf(selectedCurrency),
      ),
      onSelectedItemChanged: (selectedIndex) {
        selectedCurrency = currenciesList[selectedIndex];
        getData(selectedCurrency);
      },
      children: dropdownEntries,
    );
  }

  Widget getPicker() {
    if (Platform.isIOS) {
      return getIosPicker();
    }

    return getAndroidPicker();
  }

  @override
  void initState() {
    super.initState();
    getData(selectedCurrency);
  }

  void getData(String currency) async {
    String cryptoListUrlString = cryptoList.join(',');
    NetworkHelper networkHelper = NetworkHelper(
        'https://rest.coinapi.io/v1/exchangerate/$currency?filter_asset_id=$cryptoListUrlString&invert=True');

    var data = await networkHelper.fetchData();
    NumberFormat formatCurrency = NumberFormat.simpleCurrency(
        locale: 'en_IN', decimalDigits: 0, name: currency);

    if (data != null) {
      List<dynamic> parsedRates = data['rates'];

      Map<String, String> curRates = {};
      for (var item in parsedRates) {
        double rate = item['rate'];
        curRates[item['asset_id_quote']] =
            formatCurrency.format(rate).toString();
      }

      setState(() {
        rates = curRates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤑 Coin Ticker'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cryptoList.map<Widget>((String crypto) {
                return Card(
                  color: Colors.lightBlueAccent,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 28.0),
                    child: Text(
                      '1 $crypto = ${rates[crypto] ?? '?'} $selectedCurrency',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: getPicker(),
          ),
        ],
      ),
    );
  }
}
