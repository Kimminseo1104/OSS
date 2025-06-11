import 'package:flutter/material.dart';
import '../models/trip.dart';

class DiaryAddScreen extends StatefulWidget {
  final Trip trip;
  const DiaryAddScreen({required this.trip, Key? key}) : super(key: key);

  @override
  State<DiaryAddScreen> createState() => _DiaryAddScreenState();
}

class _DiaryAddScreenState extends State<DiaryAddScreen> {
  DateTime? selectedDate;
  String content = '';

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
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("일기 내용을 입력하세요!")),
      );
      return;
    }
    Navigator.pop(context, Diary(date: selectedDate!, content: content));
  }

  @override
  Widget build(BuildContext context) {
    final isReady = selectedDate != null && content.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('일기 작성')),
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
            Expanded(
              child: TextField(
                maxLines: null,
                minLines: 6,
                decoration: InputDecoration(labelText: '일기 내용'),
                onChanged: (v) => setState(() => content = v),
              ),
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
                  } else if (content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("일기 내용을 입력하세요!")),
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
