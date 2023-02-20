// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_guide/logic/cubit/handler.dart';
import 'package:intl/intl.dart';

import '../widgets/adaptive_flat_button.dart';

class NewTransaction extends StatefulWidget {
  BuildContext context;
  AppHandler appHandler;
  NewTransaction(this.appHandler, this.context);
  static var formKey = GlobalKey<FormState>();

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  var titleController = TextEditingController();

  var amountController = TextEditingController();

  void _presentDatePicker() {
    showDatePicker(
      context: widget.context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      widget.appHandler.changeSelectedDate(pickedDate);
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
            key: NewTransaction.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: titleController,
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
                  decoration: InputDecoration(labelText: 'Amount'),
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Amount can not be empty';
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
                              widget.appHandler.selectedDate == null
                                  ? 'No Date Chosen!'
                                  : 'Picked Date: ${DateFormat.yMd().format(widget.appHandler.selectedDate)}',
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
                    if (NewTransaction.formKey.currentState.validate()) {
                      widget.appHandler.addNewTransaction(
                        titleController.text,
                        double.parse(amountController.text),
                        widget.appHandler.selectedDate,
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
