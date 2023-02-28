import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/models/transaction.dart';
import 'package:flutter_complete_guide/widgets/chart.dart';
import 'package:flutter_complete_guide/widgets/new_transaction.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

part 'state.dart';

class AppHandler extends Cubit<AppState> {
  BuildContext context;
  Database database;
  DateTime selectedDate;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var priceController = TextEditingController();

  AppHandler(this.context) : super(AppStateInitial());
  List<TransactionModel> userTransactions = [];
  bool showChart = false;

  List<TransactionModel> get recentTransactions {
    return userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void changeSelectedDate(DateTime value) {
    selectedDate = value;
    emit(AppStateSelectedDateChanged());
  }

  List<Widget> buildLandscapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).colorScheme.secondary,
            value: showChart,
            onChanged: (val) {
              showChart = val;
              emit(AppStateShowChartValueChanged());
            },
          ),
        ],
      ),
      showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(recentTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(recentTransactions),
      ),
      txListWidget
    ];
  }

  void startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (context) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(BlocProvider.of(context), context),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Personal Expenses',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => startAddNewTransaction(context),
              ),
            ],
          );
  }

  // -----------------------------------------
  // -----------------------------------------
  // -----------------------------------------
  // ------------- DATABASE PART -------------
  // -----------------------------------------
  // -----------------------------------------
  // -----------------------------------------
  void createDatabase() async {
    emit(AppStateDatabaseLoading());
    openDatabase(
      'transactions.sql',
      version: 1,
      onCreate: (db, version) async {
        await db
            .execute(
                'CREATE TABLE transactions (id INTEGER PRIMARY KEY, title TEXT, price NUMBER, date TEXT)')
            .then((value) {
          print("Database Created");
        }).catchError((error) {
          print("Error happened while creating database: ${error.toString()}");
        });
      },
      onOpen: (db) {
        getDataFromDatabse(db);
        print("Database Opened!");
      },
    ).then((value) {
      database = value;
      emit(AppStateDatabaseCreated());
    });
  }

  void insertToDatabase(
      {@required String title, @required int price, @required String date}) {
    database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO transactions(title, price, date) VALUES("$title", "$price","$date")')
          .then((value) {
        emit(AppStateInsertToDatabase());
        getDataFromDatabse(database);
        print("$value row inserted successfully");
      }).catchError((error) {
        print("Error happened while inserting a new row: ${error.toString()}");
      });
      return null;
    });
  }

  void deletingFromDatabase(id) {
    database.rawDelete('DELETE FROM transactions where id =$id').then((value) {
      print("$id row deleted");
      userTransactions.removeWhere((element) {
        return element.id == id;
      });
      emit(AppStateDeletingFromDatabase());
      getDataFromDatabse(database);
    }).catchError((error) {
      print("Error happened while deleting from database: ${error.toString()}");
    });
  }

  void getDataFromDatabse(Database database) {
    database.rawQuery('SELECT * FROM transactions').then((value) {
      if (value.isNotEmpty) {
        value.forEach((element) {
          TransactionModel newTranscation = new TransactionModel(
              id: element["id"],
              title: element["title"],
              price: (element["price"] as int).toDouble(),
              date: DateFormat.yMd().parse(element["date"]));
          if ((userTransactions.singleWhere((it) => it.id == newTranscation.id,
                  orElse: () => null)) !=
              null) {
            print('Already exists!');
          } else {
            userTransactions.add(newTranscation);
          }
        });
      }
      emit(AppStateDatabaseFetched());
    });
  }
}
