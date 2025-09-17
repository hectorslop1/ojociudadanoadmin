import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/utils/status_utils.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class ResolvedCard extends StatelessWidget {
  final String value;
  final String percentageText;
  final VoidCallback? onTap;

  const ResolvedCard({
    super.key,
    required this.value,
    required this.percentageText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and title in a row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: StatusUtils.getStatusBackgroundColor(ReportStatus.resolved),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  StatusUtils.getStatusIcon(ReportStatus.resolved),
                  color: StatusUtils.getStatusColor(ReportStatus.resolved),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                StatusUtils.getStatusName(ReportStatus.resolved),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF616161), // Grey 700
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Value and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: StatusUtils.getStatusColor(ReportStatus.resolved),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: StatusUtils.getStatusBackgroundColor(ReportStatus.resolved),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  percentageText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: StatusUtils.getStatusColor(ReportStatus.resolved),
                  ),
                ),
              ),
            ],
          ),
          
          // Progress bar
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: double.tryParse(percentageText.replaceAll('%', ''))! / 100,
              backgroundColor: StatusUtils.getStatusBackgroundColor(ReportStatus.resolved),
              valueColor: AlwaysStoppedAnimation<Color>(StatusUtils.getStatusColor(ReportStatus.resolved)),
              minHeight: 8.0,
            ),
          ),
        ],
      ),
    );
    
    // Si hay un callback onTap, envolver en InkWell para hacerlo interactivo
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }
    
    // Si no hay callback, devolver el contenido directamente
    return content;
  }
}
