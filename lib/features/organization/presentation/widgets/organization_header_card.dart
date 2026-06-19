import 'package:flutter/material.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';

/// The venue card: a banner image with the organization name and address
/// overlaid at the bottom, matching the mockup.
class OrganizationHeaderCard extends StatelessWidget {
  final Organization organization;

  const OrganizationHeaderCard({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    final imageUrl = organization.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImageFallback(),
                  )
                : const _ImageFallback(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organization.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (organization.addressLine.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    organization.addressLine,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E3B63),
      alignment: Alignment.center,
      child: const Icon(Icons.business, color: Colors.white54, size: 56),
    );
  }
}
