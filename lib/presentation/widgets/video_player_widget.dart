import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Report report;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.report,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showReportDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.report.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    'Categoría:',
                    _getCategoryName(widget.report.category),
                  ),
                  _buildDetailItem(
                    'Descripción:',
                    widget.report.description,
                  ),
                  _buildDetailItem(
                    'Dirección:',
                    widget.report.address,
                  ),
                  _buildDetailItem(
                    'Fecha de reporte:',
                    _formatDate(widget.report.createdAt),
                  ),
                  _buildDetailItem(
                    'Estado:',
                    _getStatusName(widget.report.status),
                    valueColor: _getStatusColor(widget.report.status),
                  ),
                  if (widget.report.assignedTechnician != null)
                    _buildDetailItem(
                      'Técnico asignado:',
                      widget.report.assignedTechnician!.name,
                    ),
                  if (widget.report.assignedAt != null)
                    _buildDetailItem(
                      'Fecha de asignación:',
                      _formatDate(widget.report.assignedAt!),
                    ),
                  if (widget.report.resolvedAt != null)
                    _buildDetailItem(
                      'Fecha de resolución:',
                      _formatDate(widget.report.resolvedAt!),
                    ),
                  if (widget.report.resolutionNotes != null)
                    _buildDetailItem(
                      'Notas de resolución:',
                      widget.report.resolutionNotes!,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.lighting:
        return 'Alumbrado';
      case ReportCategory.roadRepair:
        return 'Bacheo';
      case ReportCategory.garbageCollection:
        return 'Recolección de basura';
      case ReportCategory.waterLeaks:
        return 'Fugas de agua';
      case ReportCategory.abandonedVehicles:
        return 'Vehículos abandonados';
      case ReportCategory.noise:
        return 'Exceso de ruido';
      case ReportCategory.animalAbuse:
        return 'Maltrato animal';
      case ReportCategory.insecurity:
        return 'Inseguridad';
      case ReportCategory.stopSignsDamaged:
        return 'Señales de alto dañadas';
      case ReportCategory.trafficLightsDamaged:
        return 'Semáforos dañados';
      case ReportCategory.poorSignage:
        return 'Señalización deficiente';
      case ReportCategory.genderEquity:
        return 'Equidad de género';
      case ReportCategory.disabilityRamps:
        return 'Rampas para discapacitados';
      case ReportCategory.serviceComplaints:
        return 'Quejas de servicio';
      case ReportCategory.other:
        return 'Otros';
    }
  }

  String _getStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.assigned:
        return 'Asignado';
      case ReportStatus.inProgress:
        return 'En progreso';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.assigned:
        return Colors.blue;
      case ReportStatus.inProgress:
        return Colors.purple;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isInitialized) {
          setState(() {
            _isPlaying = !_isPlaying;
            _isPlaying ? _controller.play() : _controller.pause();
          });
        }
      },
      onLongPress: _showReportDetails,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!_isPlaying || !_isInitialized)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 120),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _showReportDetails,
            ),
          ),
        ],
      ),
    );
  }
}
