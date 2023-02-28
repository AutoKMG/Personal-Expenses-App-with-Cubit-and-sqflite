// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/logic/cubit/handler.dart';
import 'package:intl/intl.dart';

import '../widgets/adaptive_flat_button.dart';

class NewTransaction extends StatelessWidget {
  BuildContext context;
  AppHandler appHandler;
  NewTransaction(this.appHandler, this.context);

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      appHandler.changeSelectedDate(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Form(
            key: appHandler.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: appHandler.titleController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Title can not be empty';
                    } else {
                      return null;
                    }
                  },
                  // onChanged: (val) {
                  //   titleInput = val;
                  // },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  controller: appHandler.priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'price can not be empty';
                    } else {
                      return null;
                    }
                  },
                ),
                Container(
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: BlocBuilder<AppHandler, AppState>(
                          builder: (context, state) {
                            return Text(
                              appHandler.selectedDate == null
                                  ? 'No Date Chosen!'
                                  : 'Picked Date: ${DateFormat.yMd().format(appHandler.selectedDate)}',
                            );
                          },
                        ),
                      ),
                      AdaptiveFlatButton('Choose Date', _presentDatePicker)
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text('Add Transaction'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                      textStyle: MaterialStateProperty.all(TextStyle(
                          color:
                              Theme.of(context).textTheme.labelLarge.color))),
                  onPressed: () {
                    if (appHandler.formKey.currentState.validate() &&
                        appHandler.selectedDate != null) {
                      appHandler.insertToDatabase(
                        title: appHandler.titleController.text,
                        price: int.parse(appHandler.priceController.text),
                        date: DateFormat.yMd().format(appHandler.selectedDate),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
