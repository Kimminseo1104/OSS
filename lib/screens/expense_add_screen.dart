import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';

class ExpenseAddScreen extends StatefulWidget {
  final Trip trip;
  const ExpenseAddScreen({required this.trip, Key? key}) : super(key: key);

  @override
  State<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends State<ExpenseAddScreen> {
  DateTime? selectedDate;
  double? amountForeign;
  double? amountKRW;
  double? rate;
  final _foreignCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  // 최신 환율을 SharedPreferences에서 불러오는 함수
  Future<void> _loadRate() async {
    final prefs = await SharedPreferences.getInstance();
    double? cachedRate = prefs.getDouble('rate_${widget.trip.country}');
    double r = cachedRate ?? _defaultRate(widget.trip.country);

    // 일본만 100으로 나눔
    if (widget.trip.country == '일본') {
      r = r / 100;
    }

    setState(() {
      rate = r;
      if (amountForeign != null && rate != null) {
        amountKRW = amountForeign! * rate!;
      }
    });
  }


  // 만약 캐시에 없을 때 사용할 기본 환율
  double _defaultRate(String country) {
    switch (country) {
      case '미국': return 1350;
      case '일본': return 9.0;
      case '유럽': return 1500;
      case '중국': return 190;
      case '영국': return 1720;
      default: return 1000;
    }
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.trip.startDate,
      firstDate: widget.trip.startDate,
      lastDate: widget.trip.endDate,
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _trySave() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("날짜를 먼저 선택하세요!")),
      );
      return;
    }
    if (amountForeign == null || amountKRW == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("금액을 입력하세요!")),
      );
      return;
    }
    Navigator.pop(
        context,
        Expense(
          date: selectedDate!,
          amountForeign: amountForeign!,
          amountKRW: amountKRW!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isReady = selectedDate != null && amountForeign != null && amountKRW != null && rate != null;

    return Scaffold(
      appBar: AppBar(title: Text('경비 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showDatePicker,
                    child: Text(
                      selectedDate == null
                          ? '날짜를 선택하세요'
                          : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate == null ? Colors.grey : Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  onPressed: _showDatePicker,
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _foreignCtrl,
              decoration: InputDecoration(
                  labelText: '외화 사용 금액', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                amountForeign = double.tryParse(v);
                if (amountForeign != null && rate != null) {
                  setState(() {
                    amountKRW = amountForeign! * rate!;
                  });
                } else {
                  setState(() {
                    amountKRW = null;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    amountKRW == null
                        ? ''
                        : 'KRW: ${amountKRW!.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  rate == null
                      ? ''
                      : '(${widget.trip.country} 환율: $rate)',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isReady ? _trySave : () {
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("날짜를 먼저 선택하세요!")),
                    );
                  } else if (amountForeign == null || amountKRW == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("금액을 입력하세요!")),
                    );
                  }
                },
                child: Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
