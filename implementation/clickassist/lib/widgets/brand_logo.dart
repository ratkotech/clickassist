import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_text_styles.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo.full({super.key, this.maxWidth = 280})
    : _variant = _BrandLogoVariant.full,
      size = null;

  const BrandLogo.compact({super.key, this.maxWidth = 240})
    : _variant = _BrandLogoVariant.compact,
      size = null;

  const BrandLogo.mark({super.key, this.size = 56})
    : _variant = _BrandLogoVariant.mark,
      maxWidth = null;

  static const _logoAsset = 'assets/branding/clickassist-app-icon.png';

  final _BrandLogoVariant _variant;
  final double? maxWidth;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _BrandLogoVariant.full => Semantics(
        label: 'ClickAssist: Precision tap automation',
        image: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: Image.asset(
            _logoAsset,
            key: const Key('brand-logo-full'),
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
      _BrandLogoVariant.compact => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo.mark(size: 48),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ClickAssist',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primaryBright,
                    ),
                  ),
                  Text(
                    'Precision tap automation',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _BrandLogoVariant.mark => Image.asset(
        _logoAsset,
        key: const Key('brand-logo-mark'),
        width: size,
        height: size,
        fit: BoxFit.contain,
        semanticLabel: 'ClickAssist',
      ),
    };
  }
}

enum _BrandLogoVariant { full, compact, mark }
