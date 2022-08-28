import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/cubit/states.dart';

import '../modules/archived_tasks.dart';
import '../modules/done_tasks.dart';
import '../modules/new_tasks.dart';

class TodoCubit extends Cubit<TodoStates> {
  TodoCubit() : super(InitialTodaStates());
  static TodoCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Widget> screens = [
    const NewTasks(),
    const DoneTasks(),
    const ArchivedTasks(),
  ];
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<String> titles = ["New Tasks", "Done Tasks", "Archived Tasks"];
  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeTodoBottomNavBarStates());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      // print("Database created");
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        print("table created");
      }).catchError((error) {
        print("error when creating table ${error.toString()}");
      });
    }, onOpen: (database) {
      print('Database Opened');
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(TodoCreateDatabaseStates());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES ("$title","$date","$time","new")')
          .then((value) {
        print("$value inserted Successfully");
        emit(TodoInsertDatabaseStates());
        getDataFromDatabase(database!);
      }).catchError((error) {
        print("error when inserting data ${error.toString()}");
      });
    });
  }

  void getDataFromDatabase(Database database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(TodoGetDatabaseLoadingStates());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      for (var element in value) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      }
      emit(TodoGetDatabaseStates());
    });
  }

  void updateData({
    required int id,
    required String status,
  }) async {
    database!
        .rawUpdate('UPDATE tasks WHERE id = ?', [status, '$id']).then((value) {
      getDataFromDatabase(database!);
      emit(TodoUpdateDatabaseStates());
    });
  }

  void deleteData({
    required int id,
  }) async {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database!);
      emit(TodoDeleteDatabaseStates());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(TodoBottomSheetStates());
  }
}
