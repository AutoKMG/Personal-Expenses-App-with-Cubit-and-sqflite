import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/models/transaction.dart';
import 'package:flutter_complete_guide/widgets/chart.dart';
import 'package:flutter_complete_guide/widgets/new_transaction.dart';
import 'package:sqflite/sqflite.dart';

part 'state.dart';

class AppHandler extends Cubit<AppState> {
  BuildContext context;
  Database database;
  DateTime selectedDate;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var amountController = TextEditingController();

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

  void addNewTransaction(String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = TransactionModel(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );
    userTransactions.add(newTx);
    emit(AppStateNewTransactionAdded());
  }

  void deleteTransaction(String id) {
    userTransactions.removeWhere((tx) => tx.id == id);
    emit(AppStateTransactionDeleted());
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
}
