// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/logic/bloc_observer.dart';
import 'package:flutter_complete_guide/logic/cubit/handler.dart';
import './widgets/transaction_list.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppHandler(context),
      child: MaterialApp(
        title: 'Personal Expenses',
        theme: ThemeData(
            fontFamily: 'Quicksand',
            textTheme: ThemeData.light().textTheme.copyWith(
                  titleMedium: TextStyle(
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  titleLarge: TextStyle(color: Colors.white),
                ),
            appBarTheme: AppBarTheme(
              toolbarTextStyle: ThemeData.light()
                  .textTheme
                  .copyWith(
                    titleMedium: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  .bodyMedium,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              // ThemeData.light()
              //     .textTheme
              //     .copyWith(
              //       titleMedium: TextStyle(
              //           fontFamily: 'OpenSans',
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white),
              //     )
              //     .titleLarge,
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.amber)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage();
  @override
  Widget build(BuildContext context) {
    AppHandler appHandler = BlocProvider.of<AppHandler>(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = appHandler.buildAppBar(context);
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
          appHandler.userTransactions, appHandler.deleteTransaction),
    );
    final pageBody = BlocConsumer<AppHandler, AppState>(
      listener: (context, state) {
        if (state is AppStateNewTransactionAdded) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (isLandscape)
                  ...appHandler.buildLandscapeContent(
                    mediaQuery,
                    appBar,
                    txListWidget,
                  ),
                if (!isLandscape)
                  ...appHandler.buildPortraitContent(
                    mediaQuery,
                    appBar,
                    txListWidget,
                  ),
              ],
            ),
          ),
        );
      },
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => appHandler.startAddNewTransaction(context),
                  ),
          );
  }
}
