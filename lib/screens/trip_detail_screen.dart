import 'package:flutter/material.dart';
import '../models/trip.dart';
import 'plan_add_screen.dart';
import 'diary_add_screen.dart';
import 'expense_add_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({required this.trip, Key? key}) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip trip;

  @override
  void initState() {
    super.initState();
    trip = Trip(
      title: widget.trip.title,
      country: widget.trip.country,
      startDate: widget.trip.startDate,
      endDate: widget.trip.endDate,
      plans: List.from(widget.trip.plans),
      diaries: List.from(widget.trip.diaries),
      expenses: List.from(widget.trip.expenses),
    );
  }

  @override
  void dispose() {
    Navigator.pop(context, trip);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, trip);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(trip.title),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('계획', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...trip.plans.map((plan) => Card(
                child: ListTile(
                  title: Text('${plan.date.year}-${plan.date.month.toString().padLeft(2, '0')}-${plan.date.day.toString().padLeft(2, '0')}'),
                  subtitle: Text(plan.content),
                ),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.add),
                  tooltip: '계획 작성',
                  onPressed: () async {
                    final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PlanAddScreen(trip: trip)),
                    );
                    if (result != null && result is Plan) {
                      setState(() {
                        trip.plans = List.from(trip.plans)..add(result);
                      });
                    }
                  },
                ),
              ),
              Divider(),
              Text('일기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...trip.diaries.map((diary) => Card(
                child: ListTile(
                  title: Text('${diary.date.year}-${diary.date.month.toString().padLeft(2, '0')}-${diary.date.day.toString().padLeft(2, '0')}'),
                  subtitle: Text(diary.content),
                ),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.add),
                  tooltip: '일기 작성',
                  onPressed: () async {
                    final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DiaryAddScreen(trip: trip)),
                    );
                    if (result != null && result is Diary) {
                      setState(() {
                        trip.diaries = List.from(trip.diaries)..add(result);
                      });
                    }
                  },
                ),
              ),
              Divider(),
              Text('경비', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...trip.expenses.map((exp) => Card(
                child: ListTile(
                  title: Text('${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}-${exp.date.day.toString().padLeft(2, '0')}'),
                  subtitle: Text('외화: ${exp.amountForeign}, KRW: ${exp.amountKRW.toStringAsFixed(0)}'),
                ),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.add),
                  tooltip: '경비 작성',
                  onPressed: () async {
                    final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ExpenseAddScreen(trip: trip)),
                    );
                    if (result != null && result is Expense) {
                      setState(() {
                        trip.expenses = List.from(trip.expenses)..add(result);
                      });
                    }
                  },
                ),
              ),
              Divider(),
              SizedBox(height: 20),
              Text('총 사용 금액: ${trip.expenses.fold(0.0, (prev, e) => prev + e.amountKRW).toStringAsFixed(0)}원',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
