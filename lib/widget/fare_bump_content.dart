import 'package:cabme/constant/constant.dart';
import 'package:cabme/themes/app_them_data.dart';
import 'package:cabme/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

typedef IncreaseFareCallback = Future<void> Function(double bumpAmount);

class FareBumpContent extends StatelessWidget {
  final double currentAmount;
  final List<double> presetAmounts;
  final IncreaseFareCallback onIncrease;
  final VoidCallback? onKeepWaiting;

  const FareBumpContent({
    super.key,
    required this.currentAmount,
    required this.presetAmounts,
    required this.onIncrease,
    this.onKeepWaiting,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();
    final String currentFareLabel = Constant().amountShow(amount: currentAmount.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? AppThemeData.warningDarkLight : AppThemeData.warningLight).withOpacity(0.7),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppThemeData.warningDarkDefault : AppThemeData.warningDefault,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppThemeData.warningDarkDefault : AppThemeData.warningDefault).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "No drivers accepted yet".tr,
          textAlign: TextAlign.center,
          style: AppThemeData.boldTextStyle(
            fontSize: 20,
            color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Increase your fare to find a driver faster".tr,
          textAlign: TextAlign.center,
          style: AppThemeData.mediumTextStyle(
            fontSize: 14,
            color: isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.neutralDark100 : AppThemeData.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current fare".tr,
                style: AppThemeData.mediumTextStyle(
                  fontSize: 13,
                  color: isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
                ),
              ),
              Text(
                currentFareLabel,
                style: AppThemeData.boldTextStyle(
                  fontSize: 15,
                  color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(presetAmounts.length, (i) {
            final bump = presetAmounts[i];
            final highlighted = i == 1;
            return _FareBumpChip(
              bumpAmount: bump,
              currentAmount: currentAmount,
              highlighted: highlighted,
              onTap: () => onIncrease(bump),
            );
          }),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final double? amount = await showCustomFareDialog(context);
            if (amount != null && amount > 0) {
              await onIncrease(amount);
            }
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: isDark ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(
            Icons.tune_rounded,
            size: 18,
            color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
          ),
          label: Text(
            "Enter custom amount".tr,
            style: AppThemeData.semiBoldTextStyle(
              fontSize: 14,
              color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
            ),
          ),
        ),
        if (onKeepWaiting != null) ...[
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: onKeepWaiting,
              child: Text(
                "Keep waiting".tr,
                style: AppThemeData.semiBoldTextStyle(
                  fontSize: 14,
                  color: isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FareBumpChip extends StatelessWidget {
  final double bumpAmount;
  final double currentAmount;
  final bool highlighted;
  final VoidCallback onTap;

  const _FareBumpChip({
    required this.bumpAmount,
    required this.currentAmount,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();
    final String bumpLabel = "+${Constant().amountShow(amount: bumpAmount.toString())}";
    final String newTotalLabel = Constant().amountShow(amount: (currentAmount + bumpAmount).toString());

    final Color bgColor = highlighted ? (isDark ? AppThemeData.primaryDarkPressed : AppThemeData.primaryDark) : (isDark ? AppThemeData.neutralDark100 : AppThemeData.neutral100);
    final Color fgColor = highlighted ? Colors.white : (isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900);
    final Color subColor = highlighted ? Colors.white.withOpacity(0.85) : (isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500);
    final Color borderColor = highlighted ? (isDark ? AppThemeData.primaryDarkPressed : AppThemeData.primaryDark) : (isDark ? AppThemeData.neutralDark200 : AppThemeData.neutral200);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: highlighted
                    ? [
                        BoxShadow(
                          color: (isDark ? AppThemeData.primaryDarkDefault : AppThemeData.primaryDark).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(bumpLabel, style: AppThemeData.boldTextStyle(fontSize: 17, color: fgColor)),
                  const SizedBox(height: 4),
                  Text(newTotalLabel, style: AppThemeData.mediumTextStyle(fontSize: 11, color: subColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<double?> showCustomFareDialog(BuildContext context) async {
  final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
  final bool isDark = themeChange.getThem();
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final double? result = await showDialog<double>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Enter custom amount".tr,
          style: AppThemeData.boldTextStyle(
            fontSize: 18,
            color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "How much extra would you like to add to your fare?".tr,
                style: AppThemeData.mediumTextStyle(
                  fontSize: 13,
                  color: isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppThemeData.semiBoldTextStyle(
                  fontSize: 16,
                  color: isDark ? AppThemeData.neutralDark900 : AppThemeData.neutral900,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Please enter an amount".tr;
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) return "Please enter a valid amount".tr;
                  return null;
                },
                decoration: InputDecoration(
                  prefixText: Constant.symbolAtRight == true ? null : "+${Constant.currency ?? ''} ",
                  suffixText: Constant.symbolAtRight == true ? " +${Constant.currency ?? ''}" : null,
                  hintText: "0.00",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppThemeData.primaryDarkDefault : AppThemeData.primaryDark,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel".tr,
              style: AppThemeData.semiBoldTextStyle(
                fontSize: 14,
                color: isDark ? AppThemeData.neutralDark500 : AppThemeData.neutral500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final parsed = double.tryParse(controller.text.trim());
                Navigator.of(ctx).pop(parsed);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppThemeData.primaryDarkDefault : AppThemeData.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              "Confirm".tr,
              style: AppThemeData.semiBoldTextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
  return result;
}

Future<void> showFareBumpBottomSheet(
  BuildContext context, {
  required double currentAmount,
  required List<double> presetAmounts,
  required IncreaseFareCallback onIncrease,
}) {
  final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
  final bool isDark = themeChange.getThem();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.neutralDark50 : AppThemeData.neutral50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.neutralDark300 : AppThemeData.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              FareBumpContent(
                currentAmount: currentAmount,
                presetAmounts: presetAmounts,
                onIncrease: (bump) async {
                  Navigator.of(ctx).pop();
                  await onIncrease(bump);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
