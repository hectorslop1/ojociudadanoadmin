import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/evidence_reel_item.dart';

class EvidenceReelFeed extends StatefulWidget {
  final List<Report> reports;
  final Function()? onRefresh;

  const EvidenceReelFeed({
    super.key,
    required this.reports,
    this.onRefresh,
  });

  @override
  State<EvidenceReelFeed> createState() => _EvidenceReelFeedState();
}

class _EvidenceReelFeedState extends State<EvidenceReelFeed> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar reportes que tienen evidencias
    final reportsWithEvidence = widget.reports.where(
      (report) => report.evidenceUrls.isNotEmpty
    ).toList();

    if (reportsWithEvidence.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: reportsWithEvidence.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final report = reportsWithEvidence[index];
          return EvidenceReelItem(
            report: report,
            isVisible: _currentPage == index,
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay evidencias disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otros filtros',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
