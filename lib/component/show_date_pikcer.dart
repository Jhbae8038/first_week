import 'package:flutter/cupertino.dart';

void showCupertinoDatePicker({required BuildContext context, required ValueChanged<DateTime> onDateChanged, required DateTime initialDateTime}) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 250,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: initialDateTime,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: onDateChanged,
              ),
            ),
            CupertinoButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}