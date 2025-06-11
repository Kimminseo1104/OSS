import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'trip_list_screen.dart';
import 'profile_screen.dart';

class ExchangeRateScreen extends StatefulWidget {
  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  String? selectedCountry;
  double? rate;
  bool isLoading = false;

  final Map<String, String> currencyCodes = {
    '미국': 'USD',
    '일본': 'JPY(100)',
    '유럽': 'EUR',
    '중국': 'CNH',
    '영국': 'GBP',
  };

  // 한국수출입은행 API Key (여기에 본인 키 입력)
  final String apiKey = 'v4qGHtdi8iDByvlnRRyHTKTQISFCbCyK';

  void _showCountryDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('국가 선택'),
        children: currencyCodes.keys.map((c) => SimpleDialogOption(
          child: Text(c),
          onPressed: () => Navigator.pop(ctx, c),
        )).toList(),
      ),
    );
    if (selected != null) {
      setState(() {
        selectedCountry = selected;
        rate = null;
        isLoading = true;
      });
      await _fetchExchangeRate(selected);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchExchangeRate(String country) async {
    String? code = currencyCodes[country];
    if (code == null) return;
    try {
      final url =
          'https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=$apiKey&searchdate=${_today()}&data=AP01';
      print('API 요청 URL: $url');
      final response = await http.get(Uri.parse(url));
      print('응답코드: ${response.statusCode}');
      print('응답바디: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('파싱된 데이터: $data');
        var currencyData = data.firstWhere(
              (item) => item['cur_unit'] == code,
          orElse: () => null,
        );
        print('찾은 통화 데이터: $currencyData');
        if (currencyData != null) {
          String baseRateStr = currencyData['deal_bas_r'] ?? '0';
          double baseRate = double.parse(baseRateStr.replaceAll(',', ''));
          setState(() {
            rate = baseRate;
          });
          await _saveCachedRate(country, baseRate);
        } else {
          print('API에는 있지만 통화 코드가 안맞음');
          await _loadCachedRate(country);
        }
      } else {
        print('응답이 200이 아님');
        await _loadCachedRate(country);
      }
    } catch (e) {
      print('예외 발생: $e');
      await _loadCachedRate(country);
    }
  }

  String _today() {
    final now = DateTime.now().subtract(Duration(days: 1)); // 어제로 임시 고정
    return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCachedRate(String country, double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rate_$country', rate);
    await prefs.setString('rate_date_$country', _today());
  }

  Future<void> _loadCachedRate(String country) async {
    final prefs = await SharedPreferences.getInstance();
    double? cachedRate = prefs.getDouble('rate_$country');
    setState(() {
      rate = cachedRate;
    });
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TripListScreen()),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    }
  }

  String _getCurrencyUnit(String country) {
    return currencyCodes[country] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("환율 조회")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _showCountryDialog,
              child: Text(selectedCountry == null ? '국가 선택' : '국가: $selectedCountry'),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (selectedCountry != null && rate != null)
              Text(
                '$selectedCountry 환율: 1 ${_getCurrencyUnit(selectedCountry!)} = ${rate!.toStringAsFixed(2)} KRW',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            else if (selectedCountry != null)
                Text('환율 정보를 불러올 수 없습니다. (저장된 값도 없음)', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "환율조회"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: _onTabTapped,
      ),
    );
  }
}
