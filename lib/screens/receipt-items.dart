import 'package:flutter/material.dart';

import '../models/receipt-item.dart';
import '../models/receipt.dart';

class ReceiptItemsScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptItemsScreen(this.receipt, {super.key});

  @override
  Widget build(BuildContext context) {
    final itemsList = ReceiptItemListModel(receipt.id);

    return MaterialApp(
      title: "Grocer",
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                splashRadius: 25.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Items: ${receipt.name}'),
              ),
            ],
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: itemsList.refresh,
              child: FutureBuilder<List<ReceiptItem>>(
                  future: itemsList.items,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return StreamBuilder<List<ReceiptItem>>(
                          initialData: snapshot.data,
                          stream: itemsList.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final items = snapshot.data!;

                              return ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];

                                  return Column(
                                    children: [
                                      Text(item.name),
                                      const SizedBox(height: 5)
                                    ],
                                  );
                                },
                              );
                            }

                            if (snapshot.hasError) {
                              return Text("ERROR - ${snapshot.error}");
                            }

                            return const CircularProgressIndicator();
                          });
                    }

                    if (snapshot.hasError) {
                      return Text("ERROR - ${snapshot.error}");
                    }

                    return const CircularProgressIndicator();
                  }),
            )),
      ),
    );
  }
}
