import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ConnectivityService.instance,
      builder: (context, _) {
        if (ConnectivityService.instance.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'You\'re offline - Viewing cached content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
