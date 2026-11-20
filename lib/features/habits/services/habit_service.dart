import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../models/goal.dart';
import '../models/habit.dart';

/// Pesan gagal modul habit
class HabitServiceException implements Exception {
  const HabitServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Pemanggilan endpoint modul Sustainable Habit & Goal Tracker
/// Memakai ApiClient bersama
class HabitService {
  HabitService(this._api);

  /// Mengambil ApiClient dari Provider
  factory HabitService.of(BuildContext context) =>
      HabitService(context.read<ApiClient>());

  final ApiClient _api;
  static const _timeout = Duration(seconds: 20);

  /// GET /api/v1/habits/ (ringkasan hari ini + daftar habit)
  Future<HabitOverview> fetchHabits() async {
    final data = await _send(_api.get('/habits/'));
    if (data is! Map<String, dynamic>) {
      throw const HabitServiceException('Respons daftar habit tidak valid.');
    }
    try {
      return HabitOverview.fromJson(data);
    } on FormatException {
      throw const HabitServiceException('Respons daftar habit tidak valid.');
    }
  }

  /// GET /api/v1/goals/ (daftar goal beserta progres dan checklist)
  Future<List<Goal>> fetchGoals() async {
    final data = await _send(_api.get('/goals/'));
    if (data is! List) {
      throw const HabitServiceException('Respons daftar goal tidak valid.');
    }
    try {
      return data.whereType<Map<String, dynamic>>().map(Goal.fromJson).toList();
    } on FormatException {
      throw const HabitServiceException('Respons daftar goal tidak valid.');
    }
  }

  /// Mengubah timeout, error jaringan, dan error HTTP menjadi pesan yang jelas
  Future<dynamic> _send(Future<dynamic> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw const HabitServiceException(
        'Server belum merespons. Silakan coba lagi.',
      );
    } on http.ClientException {
      throw const HabitServiceException(
        'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.',
      );
    } on ApiException catch (error) {
      throw HabitServiceException(_messageFor(error));
    }
  }

  String _messageFor(ApiException error) {
    if (error.statusCode == 401) {
      return 'Sesi kamu sudah berakhir. Silakan masuk kembali.';
    }
    if (error.statusCode == 404) {
      return 'Layanan habit belum tersedia. Silakan coba lagi nanti.';
    }
    if (error.statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }
    return error.message;
  }
}
