part of 'handler.dart';

@immutable
abstract class AppState {}

class AppStateInitial extends AppState {}

class AppStateShowChartValueChanged extends AppState {}

class AppStateSelectedDateChanged extends AppState {}

class AppStateDatabaseCreated extends AppState {}

class AppStateDatabaseLoading extends AppState {}

class AppStateDatabaseFetched extends AppState {}

class AppStateDeletingFromDatabase extends AppState {}

class AppStateInsertToDatabase extends AppState {}
