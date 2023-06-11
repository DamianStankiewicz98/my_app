import 'side_menu.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterView extends StatefulWidget {
  @override
  _CurrencyConverterViewState createState() => _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends State<CurrencyConverterView> {
  final String apiUrl = 'https://open.exchangerate-api.com/v6/latest';
  Map<String, dynamic> exchangeRates = {};
  String selectedCurrencyFrom = 'PLN';
  String selectedCurrencyTo = 'EUR';
  double amount = 0.0;
  double convertedAmount = 0.0;
  TextEditingController amountController = TextEditingController();

  Future<void> fetchExchangeRates() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        exchangeRates = data['rates'];
      });
    } else {
      throw Exception('Failed to fetch exchange rates');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  void convertCurrency() {
    double rateFrom = double.parse(exchangeRates[selectedCurrencyFrom].toString());
    double rateTo = double.parse(exchangeRates[selectedCurrencyTo].toString());
    double amountValue = double.parse(amount.toString());
    setState(() {
      convertedAmount = (amountValue / rateFrom) * rateTo;
    });
  }

  void swapCurrencies() {
    setState(() {
      String tempCurrency = selectedCurrencyFrom;
      selectedCurrencyFrom = selectedCurrencyTo;
      selectedCurrencyTo = tempCurrency;
      amount = 0.0;
      convertedAmount = 0.0;
      amountController.clear(); // Clear the amount field
    });
  }

  @override
  Widget build(BuildContext context) {

    String formattedExchangeRate = '';

    if (exchangeRates.containsKey(selectedCurrencyFrom) && exchangeRates.containsKey(selectedCurrencyTo)) {
      double rateFrom = double.tryParse(exchangeRates[selectedCurrencyFrom].toString()) ?? 1.0;
      double rateTo = double.tryParse(exchangeRates[selectedCurrencyTo].toString()) ?? 1.0;
      num exchangeRate = (1 / rateFrom) * rateTo;
      formattedExchangeRate = exchangeRate.toStringAsFixed(4);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Przelicznik walut'),
      ),
      drawer: SideMenu(
        selectedMenuItem: '',
        onMenuItemSelected: (String item) {},
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400.0),
                  child: Text(
                    'Zamiana ${amount.toStringAsFixed(2)} $selectedCurrencyFrom na $selectedCurrencyTo',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400.0),
                  child: Text(
                    'Aktualny kurs: 1 $selectedCurrencyFrom = $formattedExchangeRate $selectedCurrencyTo',
                    style: TextStyle(fontSize: 18.0),
                  ),
              ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400.0),
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ilość',
                    ),
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 0.0;
                        convertedAmount = 0.0; // Reset converted amount
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedCurrencyFrom,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCurrencyFrom = newValue!;
                        convertedAmount = 0.0; // Reset converted amount
                      });
                    },
                    items: exchangeRates.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 10.0),
                  IconButton(
                    icon: Icon(Icons.swap_horiz),
                    onPressed: swapCurrencies,
                  ),
                  SizedBox(width: 10.0),
                  DropdownButton<String>(
                    value: selectedCurrencyTo,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCurrencyTo = newValue!;
                        convertedAmount = 0.0; // Reset converted amount
                      });
                    },
                    items: exchangeRates.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: convertCurrency,
                child: Text('Przelicz'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Wynik: ${convertedAmount.toStringAsFixed(4)} $selectedCurrencyTo',
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}