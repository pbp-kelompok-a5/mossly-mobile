import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../models/dashboard_data.dart';

class DashboardServiceException implements Exception {
  const DashboardServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DashboardService {
  DashboardService(this._api);

  factory DashboardService.of(BuildContext context) =>
      DashboardService(context.read<ApiClient>());

  final ApiClient _api;
  static const _timeout = Duration(seconds: 20);

  Future<DashboardSummary> fetchSummary() async {
    final data = await _send(_api.get('/dashboard/summary/'));
    if (data is! Map<String, dynamic>) {
      throw const DashboardServiceException('Respons ringkasan tidak valid.');
    }
    try {
      return DashboardSummary.fromJson(data);
    } on TypeError {
      throw const DashboardServiceException('Respons ringkasan tidak valid.');
    }
  }

  Future<BadgeOverview> fetchBadges({String? category}) async {
    final data = await _send(
      _api.get(
        '/dashboard/badges/',
        query: category == null ? null : {'kategori': category},
      ),
    );
    if (data is! Map<String, dynamic>) {
      throw const DashboardServiceException('Respons badge tidak valid.');
    }
    try {
      return BadgeOverview.fromJson(data);
    } on TypeError {
      throw const DashboardServiceException('Respons badge tidak valid.');
    }
  }

  Future<dynamic> _send(Future<dynamic> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw const DashboardServiceException(
        'Server belum merespons. Silakan coba lagi.',
      );
    } on http.ClientException {
      throw const DashboardServiceException(
        'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.',
      );
    } on ApiException catch (error) {
      throw DashboardServiceException(_messageFor(error));
    }
  }

  String _messageFor(ApiException error) {
    if (error.statusCode == 401) {
      return 'Sesi kamu sudah berakhir. Silakan masuk kembali.';
    }
    if (error.statusCode == 404) {
      return 'Layanan dashboard belum tersedia. Silakan coba lagi nanti.';
    }
    if (error.statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }
    return error.message;
  }
}