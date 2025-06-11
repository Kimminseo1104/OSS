import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/trip.dart';
import 'trip_detail_screen.dart';
import 'exchange_rate_screen.dart';
import 'profile_screen.dart';

class TripListScreen extends StatefulWidget {
  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripStrs = prefs.getStringList('trips') ?? [];
    setState(() {
      trips = tripStrs.map((str) => Trip.fromJson(json.decode(str))).toList();
    });
  }

  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripStrs = trips.map((t) => json.encode(t.toJson())).toList();
    await prefs.setStringList('trips', tripStrs);
  }

  void _addTrip(Trip trip) async {
    setState(() {
      trips.add(trip);
    });
    await _saveTrips();
  }

  void _onTabTapped(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ExchangeRateScreen()),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen()),
      );
    }
  }

  void _showAddTripDialog() async {
    String title = '';
    String? country;
    DateTime? startDate;
    DateTime? endDate;
    final countryList = ['미국', '일본', '유럽', '중국', '영국'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('여행 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: '여행 이름'),
                  onChanged: (value) => title = value,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(country == null ? '국가 선택' : '국가: $country'),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final selected = await showDialog<String>(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: Text('국가 선택'),
                            children: countryList
                                .map((c) => SimpleDialogOption(
                              child: Text(c),
                              onPressed: () => Navigator.pop(ctx, c),
                            ))
                                .toList(),
                          ),
                        );
                        if (selected != null) setState(() => country = selected);
                      },
                      child: Text('국가선택'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        startDate == null
                            ? '시작일 선택'
                            : '시작: ${_formatDate(startDate!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                            if (endDate != null && endDate!.isBefore(startDate!)) {
                              endDate = null;
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        endDate == null
                            ? '종료일 선택'
                            : '종료: ${_formatDate(endDate!)}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        if (startDate == null) return;
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate!,
                          firstDate: startDate!,
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => endDate = picked);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && country != null && startDate != null && endDate != null) {
                  Navigator.of(context).pop(
                    Trip(
                      title: title,
                      country: country!,
                      startDate: startDate!,
                      endDate: endDate!,
                      plans: [],
                      diaries: [],
                      expenses: [],
                    ),
                  );
                }
              },
              child: Text('추가'),
            ),
          ],
        ),
      ),
    ).then((result) {
      if (result != null && result is Trip) {
        _addTrip(result);
      }
    });
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddTripDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, idx) {
          final trip = trips[idx];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.card_travel),
              title: Text(trip.title),
              subtitle: Text(
                  '${trip.country}\n${_formatDate(trip.startDate)} ~ ${_formatDate(trip.endDate)}'),
              onTap: () async {
                final updatedTrip = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripDetailScreen(
                      trip: Trip(
                        title: trip.title,
                        country: trip.country,
                        startDate: trip.startDate,
                        endDate: trip.endDate,
                        plans: List.from(trip.plans),
                        diaries: List.from(trip.diaries),
                        expenses: List.from(trip.expenses),
                      ),
                    ),
                  ),
                );
                if (updatedTrip != null && updatedTrip is Trip) {
                  setState(() {
                    trips[idx] = updatedTrip;
                  });
                  await _saveTrips();
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
