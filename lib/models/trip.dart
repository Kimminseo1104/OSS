class Plan {
  final DateTime date;
  final String content;
  Plan({required this.date, required this.content});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'content': content,
  };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    date: DateTime.parse(json['date']),
    content: json['content'],
  );
}

class Diary {
  final DateTime date;
  final String content;
  Diary({required this.date, required this.content});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'content': content,
  };

  factory Diary.fromJson(Map<String, dynamic> json) => Diary(
    date: DateTime.parse(json['date']),
    content: json['content'],
  );
}

class Expense {
  final DateTime date;
  final double amountForeign;
  final double amountKRW;
  Expense({required this.date, required this.amountForeign, required this.amountKRW});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'amountForeign': amountForeign,
    'amountKRW': amountKRW,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    date: DateTime.parse(json['date']),
    amountForeign: (json['amountForeign'] as num).toDouble(),
    amountKRW: (json['amountKRW'] as num).toDouble(),
  );
}

class Trip {
  final String title;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  List<Plan> plans;
  List<Diary> diaries;
  List<Expense> expenses;

  Trip({
    required this.title,
    required this.country,
    required this.startDate,
    required this.endDate,
    this.plans = const [],
    this.diaries = const [],
    this.expenses = const [],
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'country': country,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'plans': plans.map((p) => p.toJson()).toList(),
    'diaries': diaries.map((d) => d.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    title: json['title'],
    country: json['country'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    plans: (json['plans'] as List? ?? []).map((p) => Plan.fromJson(p)).toList(),
    diaries: (json['diaries'] as List? ?? []).map((d) => Diary.fromJson(d)).toList(),
    expenses: (json['expenses'] as List? ?? []).map((e) => Expense.fromJson(e)).toList(),
  );
}
