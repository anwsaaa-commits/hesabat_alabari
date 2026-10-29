import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const navy = Color(0xFF071B2B);
const navy2 = Color(0xFF102E46);
const gold = Color(0xFFFFC857);
const sea = Color(0xFF0E7490);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BoatAccountsApp());
}

class BoatAccountsApp extends StatelessWidget {
  const BoatAccountsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'حسابات العبري',
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: navy,
      colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.dark),
      appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: navy2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF31536A)),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
    ),
    home: const DashboardPage(),
  );
}

String money(num n) => NumberFormat('#,##0.##', 'en').format(n);
String dateNow() => DateFormat('yyyy-MM-dd').format(DateTime.now());

class Boat {
  String id, name;
  String licenseNo, licenseIssue, licenseExpiry;
  double licenseCost;
  Boat({required this.id, required this.name, this.licenseNo='', this.licenseIssue='',
    this.licenseExpiry='', this.licenseCost=0});
  Map<String,dynamic> toJson() => {'id':id,'name':name,'licenseNo':licenseNo,
    'licenseIssue':licenseIssue,'licenseExpiry':licenseExpiry,'licenseCost':licenseCost};
  factory Boat.fromJson(Map<String,dynamic> j) => Boat(
    id:j['id'], name:j['name'], licenseNo:j['licenseNo']??'',
    licenseIssue:j['licenseIssue']??'', licenseExpiry:j['licenseExpiry']??'',
    licenseCost:(j['licenseCost'] as num? ?? 0).toDouble());
}

class Expense {
  String id, boatId, category, item, date, person, notes;
  double quantity, unitPrice;
  Expense({required this.id, required this.boatId, required this.category,
    required this.item, required this.date, required this.quantity,
    required this.unitPrice, this.person='', this.notes=''});
  double get total => quantity * unitPrice;
  Map<String,dynamic> toJson() => {'id':id,'boatId':boatId,'category':category,
    'item':item,'date':date,'quantity':quantity,'unitPrice':unitPrice,'person':person,'notes':notes};
  factory Expense.fromJson(Map<String,dynamic> j) => Expense(
    id:j['id'],boatId:j['boatId'],category:j['category'],item:j['item'],date:j['date'],
    quantity:(j['quantity'] as num).toDouble(),unitPrice:(j['unitPrice'] as num).toDouble(),
    person:j['person']??'',notes:j['notes']??'');
}

class Fisherman {
  String id, boatId, name, address, phone;
  double openingDebt;
  Fisherman({required this.id, required this.boatId, required this.name,
    this.address='', this.phone='', this.openingDebt=0});
  Map<String,dynamic> toJson()=>{'id':id,'boatId':boatId,'name':name,'address':address,
    'phone':phone,'openingDebt':openingDebt};
  factory Fisherman.fromJson(Map<String,dynamic> j)=>Fisherman(
    id:j['id'],boatId:j['boatId'],name:j['name'],address:j['address']??'',
    phone:j['phone']??'',openingDebt:(j['openingDebt'] as num? ?? 0).toDouble());
}

class DebtEntry {
  String id, boatId, fishermanId, date, description, type;
  double amount;
  DebtEntry({required this.id,required this.boatId,required this.fishermanId,
    required this.date,required this.description,required this.type,required this.amount});
  Map<String,dynamic> toJson()=>{'id':id,'boatId':boatId,'fishermanId':fishermanId,
    'date':date,'description':description,'type':type,'amount':amount};
  factory DebtEntry.fromJson(Map<String,dynamic> j)=>DebtEntry(
    id:j['id'],boatId:j['boatId'],fishermanId:j['fishermanId'],date:j['date'],
    description:j['description']??'',type:j['type'],amount:(j['amount'] as num).toDouble());
}

class Store {
  static const _boats='boats_v1', _expenses='expenses_v1', _fishers='fishers_v1', _debts='debts_v1';
  static List<Boat> boats=[];
  static List<Expense> expenses=[];
  static List<Fisherman> fishers=[];
  static List<DebtEntry> debts=[];
  static String email='';
  static String activeBoatId='';
  static Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    List<dynamic> decode(String k)=>jsonDecode(p.getString(k)??'[]') as List<dynamic>;
    boats=decode(_boats).map((e)=>Boat.fromJson(Map<String,dynamic>.from(e))).toList();
    expenses=decode(_expenses).map((e)=>Expense.fromJson(Map<String,dynamic>.from(e))).toList();
    fishers=decode(_fishers).map((e)=>Fisherman.fromJson(Map<String,dynamic>.from(e))).toList();
    debts=decode(_debts).map((e)=>DebtEntry.fromJson(Map<String,dynamic>.from(e))).toList();
    email=p.getString('backup_email')??'';
    activeBoatId=p.getString('active_boat')??'';
    if(boats.isEmpty) {
      boats.add(Boat(id:DateTime.now().microsecondsSinceEpoch.toString(),name:'العبري الأول'));
      activeBoatId=boats.first.id;
      await save();
    }
    if(!boats.any((b)=>b.id==activeBoatId)) activeBoatId=boats.first.id;
  }
  static Future<void> save() async {
    final p=await SharedPreferences.getInstance();
    await p.setString(_boats,jsonEncode(boats.map((e)=>e.toJson()).toList()));
    await p.setString(_expenses,jsonEncode(expenses.map((e)=>e.toJson()).toList()));
    await p.setString(_fishers,jsonEncode(fishers.map((e)=>e.toJson()).toList()));
    await p.setString(_debts,jsonEncode(debts.map((e)=>e.toJson()).toList()));
    await p.setString('backup_email',email);
    await p.setString('active_boat',activeBoatId);
  }
  static Boat get activeBoat => boats.firstWhere((b)=>b.id==activeBoatId,orElse:()=>boats.first);
  static double expenseTotal([String? boatId]) => expenses.where((e)=>boatId==null||e.boatId==boatId).fold(0,(s,e)=>s+e.total);
  static double debtBalance(Fisherman f) {
    final entries=debts.where((e)=>e.fishermanId==f.id);
    return f.openingDebt + entries.fold(0.0,(s,e)=>s+(e.type=='دين' ? e.amount : -e.amount));
  }
}

const categories = ['المواد الغذائية','مستلزمات وتجهيزات العبري','المشتقات النفطية','الثلج والماء'];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState()=>_DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> {
  int tab=0;
  bool loading=true;
  @override void initState(){super.initState(); Store.load().then((_){if(mounted)setState(()=>loading=false);});}
  void refresh()=>setState((){});
  @override Widget build(BuildContext context) {
    if(loading) return const Scaffold(body:Center(child:CircularProgressIndicator()));
    final pages=[
      _home(), ExpensesPage(onChanged:refresh), FishermenPage(onChanged:refresh),
      TotalsPage(), SettingsPage(onChanged:refresh),
    ];
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(
      appBar:AppBar(title:Text('حسابات ${Store.activeBoat.name}',style:const TextStyle(fontWeight:FontWeight.bold)),
        actions:[PopupMenuButton<String>(
          icon:const Icon(Icons.directions_boat,color:gold),
          onSelected:(id) async {Store.activeBoatId=id;await Store.save();refresh();},
          itemBuilder:(_)=>Store.boats.map((b)=>PopupMenuItem(value:b.id,child:Text(b.name))).toList())]),
      body:pages[tab],
      bottomNavigationBar:NavigationBar(backgroundColor:navy2,indicatorColor:gold.withOpacity(.18),
        selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const [
          NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard,color:gold),label:'الرئيسية'),
          NavigationDestination(icon:Icon(Icons.receipt_long),label:'المصروفات'),
          NavigationDestination(icon:Icon(Icons.groups),label:'الصيادون'),
          NavigationDestination(icon:Icon(Icons.calculate),label:'الحسابات'),
          NavigationDestination(icon:Icon(Icons.settings),label:'الإعدادات'),
        ]),
    ));
  }
  Widget _home()=>ListView(padding:const EdgeInsets.all(16),children:[
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(
      borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[navy2,sea])),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Icon(Icons.sailing,size:44,color:gold),
        const SizedBox(height:8),const Text('إدارة حسابات العبري',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
        const Text('كل حسابات مشروع الصيد في مكان واحد',style:TextStyle(color:Colors.white70)),
        const SizedBox(height:18),Text('العبري النشط: ${Store.activeBoat.name}',style:const TextStyle(color:gold,fontWeight:FontWeight.bold)),
      ])),
    const SizedBox(height:14),
    Row(children:[
      Expanded(child:_stat('إجمالي المصروفات',money(Store.expenseTotal(Store.activeBoatId))+' ر.ي',Icons.payments)),
      const SizedBox(width:10),
      Expanded(child:_stat('عدد الصيادين',Store.fishers.where((f)=>f.boatId==Store.activeBoatId).length.toString(),Icons.groups)),
    ]),
    const SizedBox(height:14),
    _sectionTitle('تجهيز العبري للإبحار'),
    ...categories.map((c){final total=Store.expenses.where((e)=>e.boatId==Store.activeBoatId&&e.category==c).fold(0.0,(s,e)=>s+e.total);
      return Card(color:navy2,child:ListTile(leading:const Icon(Icons.anchor,color:gold),title:Text(c),
        trailing:Text('${money(total)} ر.ي',style:const TextStyle(color:gold,fontWeight:FontWeight.bold))));}),
    const SizedBox(height:12),
    Card(color:navy2,child:ListTile(leading:const Icon(Icons.description,color:gold),title:const Text('رخصة دخول مياه الصومال'),
      subtitle:Text('رقم الرخصة: ${Store.activeBoat.licenseNo.isEmpty?'غير مسجل':Store.activeBoat.licenseNo}\nالانتهاء: ${Store.activeBoat.licenseExpiry.isEmpty?'غير مسجل':Store.activeBoat.licenseExpiry}'),
      isThreeLine:true,onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LicensePage(onChanged:refresh))).then((_)=>refresh()))),
    const SizedBox(height:8),
    FilledButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LicensePage(onChanged:refresh))).then((_)=>refresh()),
      icon:const Icon(Icons.edit_document),label:const Text('إدارة بيانات الرخصة')),
    FilledButton.icon(onPressed:()=>makePdfReport(),icon:const Icon(Icons.picture_as_pdf),label:const Text('إنشاء تقرير PDF')),
  ]);
  Widget _stat(String title,String value,IconData icon)=>Container(padding:const EdgeInsets.all(16),
    decoration:BoxDecoration(color:navy2,borderRadius:BorderRadius.circular(18),border:Border.all(color:gold.withOpacity(.35))),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Icon(icon,color:gold,size:26),const SizedBox(height:10),Text(title,style:const TextStyle(color:Colors.white70)),
      const SizedBox(height:6),Text(value,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold,color:gold)),
    ]));
  Widget _sectionTitle(String s)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(s,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:gold)));
}

class ExpensesPage extends StatefulWidget {
  final VoidCallback onChanged;
  const ExpensesPage({super.key,required this.onChanged});
  @override State<ExpensesPage> createState()=>_ExpensesPageState();
}
class _ExpensesPageState extends State<ExpensesPage> {
  String category=categories.first;
  @override Widget build(BuildContext context) {
    final list=Store.expenses.where((e)=>e.boatId==Store.activeBoatId&&e.category==category).toList()..sort((a,b)=>b.date.compareTo(a.date));
    final sum=list.fold(0.0,(s,e)=>s+e.total);
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:Colors.transparent,
      floatingActionButton:FloatingActionButton.extended(backgroundColor:gold,foregroundColor:navy,
        onPressed:()=>_addExpense(context),icon:const Icon(Icons.add),label:const Text('إضافة مصروف')),
      body:Column(children:[
        Padding(padding:const EdgeInsets.all(12),child:DropdownButtonFormField<String>(value:category,decoration:const InputDecoration(labelText:'اختر القسم'),
          items:categories.map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),onChanged:(v)=>setState(()=>category=v??categories.first))),
        Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Align(alignment:Alignment.centerRight,child:Text('إجمالي القسم: ${money(sum)} ر.ي',style:const TextStyle(color:gold,fontSize:17,fontWeight:FontWeight.bold)))),
        Expanded(child:list.isEmpty?const Center(child:Text('لا توجد مصروفات مسجلة لهذا القسم')):ListView.builder(itemCount:list.length,itemBuilder:(ctx,i){
          final e=list[i];return Card(color:navy2,margin:const EdgeInsets.symmetric(horizontal:12,vertical:5),child:ListTile(
            leading:const CircleAvatar(backgroundColor:navy,child:Icon(Icons.receipt,color:gold)),
            title:Text(e.item,style:const TextStyle(fontWeight:FontWeight.bold)),
            subtitle:Text('${e.date} • الكمية ${money(e.quantity)} × ${money(e.unitPrice)}${e.person.isEmpty?'':'\\nالمستلم: ${e.person}'}'),
            isThreeLine:e.person.isNotEmpty,trailing:Text('${money(e.total)}\\nر.ي',textAlign:TextAlign.end,style:const TextStyle(color:gold,fontWeight:FontWeight.bold)),
            onLongPress:()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('حذف المصروف؟'),content:Text(e.item),actions:[
              TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('إلغاء')),
              TextButton(onPressed:()=>Navigator.pop(c,true),child:const Text('حذف'))]));
              if(ok==true){Store.expenses.removeWhere((x)=>x.id==e.id);await Store.save();setState((){});widget.onChanged();}
            ]));})),
      ])));
  }
  Future<void> _addExpense(BuildContext context) async {
    final item=TextEditingController(),qty=TextEditingController(text:'1'),price=TextEditingController(),person=TextEditingController(),notes=TextEditingController();
    final form=GlobalKey<FormState>();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
      title:Text('إضافة: $category'),content:SingleChildScrollView(child:Form(key:form,child:Column(mainAxisSize:MainAxisSize.min,children:[
        _field(item,'الصنف / البيان',required:true),_field(qty,'الكمية',required:true,number:true),
        _field(price,'سعر الوحدة',required:true,number:true),_field(person,'اسم المستلم أو المورد'),
        _field(notes,'ملاحظات'),
      ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),
        FilledButton(onPressed:()=>Navigator.pop(ctx,form.currentState!.validate()),child:const Text('حفظ'))])));
    if(ok!=true)return;
    Store.expenses.add(Expense(id:DateTime.now().microsecondsSinceEpoch.toString(),boatId:Store.activeBoatId,
      category:category,item:item.text.trim(),date:dateNow(),quantity:double.parse(qty.text),unitPrice:double.parse(price.text),
      person:person.text.trim(),notes:notes.text.trim()));
    await Store.save();if(mounted)setState((){});widget.onChanged();
  }
}

class FishermenPage extends StatefulWidget {
  final VoidCallback onChanged;
  const FishermenPage({super.key,required this.onChanged});
  @override State<FishermenPage> createState()=>_FishermenPageState();
}
class _FishermenPageState extends State<FishermenPage> {
  @override Widget build(BuildContext context){
    final list=Store.fishers.where((f)=>f.boatId==Store.activeBoatId).toList();
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:Colors.transparent,
      floatingActionButton:FloatingActionButton.extended(backgroundColor:gold,foregroundColor:navy,onPressed:_addFisher,
        icon:const Icon(Icons.person_add),label:const Text('إضافة صياد')),
      body:list.isEmpty?const Center(child:Text('أضف أسماء الصيادين لبدء تسجيل حساباتهم')):ListView.builder(padding:const EdgeInsets.all(12),itemCount:list.length,itemBuilder:(ctx,i){
        final f=list[i],balance=Store.debtBalance(f);
        return Card(color:navy2,child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),
          title:Text(f.name,style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text('${f.phone}\\n${f.address}\\nالمديونية: ${money(balance)} ر.ي',style:TextStyle(color:balance>0?Colors.orangeAccent:Colors.white70)),
          isThreeLine:true,trailing:const Icon(Icons.chevron_left),onTap:()=>_fisherDetails(f)));
      })));
  }
  Future<void> _addFisher() async {
    final name=TextEditingController(),address=TextEditingController(),phone=TextEditingController(),debt=TextEditingController(text:'0');
    final form=GlobalKey<FormState>();
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
      title:const Text('إضافة صياد'),content:Form(key:form,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        _field(name,'اسم الصياد',required:true),_field(address,'العنوان'),_field(phone,'رقم الجوال'),_field(debt,'الرصيد الافتتاحي للمديونية',required:true,number:true),
      ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),
        FilledButton(onPressed:()=>Navigator.pop(ctx,form.currentState!.validate()),child:const Text('حفظ'))])));
    if(ok!=true)return;
    Store.fishers.add(Fisherman(id:DateTime.now().microsecondsSinceEpoch.toString(),boatId:Store.activeBoatId,
      name:name.text.trim(),address:address.text.trim(),phone:phone.text.trim(),openingDebt:double.parse(debt.text)));
    await Store.save();setState((){});widget.onChanged();
  }
  Future<void> _fisherDetails(Fisherman f) async {
    final form=GlobalKey<FormState>();final amount=TextEditingController(),desc=TextEditingController();
    await showDialog(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(
      title:Text(f.name),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('العنوان: ${f.address}'),Text('الجوال: ${f.phone}'),
        Text('الرصيد الحالي: ${money(Store.debtBalance(f))} ر.ي',style:const TextStyle(color:gold,fontWeight:FontWeight.bold)),
        const SizedBox(height:12),Form(key:form,child:Column(children:[_field(amount,'المبلغ',required:true,number:true),_field(desc,'البيان')]))
      ]),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إغلاق')),
        FilledButton(onPressed:()async{if(!form.currentState!.validate())return;
          Store.debts.add(DebtEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),boatId:f.boatId,fishermanId:f.id,date:dateNow(),
            description:desc.text.trim().isEmpty?'تسجيل دين':desc.text.trim(),type:'دين',amount:double.parse(amount.text)));
          await Store.save();if(ctx.mounted)Navigator.pop(ctx);setState((){});widget.onChanged();},child:const Text('تسجيل دين')),
        FilledButton.tonal(onPressed:()async{if(!form.currentState!.validate())return;
          Store.debts.add(DebtEntry(id:DateTime.now().microsecondsSinceEpoch.toString(),boatId:f.boatId,fishermanId:f.id,date:dateNow(),
            description:desc.text.trim().isEmpty?'سداد':desc.text.trim(),type:'سداد',amount:double.parse(amount.text)));
          await Store.save();if(ctx.mounted)Navigator.pop(ctx);setState((){});widget.onChanged();},child:const Text('تسجيل سداد')),
      ])));
    if(mounted)setState((){});
  }
}

class TotalsPage extends StatelessWidget {
  const TotalsPage({super.key});
  @override Widget build(BuildContext context){
    final boatId=Store.activeBoatId;
    final exp=Store.expenses.where((e)=>e.boatId==boatId).toList();
    final fish=Store.fishers.where((f)=>f.boatId==boatId).toList();
    final debt=fish.fold(0.0,(s,f)=>s+Store.debtBalance(f));
    return Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(16),children:[
      const Text('إجمالي الحسابات',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:gold)),
      const SizedBox(height:12),
      _totalCard('إجمالي مصروفات التجهيز',Store.expenseTotal(boatId)),
      ...categories.map((c)=>_totalCard(c,exp.where((e)=>e.category==c).fold(0.0,(s,e)=>s+e.total))),
      _totalCard('إجمالي مديونيات الصيادين',debt),
      _totalCard('إجمالي المصروفات + المديونيات',Store.expenseTotal(boatId)+debt),
      const SizedBox(height:12),
      FilledButton.icon(onPressed:makePdfReport,icon:const Icon(Icons.picture_as_pdf),label:const Text('تصدير تقرير PDF')),
      const Padding(padding:EdgeInsets.only(top:12),child:Text('ملاحظة: هذا ملخص المصروفات والمديونيات المسجلة، وليس كشف أرباح أو إيرادات الصيد.',style:TextStyle(color:Colors.white60))),
    ]));
  }
  Widget _totalCard(String title,double value)=>Card(color:navy2,child:ListTile(title:Text(title),trailing:Text('${money(value)} ر.ي',style:const TextStyle(color:gold,fontWeight:FontWeight.bold))));
}

class LicensePage extends StatefulWidget {
  final VoidCallback onChanged;
  const LicensePage({super.key,required this.onChanged});
  @override State<LicensePage> createState()=>_LicensePageState();
}
class _LicensePageState extends State<LicensePage>{
  late TextEditingController no,issue,expiry,cost;
  @override void initState(){super.initState();final b=Store.activeBoat;no=TextEditingController(text:b.licenseNo);issue=TextEditingController(text:b.licenseIssue);expiry=TextEditingController(text:b.licenseExpiry);cost=TextEditingController(text:b.licenseCost==0?'':b.licenseCost.toString());}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('رخصة دخول مياه الصومال')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      const Icon(Icons.description,size:60,color:gold),const SizedBox(height:16),
      _field(no,'رقم الرخصة'),_field(issue,'تاريخ الإصدار (YYYY-MM-DD)'),_field(expiry,'تاريخ الانتهاء (YYYY-MM-DD)'),_field(cost,'قيمة الرخصة',number:true),
      const SizedBox(height:16),FilledButton.icon(onPressed:()async{final b=Store.activeBoat;b.licenseNo=no.text.trim();b.licenseIssue=issue.text.trim();b.licenseExpiry=expiry.text.trim();b.licenseCost=double.tryParse(cost.text)??0;
        await Store.save();widget.onChanged();if(context.mounted)Navigator.pop(context);},icon:const Icon(Icons.save),label:const Text('حفظ بيانات الرخصة')),
    ])));
}

class SettingsPage extends StatefulWidget {
  final VoidCallback onChanged;
  const SettingsPage({super.key,required this.onChanged});
  @override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage>{
  late TextEditingController email;
  @override void initState(){super.initState();email=TextEditingController(text:Store.email);}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('الإعدادات وإدارة العباري',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:gold)),
    const SizedBox(height:12),
    Card(color:navy2,child:ListTile(leading:const Icon(Icons.directions_boat,color:gold),title:const Text('إضافة عبري جديد'),subtitle:const Text('لكل عبري مصروفاته وصيادوه ورخصته بشكل مستقل'),onTap:_addBoat)),
    Card(color:navy2,child:ListTile(leading:const Icon(Icons.edit,color:gold),title:const Text('تغيير اسم العبري الحالي'),onTap:_renameBoat)),
    Card(color:navy2,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('البريد الإلكتروني للنسخ الاحتياطي',style:TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:10),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(hintText:'name@example.com',prefixIcon:Icon(Icons.email))),
      const SizedBox(height:8),const Text('حاليًا يتم حفظ البيانات على هذا الجهاز. حفظ البريد هنا لا ينشئ نسخة سحابية بعد؛ ستُضاف خدمة النسخ الاحتياطي الآمن في المرحلة التالية.',style:TextStyle(color:Colors.white60)),
      const SizedBox(height:10),FilledButton.icon(onPressed:()async{Store.email=email.text.trim();await Store.save();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم حفظ البريد على الجهاز')));},icon:const Icon(Icons.save),label:const Text('حفظ البريد')),
    ]))),
    Card(color:navy2,child:ListTile(leading:const Icon(Icons.picture_as_pdf,color:gold),title:const Text('تقرير PDF'),subtitle:const Text('إنشاء ومشاركة تقرير الحسابات'),onTap:makePdfReport)),
    const SizedBox(height:10),const Text('الإصدار الأول: حفظ محلي، إدارة العباري، المصروفات، الصيادون والمديونيات، الرخصة وتصدير PDF.',style:TextStyle(color:Colors.white54)),
  ]));
  Future<void> _addBoat()async{
    final c=TextEditingController();final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('إضافة عبري'),content:TextField(controller:c,decoration:const InputDecoration(labelText:'اسم العبري')),actions:[
      TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,c.text.trim().isNotEmpty),child:const Text('إضافة'))])));
    if(ok==true){Store.boats.add(Boat(id:DateTime.now().microsecondsSinceEpoch.toString(),name:c.text.trim()));Store.activeBoatId=Store.boats.last.id;await Store.save();setState((){});widget.onChanged();}
  }
  Future<void> _renameBoat()async{
    final c=TextEditingController(text:Store.activeBoat.name);final ok=await showDialog<bool>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('تغيير اسم العبري'),content:TextField(controller:c,decoration:const InputDecoration(labelText:'الاسم الجديد')),actions:[
      TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,c.text.trim().isNotEmpty),child:const Text('حفظ'))])));
    if(ok==true){Store.activeBoat.name=c.text.trim();await Store.save();setState((){});widget.onChanged();}
  }
}

Widget _field(TextEditingController c,String label,{bool required=false,bool number=false})=>Padding(
  padding:const EdgeInsets.only(bottom:10),child:TextFormField(controller:c,keyboardType:number?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,
    decoration:InputDecoration(labelText:label),validator:(v){if(required&&(v==null||v.trim().isEmpty))return 'هذا الحقل مطلوب';if(number&&v!=null&&v.trim().isNotEmpty&&double.tryParse(v.trim())==null)return 'أدخل رقمًا صحيحًا';if(number&&v!=null&&double.tryParse(v.trim())!=null&&double.parse(v.trim())<0)return 'لا يمكن إدخال قيمة سالبة';return null;}));

Future<void> makePdfReport() async {
  final boat=Store.activeBoat;
  final doc=pw.Document();
  final expenses=Store.expenses.where((e)=>e.boatId==boat.id).toList();
  final fish=Store.fishers.where((f)=>f.boatId==boat.id).toList();
  doc.addPage(pw.MultiPage(build:(context)=>[
    pw.Header(level:0,child:pw.Text('تقرير حسابات العبري: ${boat.name}')),
    pw.Text('تاريخ التقرير: ${dateNow()}'),
    pw.SizedBox(height:12),
    pw.Text('رخصة الصومال: ${boat.licenseNo.isEmpty?'غير مسجلة':boat.licenseNo} | الانتهاء: ${boat.licenseExpiry.isEmpty?'غير مسجل':boat.licenseExpiry}'),
    pw.SizedBox(height:14),
    pw.Header(level:1,child:pw.Text('مصروفات تجهيز العبري للإبحار')),
    pw.TableHelper.fromTextArray(headers:['القسم','الصنف','التاريخ','الكمية','سعر الوحدة','الإجمالي'],
      data:expenses.map((e)=>[e.category,e.item,e.date,money(e.quantity),money(e.unitPrice),money(e.total)]).toList()),
    pw.SizedBox(height:12),
    pw.Text('إجمالي المصروفات: ${money(Store.expenseTotal(boat.id))} ريال يمني'),
    pw.SizedBox(height:14),
    pw.Header(level:1,child:pw.Text('مديونيات الصيادين')),
    pw.TableHelper.fromTextArray(headers:['اسم الصياد','الجوال','العنوان','الرصيد'],
      data:fish.map((f)=>[f.name,f.phone,f.address,money(Store.debtBalance(f))]).toList()),
    pw.SizedBox(height:10),
    pw.Text('إجمالي مديونيات الصيادين: ${money(fish.fold(0.0,(s,f)=>s+Store.debtBalance(f)))} ريال يمني'),
    pw.SizedBox(height:20),
    pw.Text('ملاحظة: هذا التقرير يعكس البيانات المسجلة في التطبيق وقت التصدير.'),
  ]));
  await Printing.layoutPdf(onLayout:(format)=>doc.save(),name:'accounts_${boat.name}_${dateNow()}.pdf');
}
