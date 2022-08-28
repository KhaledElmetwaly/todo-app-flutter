// ignore_for_file: prefer_is_empty

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../reusable/reusable.dart';

class DoneTasks extends StatelessWidget {
  const DoneTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoStates>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var tasks = TodoCubit.get(context).doneTasks;
        return ConditionalBuilder(
            condition: tasks.length > 0,
            builder: (context) => ListView.separated(
                itemBuilder: (context, index) {
                  return buildTaskItem(tasks[index], context);
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[300],
                  );
                },
                itemCount: tasks.length),
            fallback: (context) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.menu),
                      Text('No Tasks Yet, Please add some tasks')
                    ],
                  ),
                ));
      },
    );
  }
}
