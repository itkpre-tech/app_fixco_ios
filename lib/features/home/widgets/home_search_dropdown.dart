import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../shared/home_constants.dart';
import '../shared/home_image_helper.dart';

class HomeSearchDropdown extends StatelessWidget {
  final List<ServiceModel> suggestions;
  final double topOffset;
  final ValueChanged<String> onSelect;

  const HomeSearchDropdown({
    super.key,
    required this.suggestions,
    required this.topOffset,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 390),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: suggestions.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(18),
              child: Row(children: [
                Icon(Icons.search_off_rounded, color: kTextLight, size: 18),
                SizedBox(width: 10),
                Text('No services found', style: TextStyle(color: kTextLight, fontSize: 14)),
              ]),
            )
                : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: suggestions.length,
              itemBuilder: (_, i) => _DropdownItem(
                service: suggestions[i],
                isLast: i == suggestions.length - 1,
                onTap: () => onSelect(suggestions[i].name),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final ServiceModel service;
  final bool isLast;
  final VoidCallback onTap;

  const _DropdownItem({required this.service, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.10))),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 38, height: 38,
                child: HomeCachedImage(
                  src: service.image.isNotEmpty ? service.image : null,
                  fallback: Container(
                    color: kSurfaceHigh,
                    child: const Icon(Icons.build_rounded, color: kTextLight, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service.name,
                style: const TextStyle(color: kTextDark, fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.north_west_rounded, color: kPrimary.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }
}