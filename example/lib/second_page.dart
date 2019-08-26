import 'package:flutter/material.dart';
import 'package:log_collector/log_collector.dart';
import 'package:provider/provider.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logger = Provider.of<Logger>(context);
    logger.post({'name': 'SecondPage'}, tag: 'screen');

    return Scaffold(
      appBar: AppBar(
        title: Text('2nd page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text('bar'),
              onPressed: () {
                logger.post({'action': 'bar'}, tag: 'event');
              },
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('back'),
              onPressed: () {
                logger.post({'action': 'back'}, tag: 'event');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
