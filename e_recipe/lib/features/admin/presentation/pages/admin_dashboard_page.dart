import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:e_recipe/features/admin/presentation/state/admin_dashboard_state.dart';
import 'package:e_recipe/features/admin/presentation/view_model/admin_dashboard_viewmodel.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:e_recipe/features/profile/presentation/widgets/notification_bell.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

part 'admin_dashboard_page_state.dart';

const _adminBrand = Color(0xFFC84616);
const _adminBg = Color(0xFFFBF7F1);

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}
