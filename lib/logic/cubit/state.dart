part of 'handler.dart';

@immutable
abstract class AppState {}

class AppStateInitial extends AppState {}

class AppStateNewTransactionAdded extends AppState {}

class AppStateTransactionDeleted extends AppState {}

class AppStateShowChartValueChanged extends AppState {}

class AppStateSelectedDateChanged extends AppState {}
