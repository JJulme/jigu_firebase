import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String? userId;
  final String? dataTime;
  final String? title;
  final String? body;
  Promotion({
    this.userId,
    this.dataTime,
    this.title,
    this.body,
  });

  factory Promotion.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Promotion(
      userId: data?["userId"],
      dataTime: data?["dataTime"],
      title: data?["title"],
      body: data?["body"],
    );
  }
}
