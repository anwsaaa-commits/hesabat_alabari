import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const navy = Color(0xFF071B2B);
const navy2 = Color(0xFF102E46);
const gold = Color(0xFFFFC857);
const sea = Color(0xFF0E7490);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.load();
  runApp(const BoatAccountsApp());
}

class BoatAccountsApp extends StatefulWidget {
  const BoatAccountsApp({super.key});
  @override
  State<BoatAccountsApp> createState() => _BoatAccountsAppState();
}

class _BoatAccountsAppState extends State<BoatAccountsApp> {
  @override
  Widget build(BuildContext context) {
    final dark = Store.isDarkMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة حسابات العبري',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: dark ? navy : const Color(0xFFF3F5F7),
        colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: dark ? Brightness.dark : Brightness.light),
        cardTheme: CardTheme(
          color: dark ? navy2 : Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: dark ? gold.withOpacity(0.18) : const Color(0xFFD5DEE5)),
          ),
        ),
        textTheme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light).textTheme.apply(
          bodyColor: dark ? Colors.white : const Color(0xFF172B3A),
          displayColor: dark ? Colors.white : const Color(0xFF172B3A),
        ),
        appBarTheme: AppBarTheme(backgroundColor: dark ? navy : Colors.white, foregroundColor: dark ? Colors.white : navy),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: dark ? navy2 : const Color(0xFFE8EDF1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dark ? const Color(0xFF31536A) : Colors.black26)),
        ),
        filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 46), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      ),
      home: DashboardPage(onThemeChanged: () => setState(() {})),
    );
  }
}

String money(num value) => NumberFormat('#,##0.##', 'en').format(value);
String dateNow() => DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

class Boat {
  String id;
  String name;
  String licenseNo;
  String licenseIssue;
  String licenseExpiry;
  double licenseCost;

  Boat({
    required this.id,
    required this.name,
    this.licenseNo = '',
    this.licenseIssue = '',
    this.licenseExpiry = '',
    this.licenseCost = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'licenseNo': licenseNo,
        'licenseIssue': licenseIssue,
        'licenseExpiry': licenseExpiry,
        'licenseCost': licenseCost,
      };

  factory Boat.fromJson(Map<String, dynamic> json) => Boat(
        id: json['id']?.toString() ?? newId(),
        name: json['name']?.toString() ?? 'عبري بدون اسم',
        licenseNo: json['licenseNo']?.toString() ?? '',
        licenseIssue: json['licenseIssue']?.toString() ?? '',
        licenseExpiry: json['licenseExpiry']?.toString() ?? '',
        licenseCost: (json['licenseCost'] as num? ?? 0).toDouble(),
      );
}

class Expense {
  String id;
  String boatId;
  String category;
  String item;
  String date;
  String person;
  String notes;
  double quantity;
  double unitPrice;

  Expense({
    required this.id,
    required this.boatId,
    required this.category,
    required this.item,
    required this.date,
    required this.quantity,
    required this.unitPrice,
    this.person = '',
    this.notes = '',
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'id': id,
        'boatId': boatId,
        'category': category,
        'item': item,
        'date': date,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'person': person,
        'notes': notes,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id']?.toString() ?? newId(),
        boatId: json['boatId']?.toString() ?? '',
        category: json['category']?.toString() ?? categories.first,
        item: json['item']?.toString() ?? '',
        date: json['date']?.toString() ?? dateNow(),
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
        person: json['person']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
      );
}

class Fisherman {
  String id;
  String boatId;
  String name;
  String address;
  String phone;
  double openingDebt;

  Fisherman({
    required this.id,
    required this.boatId,
    required this.name,
    this.address = '',
    this.phone = '',
    this.openingDebt = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'boatId': boatId,
        'name': name,
        'address': address,
        'phone': phone,
        'openingDebt': openingDebt,
      };

  factory Fisherman.fromJson(Map<String, dynamic> json) => Fisherman(
        id: json['id']?.toString() ?? newId(),
        boatId: json['boatId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        openingDebt: (json['openingDebt'] as num? ?? 0).toDouble(),
      );
}

class DebtEntry {
  String id;
  String boatId;
  String fishermanId;
  String date;
  String description;
  String type;
  double amount;

  DebtEntry({
    required this.id,
    required this.boatId,
    required this.fishermanId,
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'boatId': boatId,
        'fishermanId': fishermanId,
        'date': date,
        'description': description,
        'type': type,
        'amount': amount,
      };

  factory DebtEntry.fromJson(Map<String, dynamic> json) => DebtEntry(
        id: json['id']?.toString() ?? newId(),
        boatId: json['boatId']?.toString() ?? '',
        fishermanId: json['fishermanId']?.toString() ?? '',
        date: json['date']?.toString() ?? dateNow(),
        description: json['description']?.toString() ?? '',
        type: json['type']?.toString() ?? 'دين',
        amount: (json['amount'] as num? ?? 0).toDouble(),
      );
}

const categories = [
  'المواد الغذائية',
  'مستلزمات وتجهيزات العبري',
  'المشتقات النفطية',
  'الثلج والماء',
];

class Store {
  static const _boatsKey = 'boats_v1';
  static const _expensesKey = 'expenses_v1';
  static const _fishersKey = 'fishers_v1';
  static const _debtsKey = 'debts_v1';

  static List<Boat> boats = [];
  static List<Expense> expenses = [];
  static List<Fisherman> fishers = [];
  static List<DebtEntry> debts = [];
  static String email = '';
  static String activeBoatId = '';
  static bool isDarkMode = true;
  static List<Map<String, dynamic>> monthlyArchives = [];
  static const _themeKey = 'app_dark_mode_v1';
  static const _monthlyArchivesKey = 'monthly_archives_v1';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    List<dynamic> readList(String key) {
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return [];
      try {
        final decoded = jsonDecode(raw);
        return decoded is List ? decoded : [];
      } catch (_) {
        return [];
      }
    }

    boats = readList(_boatsKey)
        .map((item) => Boat.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    expenses = readList(_expensesKey)
        .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    fishers = readList(_fishersKey)
        .map((item) => Fisherman.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    debts = readList(_debtsKey)
        .map((item) => DebtEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    email = prefs.getString('backup_email') ?? '';
    isDarkMode = prefs.getBool(_themeKey) ?? true;
    try {
      final archiveRaw = prefs.getString(_monthlyArchivesKey);
      final archiveDecoded = archiveRaw == null ? [] : jsonDecode(archiveRaw);
      monthlyArchives = archiveDecoded is List
          ? archiveDecoded.map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
    } catch (_) {
      monthlyArchives = [];
    }
    activeBoatId = prefs.getString('active_boat') ?? '';

    if (boats.isEmpty) {
      final firstBoat = Boat(id: newId(), name: 'العبري الأول');
      boats = [firstBoat];
      activeBoatId = firstBoat.id;
      await save();
    }

    if (!boats.any((boat) => boat.id == activeBoatId)) {
      activeBoatId = boats.first.id;
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _boatsKey,
      jsonEncode(boats.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _expensesKey,
      jsonEncode(expenses.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _fishersKey,
      jsonEncode(fishers.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      _debtsKey,
      jsonEncode(debts.map((item) => item.toJson()).toList()),
    );
    await prefs.setString('backup_email', email);
    await prefs.setString('active_boat', activeBoatId);
    await prefs.setBool(_themeKey, isDarkMode);
    await prefs.setString(_monthlyArchivesKey, jsonEncode(monthlyArchives));
  }

  static Boat get activeBoat {
    if (boats.isEmpty) {
      throw StateError('لم يتم تحميل بيانات العباري');
    }
    return boats.firstWhere(
      (boat) => boat.id == activeBoatId,
      orElse: () => boats.first,
    );
  }

  static double expenseTotal([String? boatId]) {
    return expenses
        .where((expense) => boatId == null || expense.boatId == boatId)
        .fold(0.0, (sum, expense) => sum + expense.total);
  }

  static double debtBalance(Fisherman fisherman) {
    final entries = debts.where(
      (entry) =>
          entry.fishermanId == fisherman.id &&
          entry.boatId == fisherman.boatId,
    );
    return fisherman.openingDebt +
        entries.fold(
          0.0,
          (sum, entry) =>
              sum + (entry.type == 'دين' ? entry.amount : -entry.amount),
        );
  }
}

class DashboardPage extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const DashboardPage({super.key, required this.onThemeChanged});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int tab = 0;

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _home(),
      ExpensesPage(key: ValueKey('expenses-${Store.activeBoatId}'), onChanged: refresh),
      FishermenPage(key: ValueKey('fishers-${Store.activeBoatId}'), onChanged: refresh),
      TotalsPage(key: ValueKey('totals-${Store.activeBoatId}')),
      SettingsPage(key: ValueKey('settings-${Store.activeBoatId}'), onChanged: refresh),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة حسابات العبري',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(tooltip: 'تبديل الوضع الفاتح والداكن', icon: Icon(Store.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: gold), onPressed: () async { Store.isDarkMode = !Store.isDarkMode; await Store.save(); widget.onThemeChanged(); }),
          PopupMenuButton<String>(
            icon: const Icon(Icons.directions_boat, color: gold),
            tooltip: 'تبديل العبري',
            onSelected: (id) async {
              setState(() => Store.activeBoatId = id);
              await Store.save();
              refresh();
            },
            itemBuilder: (context) => Store.boats
                .map(
                  (boat) => PopupMenuItem<String>(
                    value: boat.id,
                    child: Text(boat.name),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: navy2,
        indicatorColor: gold.withOpacity(0.18),
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: gold),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'المصروفات',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups),
            label: 'الصيادون',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'الحسابات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _home() {
    final boat = Store.activeBoat;
    final boatFishers =
        Store.fishers.where((fisher) => fisher.boatId == boat.id).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [navy2, sea]),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.directions_boat_filled, size: 48, color: gold),
              SizedBox(height: 8),
              Text(
                'إدارة حسابات العبري',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'العبري النشط: ${boat.name}',
          style: const TextStyle(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _stat(
                'إجمالي المصروفات',
                '${money(Store.expenseTotal(boat.id))} ر.ي',
                Icons.payments,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                'عدد الصيادين',
                boatFishers.toString(),
                Icons.groups,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _sectionTitle('تجهيز العبري للإبحار'),
        ...categories.map((category) {
          final total = Store.expenses
              .where(
                (expense) =>
                    expense.boatId == boat.id &&
                    expense.category == category,
              )
              .fold(0.0, (sum, expense) => sum + expense.total);

          return Card(
            color: navy2,
            child: ListTile(
              leading: const Icon(Icons.anchor, color: gold),
              title: Text(category),
              trailing: Text(
                '${money(total)} ر.ي',
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Card(
          color: navy2,
          child: ListTile(
            leading: const Icon(Icons.description, color: gold),
            title: const Text('رخصة دخول مياه الصومال'),
            subtitle: Text(
              'رقم الرخصة: ${boat.licenseNo.isEmpty ? 'غير مسجل' : boat.licenseNo}\n'
              'الانتهاء: ${boat.licenseExpiry.isEmpty ? 'غير مسجل' : boat.licenseExpiry}',
            ),
            isThreeLine: true,
            onTap: _openLicense,
          ),
        ),
        SizedBox(height: 46, child: FilledButton.icon(
          onPressed: _openLicense,
          icon: const Icon(Icons.edit_document),
          label: const Text('إدارة بيانات الرخصة'),
        )),
        const SizedBox(height: 8),
        SizedBox(height: 46, child: FilledButton.icon(
          onPressed: () => makePdfReport(),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('إنشاء تقرير PDF'),
        )),
      ],
    );
  }

  Future<void> _openLicense() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LicensePage(onChanged: refresh),
      ),
    );
    refresh();
  }

  Widget _stat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: navy2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 26),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: gold,
        ),
      ),
    );
  }
}

class ExpensesPage extends StatefulWidget {
  final VoidCallback onChanged;

  const ExpensesPage({super.key, required this.onChanged});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String category = categories.first;

  @override
  Widget build(BuildContext context) {
    final list = Store.expenses
        .where(
          (expense) =>
              expense.boatId == Store.activeBoatId &&
              expense.category == category,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final sum = list.fold(0.0, (value, expense) => value + expense.total);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        foregroundColor: navy,
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('إضافة مصروف'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'اختر القسم'),
              items: categories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => category = value ?? categories.first);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'إجمالي القسم: ${money(sum)} ر.ي',
                style: const TextStyle(
                  color: gold,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Text('لا توجد مصروفات مسجلة لهذا القسم'),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final expense = list[index];
                      return Card(
                        color: navy2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: navy,
                            child: Icon(Icons.receipt, color: gold),
                          ),
                          title: Text(
                            expense.item,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${money(expense.total)} ر.ي • ${expense.date} • الكمية ${money(expense.quantity)} × ${money(expense.unitPrice)}'
                            '${expense.person.isEmpty ? '' : '\nالمستلم: ${expense.person}'}'
                            '${expense.notes.isEmpty ? '' : '\nملاحظات: ${expense.notes}'}',
                          ),
                          isThreeLine:
                              expense.person.isNotEmpty || expense.notes.isNotEmpty,
                          trailing: SizedBox(width: 112, child: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(tooltip: 'تعديل', visualDensity: VisualDensity.compact, onPressed: () => _addExpense(existing: expense), icon: const Icon(Icons.edit, color: gold, size: 20)),
                            IconButton(tooltip: 'حذف', visualDensity: VisualDensity.compact, onPressed: () => _deleteExpense(expense), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
                          ])),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المصروف؟'),
        content: Text(expense.item),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    Store.expenses.removeWhere((item) => item.id == expense.id);
    await Store.save();
    if (!mounted) return;
    setState(() {});
    widget.onChanged();
  }

  Future<void> _addExpense({Expense? existing}) async {
    final item = TextEditingController(text: existing?.item ?? '');
    final quantity = TextEditingController(text: existing?.quantity.toString() ?? '1');
    final price = TextEditingController(text: existing?.unitPrice.toString() ?? '');
    final person = TextEditingController(text: existing?.person ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'إضافة: $category' : 'تعديل المصروف'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(item, 'الصنف / البيان', required: true),
                field(quantity, 'الكمية', required: true, number: true),
                field(price, 'سعر الوحدة', required: true, number: true),
                field(person, 'اسم المستلم أو المورد'),
                field(notes, 'ملاحظات'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, formKey.currentState!.validate());
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (existing == null) {
        Store.expenses.add(Expense(id: newId(), boatId: Store.activeBoatId, category: category, item: item.text.trim(), date: dateNow(), quantity: double.parse(quantity.text), unitPrice: double.parse(price.text), person: person.text.trim(), notes: notes.text.trim()));
      } else {
        existing.item = item.text.trim(); existing.quantity = double.parse(quantity.text); existing.unitPrice = double.parse(price.text); existing.person = person.text.trim(); existing.notes = notes.text.trim();
      }
      await Store.save();
      if (mounted) setState(() {});
      widget.onChanged();
    }

    item.dispose();
    quantity.dispose();
    price.dispose();
    person.dispose();
    notes.dispose();
  }
}

class FishermenPage extends StatefulWidget {
  final VoidCallback onChanged;

  const FishermenPage({super.key, required this.onChanged});

  @override
  State<FishermenPage> createState() => _FishermenPageState();
}

class _FishermenPageState extends State<FishermenPage> {
  @override
  Widget build(BuildContext context) {
    final list = Store.fishers
        .where((fisher) => fisher.boatId == Store.activeBoatId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        foregroundColor: navy,
        onPressed: _addFisher,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة صياد'),
      ),
      body: list.isEmpty
          ? const Center(
              child: Text('أضف أسماء الصيادين لبدء تسجيل حساباتهم'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final fisher = list[index];
                final balance = Store.debtBalance(fisher);
                return Card(
                  color: navy2,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      fisher.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${fisher.phone}\n${fisher.address}\nالمديونية: ${money(balance)} ر.ي',
                      style: TextStyle(
                        color: balance > 0
                            ? Colors.orangeAccent
                            : Colors.white70,
                      ),
                    ),
                    isThreeLine: true,
                    trailing: SizedBox(width: 104, child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(tooltip: 'تعديل الصياد', visualDensity: VisualDensity.compact, onPressed: () => _editFisher(fisher), icon: const Icon(Icons.edit, color: gold, size: 20)),
                      IconButton(tooltip: 'حذف الصياد', visualDensity: VisualDensity.compact, onPressed: () => _deleteFisher(fisher), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
                    ])),
                    onTap: () => _fisherDetails(fisher),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _editFisher(Fisherman fisher) async {
    final name = TextEditingController(text: fisher.name);
    final address = TextEditingController(text: fisher.address);
    final phone = TextEditingController(text: fisher.phone);
    final opening = TextEditingController(text: fisher.openingDebt.toString());
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('تعديل بيانات الصياد'),
      content: Form(key: key, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [field(name, 'اسم الصياد', required: true), field(address, 'العنوان'), field(phone, 'رقم الجوال'), field(opening, 'الرصيد الافتتاحي', required: true, number: true)]))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, key.currentState!.validate()), child: const Text('حفظ'))],
    ));
    if (ok == true) { fisher.name=name.text.trim(); fisher.address=address.text.trim(); fisher.phone=phone.text.trim(); fisher.openingDebt=double.parse(opening.text); await Store.save(); if (mounted) { setState(() {}); widget.onChanged(); } }
    name.dispose(); address.dispose(); phone.dispose(); opening.dispose();
  }

  Future<void> _deleteFisher(Fisherman fisher) async {
    final count = Store.debts.where((e) => e.fishermanId == fisher.id && e.boatId == fisher.boatId).length;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف الصياد؟'),
      content: Text('سيتم حذف الصياد «${fisher.name}» وسجل عملياته المالية ($count عملية). لا يمكن التراجع عن ذلك.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف الصياد'))],
    ));
    if (ok != true) return;
    Store.fishers.removeWhere((e) => e.id == fisher.id && e.boatId == fisher.boatId);
    Store.debts.removeWhere((e) => e.fishermanId == fisher.id && e.boatId == fisher.boatId);
    await Store.save(); if (mounted) { setState(() {}); widget.onChanged(); }
  }

  Future<void> _addFisher() async {
    final name = TextEditingController();
    final address = TextEditingController();
    final phone = TextEditingController();
    final openingDebt = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة صياد'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field(name, 'اسم الصياد', required: true),
                field(address, 'العنوان'),
                field(phone, 'رقم الجوال'),
                field(
                  openingDebt,
                  'الرصيد الافتتاحي للمديونية',
                  required: true,
                  number: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, formKey.currentState!.validate());
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Store.fishers.add(
        Fisherman(
          id: newId(),
          boatId: Store.activeBoatId,
          name: name.text.trim(),
          address: address.text.trim(),
          phone: phone.text.trim(),
          openingDebt: double.parse(openingDebt.text),
        ),
      );
      await Store.save();
      if (mounted) setState(() {});
      widget.onChanged();
    }

    name.dispose();
    address.dispose();
    phone.dispose();
    openingDebt.dispose();
  }

  Future<void> _fisherDetails(Fisherman fisher) async {
    final formKey = GlobalKey<FormState>();
    final amount = TextEditingController();
    final description = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(fisher.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('العنوان: ${fisher.address}'),
              Text('الجوال: ${fisher.phone}'),
              Text(
                'الرصيد الحالي: ${money(Store.debtBalance(fisher))} ر.ي',
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _fisherLedger(fisher),
              const SizedBox(height: 12),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    field(amount, 'المبلغ', required: true, number: true),
                    field(description, 'البيان'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
          FilledButton(
            onPressed: () => _saveDebt(
              dialogContext,
              fisher,
              amount,
              description,
              formKey,
              'دين',
            ),
            child: const Text('تسجيل دين'),
          ),
          FilledButton.tonal(
            onPressed: () => _saveDebt(
              dialogContext,
              fisher,
              amount,
              description,
              formKey,
              'سداد',
            ),
            child: const Text('تسجيل سداد'),
          ),
        ],
      ),
    );

    amount.dispose();
    description.dispose();
    if (mounted) setState(() {});
  }

  Widget _fisherLedger(Fisherman fisher) {
    final entries = Store.debts.where((e) => e.fishermanId == fisher.id && e.boatId == fisher.boatId).toList()..sort((a,b) => b.date.compareTo(a.date));
    final debts = entries.where((e) => e.type == 'دين').fold(0.0, (sum,e) => sum + e.amount);
    final payments = entries.where((e) => e.type == 'سداد').fold(0.0, (sum,e) => sum + e.amount);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('كشف الحساب: ديون ${money(debts)} • سداد ${money(payments)} • رصيد افتتاحي ${money(fisher.openingDebt)}', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      if (entries.isEmpty) const Text('لا توجد عمليات مسجلة بعد', style: TextStyle(color: Colors.white60)),
      ...entries.map((entry) => Card(child: ListTile(
        dense: true,
        title: Text('${entry.type}: ${money(entry.amount)} ر.ي'),
        subtitle: Text('${entry.date}\n${entry.description}'),
        isThreeLine: true,
        trailing: SizedBox(width: 88, child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(tooltip: 'تعديل العملية', visualDensity: VisualDensity.compact, onPressed: () => _editDebtEntry(entry), icon: const Icon(Icons.edit, color: gold, size: 19)),
          IconButton(tooltip: 'حذف العملية', visualDensity: VisualDensity.compact, onPressed: () => _deleteDebtEntry(entry), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 19)),
        ])),
      ))),
    ]);
  }

  Future<void> _editDebtEntry(DebtEntry entry) async {
    final amount = TextEditingController(text: entry.amount.toString());
    final description = TextEditingController(text: entry.description);
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: Text('تعديل ${entry.type}'),
      content: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [field(amount, 'المبلغ', required: true, number: true), field(description, 'البيان')])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, key.currentState!.validate()), child: const Text('حفظ'))],
    ));
    if (ok == true) { entry.amount=double.parse(amount.text); entry.description=description.text.trim(); await Store.save(); if (mounted) setState(() {}); widget.onChanged(); }
    amount.dispose(); description.dispose();
  }

  Future<void> _deleteDebtEntry(DebtEntry entry) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('حذف العملية؟'), content: Text('${entry.type}: ${money(entry.amount)} ر.ي'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف'))]));
    if (ok != true) return;
    Store.debts.removeWhere((e) => e.id == entry.id); await Store.save(); if (mounted) setState(() {}); widget.onChanged();
  }

  Future<void> _saveDebt(
    BuildContext dialogContext,
    Fisherman fisher,
    TextEditingController amount,
    TextEditingController description,
    GlobalKey<FormState> formKey,
    String type,
  ) async {
    if (!formKey.currentState!.validate()) return;

    Store.debts.add(
      DebtEntry(
        id: newId(),
        boatId: fisher.boatId,
        fishermanId: fisher.id,
        date: dateNow(),
        description: description.text.trim().isEmpty
            ? (type == 'دين' ? 'تسجيل دين' : 'سداد')
            : description.text.trim(),
        type: type,
        amount: double.parse(amount.text),
      ),
    );

    await Store.save();
    if (!mounted || !dialogContext.mounted) return;
    Navigator.pop(dialogContext);
    setState(() {});
    widget.onChanged();
  }
}

DateTime? _archiveDate(String value) {
  return DateTime.tryParse(value.trim().replaceFirst(' ', 'T'));
}

String _monthLabel(String key) {
  final parts = key.split('-');
  if (parts.length != 2) return key;
  const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];
  final month = int.tryParse(parts[1]) ?? 0;
  if (month < 1 || month > 12) return key;
  return '${months[month - 1]} ${parts[0]}';
}

Future<void> _createMonthlyArchive(BuildContext context) async {
  final selected = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    helpText: 'اختر أي تاريخ من الشهر المراد ترحيله',
    cancelText: 'إلغاء',
    confirmText: 'اختيار الشهر',
  );
  if (selected == null || !context.mounted) return;
  final monthKey = DateFormat('yyyy-MM').format(selected);
  final boatId = Store.activeBoatId;
  final existing = Store.monthlyArchives.any(
    (a) => a['month'] == monthKey && a['boatId'] == boatId,
  );
  if (existing) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم ترحيل ${_monthLabel(monthKey)} مسبقاً لهذا العبري')),
    );
    return;
  }
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('تأكيد ترحيل الكشف الشهري'),
      content: Text('سيتم حفظ كشف ${_monthLabel(monthKey)} للعبري ${Store.activeBoat.name} في الأرشيف، مع تسجيل أرصدة الصيادين المتبقية. لن تُحذف أي بيانات من سجلاتك.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ترحيل وحفظ')),
      ],
    ),
  );
  if (confirm != true) return;

  final start = DateTime(selected.year, selected.month);
  final end = DateTime(selected.year, selected.month + 1);
  bool inMonth(String value) {
    final date = _archiveDate(value);
    return date != null && !date.isBefore(start) && date.isBefore(end);
  }
  final monthExpenses = Store.expenses
      .where((e) => e.boatId == boatId && inMonth(e.date))
      .map((e) => e.toJson()).toList();
  final monthDebts = Store.debts
      .where((e) => e.boatId == boatId && inMonth(e.date))
      .map((e) => e.toJson()).toList();
  final monthFishers = Store.fishers.where((f) => f.boatId == boatId).map((f) {
    final balance = f.openingDebt + Store.debts.where((e) {
      if (e.boatId != boatId || e.fishermanId != f.id) return false;
      final date = _archiveDate(e.date);
      return date != null && date.isBefore(end);
    }).fold<double>(0, (sum, e) => sum + (e.type == 'دين' ? e.amount : -e.amount));
    return <String, dynamic>{...f.toJson(), 'closingBalance': balance};
  }).toList();

  Store.monthlyArchives.add({
    'id': newId(), 'month': monthKey, 'boatId': boatId,
    'boatName': Store.activeBoat.name, 'createdAt': dateNow(),
    'expenses': monthExpenses, 'debts': monthDebts,
    'fishers': monthFishers,
    'expenseTotal': monthExpenses.fold<double>(0, (sum, e) => sum + (((e['quantity'] as num? ?? 0) * (e['unitPrice'] as num? ?? 0)).toDouble())),
    'debtTotal': monthDebts.where((e) => e['type'] == 'دين').fold<double>(0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0)),
    'paymentTotal': monthDebts.where((e) => e['type'] == 'سداد').fold<double>(0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0)),
  });
  await Store.save();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم ترحيل وحفظ كشف ${_monthLabel(monthKey)} بنجاح')),
    );
  }
}

Future<void> _reviewMonthlyArchives(BuildContext context) async {
  final archives = Store.monthlyArchives
      .where((a) => a['boatId'] == Store.activeBoatId)
      .toList()
    ..sort((a, b) => (b['month'] ?? '').toString().compareTo((a['month'] ?? '').toString()));
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('أرشيف الكشوفات الشهرية'),
      content: SizedBox(
        width: double.maxFinite,
        child: archives.isEmpty
            ? const Text('لا توجد كشوفات مرحلة لهذا العبري حتى الآن.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: archives.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final a = archives[i];
                  final month = (a['month'] ?? '').toString();
                  final expenses = (a['expenseTotal'] as num? ?? 0).toDouble();
                  final debt = (a['debtTotal'] as num? ?? 0).toDouble();
                  final payments = (a['paymentTotal'] as num? ?? 0).toDouble();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month, color: gold),
                    title: Text(_monthLabel(month)),
                    subtitle: Text('المصروفات: ${money(expenses)} | الديون: ${money(debt)} | السداد: ${money(payments)}'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => showDialog<void>(
                      context: ctx,
                      builder: (detailCtx) {
                        final fishers = (a['fishers'] as List? ?? []);
                        final expensesList = (a['expenses'] as List? ?? []);
                        final debtsList = (a['debts'] as List? ?? []);
                        return AlertDialog(
                          title: Text('كشف ${_monthLabel(month)}'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Text('العبري: ${a['boatName'] ?? ''}'),
                                Text('تاريخ الترحيل: ${a['createdAt'] ?? ''}'),
                                const Divider(),
                                Text('إجمالي المصروفات: ${money(expenses)} ر.ي'),
                                Text('إجمالي الديون خلال الشهر: ${money(debt)} ر.ي'),
                                Text('إجمالي السداد خلال الشهر: ${money(payments)} ر.ي'),
                                const Divider(),
                                const Text('أرصدة الصيادين عند نهاية الشهر', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
                                ...fishers.map((f) => ListTile(
                                  dense: true,
                                  title: Text((f['name'] ?? '').toString()),
                                  trailing: Text('${money((f['closingBalance'] as num? ?? 0))} ر.ي'),
                                )),
                                const Divider(),
                                Text('عدد المصروفات المسجلة: ${expensesList.length}'),
                                Text('عدد عمليات الدين والسداد: ${debtsList.length}'),
                              ],
                            ),
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(detailCtx), child: const Text('إغلاق'))],
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
    ),
  );
}

class TotalsPage extends StatelessWidget {
  const TotalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final boatId = Store.activeBoatId;
    final expenses =
        Store.expenses.where((item) => item.boatId == boatId).toList();
    final fishers =
        Store.fishers.where((item) => item.boatId == boatId).toList();
    final totalDebtEntries = Store.debts.where((e) => e.boatId == boatId && e.type == 'دين').fold(0.0, (sum, e) => sum + e.amount);
    final totalPayments = Store.debts.where((e) => e.boatId == boatId && e.type == 'سداد').fold(0.0, (sum, e) => sum + e.amount);
    final openingBalances = fishers.fold(0.0, (sum, f) => sum + f.openingDebt);
    final debt = fishers.fold(0.0, (sum, fisher) => sum + Store.debtBalance(fisher));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'إجمالي الحسابات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
        ),
        const SizedBox(height: 12),
        _totalCard('إجمالي مصروفات التجهيز', Store.expenseTotal(boatId)),
        ...categories.map(
          (category) => _totalCard(
            category,
            expenses
                .where((item) => item.category == category)
                .fold(0.0, (sum, item) => sum + item.total),
          ),
        ),
        _totalCard('إجمالي الديون المسجلة', totalDebtEntries),
        _totalCard('إجمالي السداد', totalPayments),
        _totalCard('الأرصدة الافتتاحية', openingBalances),
        _totalCard('الرصيد المتبقي للصيادين', debt),
        _totalCard('المصروفات + الرصيد المتبقي', Store.expenseTotal(boatId) + debt),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => makePdfReport(),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('تصدير تقرير PDF'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _createMonthlyArchive(context),
          icon: const Icon(Icons.archive),
          label: const Text('ترحيل كشف شهر إلى الأرشيف'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _reviewMonthlyArchives(context),
          icon: const Icon(Icons.history),
          label: const Text('مراجعة الكشوفات الشهرية السابقة'),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'ملاحظة: هذا ملخص المصروفات والمديونيات المسجلة، وليس كشف أرباح أو إيرادات الصيد.',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      ],
    );
  }

  Widget _totalCard(String title, double value) {
    return Card(
      color: navy2,
      child: ListTile(
        title: Text(title),
        trailing: Text(
          '${money(value)} ر.ي',
          style: const TextStyle(
            color: gold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class LicensePage extends StatefulWidget {
  final VoidCallback onChanged;

  const LicensePage({super.key, required this.onChanged});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  late final TextEditingController licenseNo;
  late final TextEditingController issueDate;
  late final TextEditingController expiryDate;
  late final TextEditingController cost;

  @override
  void initState() {
    super.initState();
    final boat = Store.activeBoat;
    licenseNo = TextEditingController(text: boat.licenseNo);
    issueDate = TextEditingController(text: boat.licenseIssue);
    expiryDate = TextEditingController(text: boat.licenseExpiry);
    cost = TextEditingController(
      text: boat.licenseCost == 0 ? '' : boat.licenseCost.toString(),
    );
  }

  @override
  void dispose() {
    licenseNo.dispose();
    issueDate.dispose();
    expiryDate.dispose();
    cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رخصة دخول مياه الصومال')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.description, size: 60, color: gold),
          const SizedBox(height: 16),
          field(licenseNo, 'رقم الرخصة'),
          field(issueDate, 'تاريخ الإصدار (YYYY-MM-DD)'),
          field(expiryDate, 'تاريخ الانتهاء (YYYY-MM-DD)'),
          field(cost, 'قيمة الرخصة', number: true),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saveLicense,
            icon: const Icon(Icons.save),
            label: const Text('حفظ بيانات الرخصة'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLicense() async {
    final boat = Store.activeBoat;
    boat.licenseNo = licenseNo.text.trim();
    boat.licenseIssue = issueDate.text.trim();
    boat.licenseExpiry = expiryDate.text.trim();
    boat.licenseCost = double.tryParse(cost.text.trim()) ?? 0;
    await Store.save();

    if (!mounted) return;
    widget.onChanged();
    Navigator.pop(context);
  }
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onChanged;

  const SettingsPage({super.key, required this.onChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController email;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: Store.email);
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الإعدادات وإدارة العباري',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: navy2,
          child: ListTile(
            leading: const Icon(Icons.directions_boat, color: gold),
            title: const Text('إضافة عبري جديد'),
            subtitle: const Text(
              'لكل عبري مصروفاته وصيادوه ورخصته بشكل مستقل',
            ),
            onTap: _addBoat,
          ),
        ),
        Card(
          color: navy2,
          child: ListTile(
            leading: const Icon(Icons.edit, color: gold),
            title: const Text('تغيير اسم العبري الحالي'),
            onTap: _renameBoat,
          ),
        ),
        Card(
          color: navy2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'البريد الإلكتروني للنسخ الاحتياطي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'حفظ البريد لا يرسل الملفات تلقائيًا. أنشئ ملف JSON ثم احفظه على الهاتف أو أرسله من تطبيق البريد يدويًا.',
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _saveEmail,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ البريد'),
                ),
              ],
            ),
          ),
        ),
        Card(child: SwitchListTile(
          secondary: const Icon(Icons.brightness_6, color: gold),
          title: const Text('الوضع الليلي'),
          subtitle: const Text('يمكن التبديل بين المظهر الفاتح والداكن'),
          value: Store.isDarkMode,
          activeColor: gold,
          onChanged: (value) async { Store.isDarkMode = value; await Store.save(); if (mounted) { setState(() {}); widget.onChanged(); } },
        )),
        Card(child: Column(children: [
          ListTile(leading: const Icon(Icons.backup, color: gold), title: const Text('إنشاء نسخة احتياطية'), subtitle: const Text('حفظ جميع بيانات العباري في ملف JSON'), onTap: _exportBackup),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.restore, color: gold), title: const Text('استعادة نسخة احتياطية'), subtitle: const Text('استيراد ملف JSON محفوظ سابقاً'), onTap: _importBackup),
        ])),
        Card(
          color: navy2,
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: gold),
            title: const Text('تقرير PDF'),
            subtitle: const Text('إنشاء ومشاركة تقرير الحسابات'),
            onTap: () => makePdfReport(),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'الإصدار الأول: حفظ محلي، إدارة العباري، المصروفات، الصيادون والمديونيات، الرخصة وتصدير PDF.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Future<void> _saveEmail() async {
    Store.email = email.text.trim();
    await Store.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ البريد على الجهاز')),
    );
  }

  Future<void> _exportBackup() async {
    try {
      final data = <String, dynamic>{
        'format': 'fishing_boat_accounts_backup', 'version': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'boats': Store.boats.map((e) => e.toJson()).toList(),
        'expenses': Store.expenses.map((e) => e.toJson()).toList(),
        'fishers': Store.fishers.map((e) => e.toJson()).toList(),
        'debts': Store.debts.map((e) => e.toJson()).toList(),
        'email': Store.email, 'activeBoatId': Store.activeBoatId,
        'isDarkMode': Store.isDarkMode,
        'monthlyArchives': Store.monthlyArchives,
      };
      final bytes = Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(data)));
      final path = await FilePicker.platform.saveFile(dialogTitle: 'حفظ النسخة الاحتياطية', fileName: 'boat_accounts_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json', type: FileType.custom, allowedExtensions: ['json'], bytes: bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(path == null
            ? 'لم يؤكد النظام حفظ الملف. اختر مجلدًا واحفظ النسخة ثم تحقق من وجود ملف JSON.'
            : 'تم حفظ النسخة الاحتياطية في: $path')),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إنشاء النسخة: $e')));
    }
  }

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
      if (result == null || result.files.single.bytes == null) return;
      if (!mounted) return;
      final decoded = jsonDecode(utf8.decode(result.files.single.bytes!));
      if (decoded is! Map || decoded['format'] != 'fishing_boat_accounts_backup') throw const FormatException('ملف النسخة غير صالح');
      final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الاستعادة'),
        content: const Text('ستُستبدل البيانات الحالية بمحتويات النسخة المختارة. يُفضّل إنشاء نسخة احتياطية من الوضع الحالي أولاً.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('استعادة'))],
      ));
      if (confirm != true) return;
      List<dynamic> list(String key) => decoded[key] is List ? decoded[key] as List : <dynamic>[];
      Store.boats = list('boats').map((e) => Boat.fromJson(Map<String, dynamic>.from(e))).toList();
      Store.expenses = list('expenses').map((e) => Expense.fromJson(Map<String, dynamic>.from(e))).toList();
      Store.fishers = list('fishers').map((e) => Fisherman.fromJson(Map<String, dynamic>.from(e))).toList();
      Store.debts = list('debts').map((e) => DebtEntry.fromJson(Map<String, dynamic>.from(e))).toList();
      if (Store.boats.isEmpty) throw const FormatException('النسخة لا تحتوي على عبري');
      Store.email = decoded['email']?.toString() ?? '';
      Store.activeBoatId = decoded['activeBoatId']?.toString() ?? Store.boats.first.id;
      if (!Store.boats.any((b) => b.id == Store.activeBoatId)) Store.activeBoatId = Store.boats.first.id;
      Store.isDarkMode = decoded['isDarkMode'] is bool ? decoded['isDarkMode'] as bool : true;
      Store.monthlyArchives = decoded['monthlyArchives'] is List
          ? (decoded['monthlyArchives'] as List).map((e) => Map<String, dynamic>.from(e)).toList()
          : [];
      await Store.save();
      if (!mounted) return;
      setState(() {}); widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت استعادة النسخة الاحتياطية')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذرت الاستعادة: $e')));
    }
  }

  Future<void> _addBoat() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة عبري'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم العبري'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().isNotEmpty,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final boat = Boat(id: newId(), name: controller.text.trim());
      Store.boats.add(boat);
      Store.activeBoatId = boat.id;
      await Store.save();
      if (mounted) {
        setState(() {});
        widget.onChanged();
      }
    }
    controller.dispose();
  }

  Future<void> _renameBoat() async {
    final controller = TextEditingController(text: Store.activeBoat.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تغيير اسم العبري'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'الاسم الجديد'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().isNotEmpty,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Store.activeBoat.name = controller.text.trim();
      await Store.save();
      if (mounted) {
        setState(() {});
        widget.onChanged();
      }
    }
    controller.dispose();
  }
}

Widget field(
  TextEditingController controller,
  String label, {
  bool required = false,
  bool number = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return 'هذا الحقل مطلوب';
        if (number && text.isNotEmpty) {
          final parsed = double.tryParse(text);
          if (parsed == null) return 'أدخل رقمًا صحيحًا';
          if (parsed < 0) return 'لا يمكن إدخال قيمة سالبة';
        }
        return null;
      },
    ),
  );
}


Future<void> makePdfReport() async {
  final boat = Store.activeBoat;
  final document = pw.Document();

  final arabicFontData =
      await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
  final arabicBoldData =
      await rootBundle.load('assets/fonts/NotoSansArabic-Bold.ttf');

  final arabicFont = pw.Font.ttf(arabicFontData);
  final arabicBold = pw.Font.ttf(arabicBoldData);

  final pdfTheme = pw.ThemeData.withFont(
    base: arabicFont,
    bold: arabicBold,
  );

  final expenses = Store.expenses
      .where((item) => item.boatId == boat.id)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final fishers = Store.fishers
      .where((item) => item.boatId == boat.id)
      .toList();

  final debtEntries = Store.debts
      .where((item) => item.boatId == boat.id)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final fisherNames = {
    for (final fisher in fishers) fisher.id: fisher.name,
  };

  final totalDebt = fishers.fold(
    0.0,
    (sum, fisher) => sum + Store.debtBalance(fisher),
  );

  final totalDebtEntries = debtEntries
      .where((entry) => entry.type == 'دين')
      .fold(0.0, (sum, entry) => sum + entry.amount);

  final totalPayments = debtEntries
      .where((entry) => entry.type == 'سداد')
      .fold(0.0, (sum, entry) => sum + entry.amount);

  document.addPage(
    pw.MultiPage(
      theme: pdfTheme,
      pageTheme: pw.PageTheme(
        textDirection: pw.TextDirection.rtl,
      ),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            'تقرير حسابات العبري: ${boat.name}',
            style: pw.TextStyle(font: arabicBold, fontSize: 20),
          ),
        ),
        pw.Text('تاريخ التقرير: ${dateNow()}'),
        pw.SizedBox(height: 10),

        pw.Text(
          'رخصة الصومال: ${boat.licenseNo.isEmpty ? 'غير مسجلة' : boat.licenseNo}',
        ),
        pw.Text(
          'تاريخ انتهاء الرخصة: ${boat.licenseExpiry.isEmpty ? 'غير مسجل' : boat.licenseExpiry}',
        ),

        pw.SizedBox(height: 16),
        pw.Header(
          level: 1,
          child: pw.Text('مصروفات تجهيز العبري للإبحار'),
        ),

        pw.TableHelper.fromTextArray(
          headers: [
            'القسم',
            'الصنف',
            'التاريخ',
            'الكمية',
            'سعر الوحدة',
            'الإجمالي',
          ],
          data: expenses.map((item) => [
            item.category,
            item.item,
            item.date,
            money(item.quantity),
            money(item.unitPrice),
            money(item.total),
          ]).toList(),
          cellAlignment: pw.Alignment.centerRight,
          headerAlignment: pw.Alignment.center,
          cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8),
          headerStyle: pw.TextStyle(font: arabicBold, fontSize: 8),
        ),

        pw.SizedBox(height: 10),
        pw.Text(
          'إجمالي المصروفات: ${money(Store.expenseTotal(boat.id))} ريال يمني',
          style: pw.TextStyle(font: arabicBold),
        ),

        pw.SizedBox(height: 16),
        pw.Header(
          level: 1,
          child: pw.Text('بيانات الصيادين والأرصدة'),
        ),

        pw.TableHelper.fromTextArray(
          headers: ['اسم الصياد', 'الجوال', 'العنوان', 'الرصيد المتبقي'],
          data: fishers.map((fisher) => [
            fisher.name,
            fisher.phone,
            fisher.address,
            money(Store.debtBalance(fisher)),
          ]).toList(),
          cellAlignment: pw.Alignment.centerRight,
          headerAlignment: pw.Alignment.center,
          cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8),
          headerStyle: pw.TextStyle(font: arabicBold, fontSize: 8),
        ),

        pw.SizedBox(height: 10),
        pw.Text(
          'إجمالي الرصيد المتبقي: ${money(totalDebt)} ريال',
          style: pw.TextStyle(font: arabicBold),
        ),

        pw.SizedBox(height: 16),
        pw.Header(
          level: 1,
          child: pw.Text('تفاصيل الديون والسداد'),
        ),

        pw.TableHelper.fromTextArray(
          headers: [
            'التاريخ',
            'اسم الصياد',
            'النوع',
            'الوصف',
            'المبلغ',
          ],
          data: debtEntries.map((entry) => [
            entry.date,
            fisherNames[entry.fishermanId] ?? 'صياد غير مسجل',
            entry.type,
            entry.description,
            money(entry.amount),
          ]).toList(),
          cellAlignment: pw.Alignment.centerRight,
          headerAlignment: pw.Alignment.center,
          cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8),
          headerStyle: pw.TextStyle(font: arabicBold, fontSize: 8),
        ),

        pw.SizedBox(height: 12),
        pw.Text('إجمالي الديون المسجلة: ${money(totalDebtEntries)} ريال'),
        pw.Text('إجمالي السداد: ${money(totalPayments)} ريال'),
        pw.Text(
          'الرصيد المتبقي: ${money(totalDebt)} ريال',
          style: pw.TextStyle(font: arabicBold),
        ),

        pw.SizedBox(height: 20),
        pw.Text(
          'هذا التقرير يعرض البيانات المسجلة في التطبيق وقت التصدير.',
          style: pw.TextStyle(font: arabicFont, fontSize: 9),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) => document.save(),
    name: 'accounts_${boat.name}_${dateNow()}.pdf',
  );
}
