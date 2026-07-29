import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/presentation/view_model/purchase_viewmodel.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/core/services/biometrics/biometric_service.dart';

const _esewaColor = Color(0xFF60BB46);

Future<bool> showRecipePurchaseDialog({
  required BuildContext context,
  required WidgetRef ref,
  required RecipeEntity recipe,
}) async {
  final price = RecipePrice.forRecipe(recipe);
  final formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();

  final esewaNumber = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Row(
        children: [
          CircleAvatar(
            backgroundColor: _esewaColor,
            child: Text(
              'e',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Text('Pay with eSewa'),
        ],
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'eSewa mobile number',
                  hintText: '98XXXXXXXX',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final number = value?.trim() ?? '';
                  if (!RegExp(r'^(97|98)\d{8}$').hasMatch(number)) {
                    return 'Enter a valid 10-digit eSewa number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: 'NPR $price',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your order and recipe access are created only after you press Proceed.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(dialogContext, numberController.text.trim());
            }
          },
          style: FilledButton.styleFrom(backgroundColor: _esewaColor),
          child: Text('Proceed • NPR $price'),
        ),
      ],
    ),
  );
  if (esewaNumber == null || !context.mounted) {
    // Let the dialog route finish unmounting before disposing its controller.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    numberController.dispose();
    return false;
  }

  // A biometric prompt temporarily backgrounds the activity. Wait until the
  // checkout dialog's reverse animation and inherited-widget cleanup finish.
  await Future<void>.delayed(const Duration(milliseconds: 400));
  numberController.dispose();
  if (!context.mounted) return false;

  final biometrics = BiometricService();
  if (biometrics.isEnabled) {
    final authenticated = await biometrics.authenticate(
      'Confirm your fingerprint to pay NPR $price with eSewa',
    );
    if (!authenticated || !context.mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled. Fingerprint was not verified.'),
          ),
        );
      }
      return false;
    }
  }
  final result = await ref
      .read(purchaseViewModelProvider.notifier)
      .purchase(recipe, esewaNumber: esewaNumber);
  var purchased = false;
  result.fold(
    (failure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    },
    (_) {
      purchased = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment recorded. Recipe added to Purchased.'),
        ),
      );
    },
  );
  return purchased;
}
