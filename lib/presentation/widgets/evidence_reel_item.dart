import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/report_detail_page.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/core/utils/logger_utils.dart';

class EvidenceReelItem extends StatefulWidget {
  final Report report;
  final bool isVisible;

  const EvidenceReelItem({
    super.key,
    required this.report,
    this.isVisible = false,
  });

  @override
  State<EvidenceReelItem> createState() => _EvidenceReelItemState();
}

class _EvidenceReelItemState extends State<EvidenceReelItem> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _showDetails = false;
  int _currentMediaIndex = 0;
  final PageController _mediaPageController = PageController();
  
  // Lista ordenada de evidencias (videos primero, luego imágenes)
  List<String> _sortedEvidenceUrls = [];

  @override
  void initState() {
    super.initState();
    _sortEvidenceUrls();
    _initializeMedia();
  }
  
  void _sortEvidenceUrls() {
    if (widget.report.evidenceUrls.isEmpty) return;
    
    // Separar videos e imágenes
    List<String> videos = [];
    List<String> images = [];
    
    for (String url in widget.report.evidenceUrls) {
      if (_isVideo(url)) {
        videos.add(url);
      } else {
        images.add(url);
      }
    }
    
    // Ordenar con videos primero, luego imágenes
    _sortedEvidenceUrls = [...videos, ...images];
  }

  @override
  void didUpdateWidget(EvidenceReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si la visibilidad cambió, actualizamos el estado del reproductor
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    }
  }

  void _initializeMedia() {
    // Verificar si hay evidencias disponibles
    if (_sortedEvidenceUrls.isEmpty) return;

    // Obtener la URL de evidencia actual
    final String evidenceUrl = _sortedEvidenceUrls[_currentMediaIndex];
    
    // Verificar si es un video
    if (_isVideo(evidenceUrl)) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(evidenceUrl))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
                // Reproducir automáticamente si el widget es visible
                if (widget.isVisible) {
                  _videoController!.play();
                  _videoController!.setLooping(true);
                }
              });
            }
          }).catchError((error) {
            LoggerUtils.e('Error inicializando video', error);
            if (mounted) {
              setState(() {
                _isInitialized = false;
              });
            }
          });
      } catch (e) {
        LoggerUtils.e('Excepción al crear VideoPlayerController', e);
      }
    } else {
      // Si no es un video, marcamos como inicializado para mostrar la imagen
      setState(() {
        _isInitialized = true;
      });
    }
  }

  bool _isVideo(String url) {
    return url.endsWith('.mp4') || 
           url.endsWith('.mov') || 
           url.endsWith('.avi') ||
           url.endsWith('.webm');
  }

  void _playVideo() {
    if (_videoController != null && _isInitialized) {
      _videoController!.play();
    }
  }

  void _pauseVideo() {
    if (_videoController != null && _isInitialized) {
      _videoController!.pause();
    }
  }
  
  void _onPageChanged(int index) {
    // Pausar el video actual si existe
    _pauseVideo();
    
    setState(() {
      _currentMediaIndex = index;
      _isInitialized = false;
    });
    
    // Liberar el controlador anterior
    if (_videoController != null) {
      final oldController = _videoController;
      // Usar Future para evitar problemas de estado durante la disposición
      Future.delayed(Duration.zero, () {
        oldController!.dispose();
      });
      _videoController = null;
    }
    
    // Inicializar el nuevo medio
    final String newEvidenceUrl = _sortedEvidenceUrls[index];
    if (_isVideo(newEvidenceUrl)) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(newEvidenceUrl))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
                // Reproducir automáticamente si el widget es visible
                if (widget.isVisible) {
                  _videoController!.play();
                  _videoController!.setLooping(true);
                }
              });
            }
          }).catchError((error) {
            LoggerUtils.e('Error al inicializar video en cambio de página', error);
            if (mounted) {
              setState(() {
                _isInitialized = false;
              });
            }
          });
      } catch (e) {
        LoggerUtils.e('Excepción al crear VideoPlayerController en cambio de página', e);
      }
    } else {
      // Si es una imagen, marcamos como inicializado
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  void _navigateToDetails() {
    // Pausar el video antes de navegar
    if (_videoController != null && _isInitialized && _videoController!.value.isPlaying) {
      _videoController!.pause();
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportDetailPage(reportId: widget.report.id),
      ),
    ).then((_) {
      // Al regresar de la página de detalles, verificar si debemos reproducir el video
      if (widget.isVisible && _videoController != null && _isInitialized) {
        // Solo reproducir si el widget sigue siendo visible
        if (mounted && widget.isVisible) {
          _videoController!.play();
        }
      }
    });
  }

  @override
  void dispose() {
    // Asegurarnos de pausar el video antes de liberar recursos
    if (_videoController != null) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      }
      _videoController!.dispose();
      _videoController = null;
    }
    _mediaPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay evidencias disponibles
    if (_sortedEvidenceUrls.isEmpty) {
      return _buildNoEvidenceView();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // PageView para navegar horizontalmente entre evidencias
        PageView.builder(
          controller: _mediaPageController,
          onPageChanged: _onPageChanged,
          itemCount: _sortedEvidenceUrls.length,
          itemBuilder: (context, index) {
            final String mediaUrl = _sortedEvidenceUrls[index];
            final bool isCurrentVideo = _isVideo(mediaUrl) && index == _currentMediaIndex;
            
            return Stack(
              fit: StackFit.expand,
              children: [
                // Contenido principal (video o imagen)
                isCurrentVideo && _videoController != null && _isInitialized
                    ? GestureDetector(
                        onTap: () {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        },
                        child: Container(
                          color: Colors.black,  // Fondo negro para evitar transparencias extrañas
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        ),
                      )
                    : _isVideo(mediaUrl) 
                        ? Container(
                            color: Colors.black,  // Fondo negro consistente
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 60,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.black, // Fondo negro para imágenes, igual que videos
                            child: Image.network(
                              mediaUrl,
                              fit: BoxFit.contain,  // Mantiene la relación de aspecto
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.black, // Fondo negro para errores también
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[900] 
                                      : Colors.grey[100],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                      
                // Indicador de video
                if (_isVideo(mediaUrl) && index != _currentMediaIndex)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 128), // 0.5 * 255 = 128
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Gradiente inferior para mejorar legibilidad
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 179), // 0.7 * 255 = 179
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Información y botón de detalles
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Información básica siempre visible
              Row(
                children: [
                  _buildStatusIndicator(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getCategoryName(widget.report.category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Descripción breve
              Text(
                widget.report.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Panel de detalles expandible
              if (_showDetails) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 128), // 0.5 * 255 = 128
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubicación: ${widget.report.address}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${_formatDate(widget.report.createdAt)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estado: ${_getStatusName(widget.report.status)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _navigateToDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.light
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: const Text('Ver reporte completo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Botón para mostrar/ocultar detalles
              Center(
                child: ElevatedButton.icon(
                  onPressed: _toggleDetails,
                  icon: Icon(
                    _showDetails ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: Colors.white,
                  ),
                  label: Text(
                    _showDetails ? 'Ocultar detalles' : 'Mostrar detalles',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 128), // 0.5 * 255 = 128
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Indicador de posición de evidencias
        if (_sortedEvidenceUrls.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 153), // 0.6 * 255 = 153
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentMediaIndex + 1}/${_sortedEvidenceUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
        // Indicadores de navegación lateral si hay múltiples evidencias
        if (_sortedEvidenceUrls.length > 1) ...[  
          // No se muestra el indicador de deslizar
        ],
      ],
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    switch (widget.report.status) {
      case ReportStatus.pending:
        statusColor = AppColors.warning;
        break;
      case ReportStatus.assigned:
        statusColor = AppColors.info;
        break;
      case ReportStatus.inProgress:
        statusColor = Theme.of(context).brightness == Brightness.light
            ? AppColors.primary
            : AppColors.primaryDark;
        break;
      case ReportStatus.resolved:
        statusColor = AppColors.success;
        break;
      case ReportStatus.rejected:
        statusColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusName(widget.report.status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildNoEvidenceView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'No hay evidencias disponibles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 'Bacheo';
      case ReportCategory.garbageCollection:
        return 'Recolección de Basura';
      case ReportCategory.streetImprovement:
        return 'Mejoramiento de Calles';
    }
  }

  String _getStatusName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.assigned:
        return 'Asignado';
      case ReportStatus.inProgress:
        return 'En Progreso';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.rejected:
        return 'Rechazado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
