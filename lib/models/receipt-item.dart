import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceiptItemListModel {
  ReceiptItemListModel(this.receiptId);

  Stream<List<ReceiptItem>> get stream {
    return _stream.stream;
  }

  final String receiptId;
  final _stream = StreamController<List<ReceiptItem>>();

  Future<List<ReceiptItem>> get items {
    return _fetchReceiptItems(receiptId);
  }

  Future<void> refresh() async {
    print("Refresh");
    final receiptItems = await _fetchReceiptItems(receiptId);
    _stream.addStream(Stream.value(receiptItems));
    print("Refreshed");
  }

  Future<List<ReceiptItem>> _fetchReceiptItems(String receiptId) async {
    print("Fetching receipt items of receipt ${receiptId}...");
    final response = await http
        .get(Uri.parse('http://localhost:8080/items/?receipt=$receiptId'));
    print("Fetched receipt items");

    if (response.statusCode == 200) {
      return List.from(
          jsonDecode(response.body).map((e) => ReceiptItem.fromJson(e)));
    } else {
      throw Exception('Failed to load receipt items');
    }
  }
}

@immutable
class ReceiptItem {
  final String id;
  final String name;
  final String? category;
  final String? categoryGroup;
  final int amount;
  final String receiptId;

  const ReceiptItem(this.id, this.name, this.amount, this.receiptId,
      {this.category, this.categoryGroup});

  static ReceiptItem fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
        json['id'], json['name'], json['amount'], json['receiptId'],
        category: json['category'], categoryGroup: json['categoryGroup']);
  }
}
