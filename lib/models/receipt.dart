import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceiptListModel {
  Stream<List<Receipt>> get stream {
    return _stream.stream;
  }

  final _stream = StreamController<List<Receipt>>();

  get receipts => _fetchReceipts();

  Future<void> refresh() async {
    print("Refresh");
    final receipts = await _fetchReceipts();
    _stream.addStream(Stream.value(receipts));
    print("Refreshed");
  }

  Future<List<Receipt>> _fetchReceipts() async {
    print("Fetching receipts...");
    final response =
        await http.get(Uri.parse('http://localhost:8080/receipts'));
    print("Fetched receipts");

    if (response.statusCode == 200) {
      return List.from(
          jsonDecode(response.body).map((e) => Receipt.fromJson(e)));
    } else {
      throw Exception('Failed to load receipts');
    }
  }
}

@immutable
class Receipt {
  final String id;
  final String name;
  final String store;
  final int amount;
  final DateTime date;
  final ReceiptStatus status;

  const Receipt(
      this.id, this.name, this.store, this.amount, this.date, this.status);

  static Receipt fromJson(Map<String, dynamic> json) {
    return Receipt(json['id'], json['name'], json['store'], json['amount'],
        DateTime.now(), ReceiptStatus.processed);
  }
}

enum ReceiptStatus {
  unprocessed,
  processing,
  processed,
  warning;
}
