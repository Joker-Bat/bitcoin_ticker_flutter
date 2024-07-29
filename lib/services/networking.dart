import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = '--- API Key Here ---';

class NetworkHelper {
  final String url;

  const NetworkHelper(this.url);

  Future<dynamic> fetchData() async {
    http.Response response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'X-CoinAPI-Key': apiKey,
    });

    if (response.statusCode == 200) {
      String data = response.body;
      var decodedData = jsonDecode(data);
      return decodedData;
    } else {
      print(response.statusCode);
    }
  }
}
