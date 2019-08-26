import 'package:example/second_page.dart';
import 'package:flutter/material.dart';
import 'package:log_collector/log_collector.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final logger = Provider.of<Logger>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text('foo'),
              onPressed: () {
                logger.post({'action': 'foo'}, tag: 'event');
              },
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('2nd page'),
              onPressed: () {
                logger.post({'action': '2nd_page'}, tag: 'event');
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => SecondPage(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
