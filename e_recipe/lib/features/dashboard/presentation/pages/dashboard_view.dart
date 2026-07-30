import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_recipe/app/routes/app_routes.dart';
import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/core/constants/recipe_categories.dart';
import 'package:e_recipe/core/services/permissions/app_permission_service.dart';
import 'package:e_recipe/features/favorites/presentation/pages/saved_tab.dart';
import 'package:e_recipe/features/favorites/presentation/view_model/saved_recipes_viewmodel.dart';
import 'package:e_recipe/features/profile/presentation/pages/profile_tab.dart';
import 'package:e_recipe/features/profile/presentation/pages/pro_membership_page.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:e_recipe/features/profile/presentation/widgets/notification_bell.dart';
import 'package:e_recipe/features/purchase/presentation/pages/purchased_tab.dart';
import 'package:e_recipe/features/purchase/presentation/view_model/purchase_viewmodel.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/presentation/pages/discover_tab.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:e_recipe/features/recipe/presentation/view_model/recipe_list_viewmodel.dart';
import 'package:e_recipe/features/recipe/presentation/widgets/recipe_access_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'dashboard_view_state.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}
