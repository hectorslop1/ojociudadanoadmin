import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/evidence_reel_item.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';

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

class _EvidenceReelFeedState extends State<EvidenceReelFeed> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  
  // Filtros
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;
  
  // Controlador para animación de panel lateral
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  
  // Estado del panel de filtros
  bool _showStatusFilter = false;
  
  // Estado para el bottom sheet
  ReportCategory? _bottomSheetCategory;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Inicializar controlador de animación
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  // Aplicar filtros a los reportes
  List<Report> _getFilteredReports() {
    // Primero filtrar reportes que tienen evidencias
    List<Report> filteredReports = widget.reports.where(
      (report) => report.evidenceUrls.isNotEmpty
    ).toList();
    
    // Aplicar filtro de categoría si está seleccionado
    if (_selectedCategory != null) {
      filteredReports = filteredReports.where(
        (report) => report.category == _selectedCategory
      ).toList();
    }
    
    // Aplicar filtro de estatus si está seleccionado
    if (_selectedStatus != null) {
      filteredReports = filteredReports.where(
        (report) => report.status == _selectedStatus
      ).toList();
    }
    
    return filteredReports;
  }
  
  // Mostrar bottom sheet de categorías
  void _toggleCategoryFilter() {
    // Mostrar bottom sheet en lugar del panel lateral
    _showCategoryBottomSheet(context);
  }
  
  // Mostrar/ocultar filtro de estatus
  void _toggleStatusFilter() {
    setState(() {
      _showStatusFilter = !_showStatusFilter;
    });
    
    if (_showStatusFilter) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }
  
  // Seleccionar una categoría desde el bottom sheet
  void _selectCategoryFromBottomSheet(ReportCategory category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null; // Deseleccionar si ya estaba seleccionada
      } else {
        _selectedCategory = category;
      }
    });
  }
  
  // Seleccionar un estatus
  void _selectStatus(ReportStatus status) {
    setState(() {
      if (_selectedStatus == status) {
        _selectedStatus = null; // Deseleccionar si ya estaba seleccionado
      } else {
        _selectedStatus = status;
      }
      _showStatusFilter = false; // Cerrar el panel
    });
    _filterAnimationController.reverse();
  }
  
  // Obtener nombre legible de la categoría
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
  
  // Obtener nombre legible del estatus
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
  
  // Obtener color para el estatus
  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.assigned:
        return Colors.blue;
      case ReportStatus.inProgress:
        return Colors.amber;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }
  
  // Obtener icono para la categoría
  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return Icons.construction;
      case ReportCategory.garbageCollection:
        return Icons.delete_outline;
      case ReportCategory.streetImprovement:
        return Icons.home_repair_service;
    }
  }
  
  // Obtener color para la categoría
  Color _getCategoryColor(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return Colors.brown.shade600;
      case ReportCategory.garbageCollection:
        return Colors.green.shade800;
      case ReportCategory.streetImprovement:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener reportes filtrados
    final filteredReports = _getFilteredReports();

    if (filteredReports.isEmpty) {
      return _buildEmptyView();
    }

    return Stack(
      children: [
        // Feed principal de evidencias
        RefreshIndicator(
          onRefresh: () async {
            if (widget.onRefresh != null) {
              widget.onRefresh!();
            }
          },
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: filteredReports.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final report = filteredReports[index];
              return EvidenceReelItem(
                report: report,
                isVisible: _currentPage == index,
              );
            },
          ),
        ),
        
        // Indicador de página (centrado)
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentPage + 1}/${filteredReports.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        
        // Botón de filtro de categoría
        Positioned(
          right: 12, // Vuelto a la derecha
          top: MediaQuery.of(context).size.height * 0.35, // Ajustado más abajo
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color.fromRGBO(255, 255, 255, 0.35), // Opacidad ajustada al 35%
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de categoría más pequeño
                _buildFilterButton(
                  icon: Icons.category_outlined,
                  label: 'Categoría',
                  isSelected: _selectedCategory != null,
                  onTap: _toggleCategoryFilter,
                ),
              ],
            ),
          ),
        ),
        
        // Panel de filtro de estatus (mantenemos este como panel lateral)
        if (_showStatusFilter)
          _buildStatusFilterPanel(),
      ],
    );
  }

  // Vista vacía cuando no hay evidencias
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
          if (_selectedCategory != null || _selectedStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedStatus = null;
                  });
                },
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Quitar filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Botón de filtro vertical
  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        width: 70, // Ancho reducido para un botón más pequeño
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade700,
              size: 20, // Icono más pequeño
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade800,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Método para mostrar el bottom sheet de categorías
  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCategoryBottomSheet(context),
    );
  }
  
  // Construir el bottom sheet de categorías
  Widget _buildCategoryBottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra superior con título y botón de cerrar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explorar Evidencias',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.reports.where((r) => r.evidenceUrls.isNotEmpty).length} evidencias disponibles',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar evidencias...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          
          // Categorías en grid
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.8, // Mucho más ancho que alto (más rectangular)
              children: _buildCategoryGridItems(),
            ),
          ),
          
          // Título de sección de evidencias
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Evidencias Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Lista de evidencias
          Expanded(
            child: _bottomSheetCategory != null
                ? _buildCategoryEvidenceGrid(_bottomSheetCategory!)
                : _buildAllEvidenceGrid(),
          ),
        ],
      ),
    );
  }
  
  // Construir los items de categoría para el grid
  List<Widget> _buildCategoryGridItems() {
    // Agrupar reportes por categoría y contar
    Map<ReportCategory, int> categoryCounts = {};
    for (var report in widget.reports) {
      if (report.evidenceUrls.isNotEmpty) {
        categoryCounts[report.category] = (categoryCounts[report.category] ?? 0) + 1;
      }
    }
    
    // Crear widgets para las categorías más comunes
    List<Widget> categoryWidgets = [];
    
    // Añadir categoría "Todos"
    categoryWidgets.add(
      GestureDetector(
        onTap: () {
          setState(() {
            _bottomSheetCategory = null;
            _selectedCategory = null;
          });
          Navigator.pop(context);
          _showCategoryBottomSheet(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(27, 94, 32, 0.2), // Equivalente a Colors.green.shade600 con 20% de opacidad
            border: Border.all(
              color: Colors.green.shade600,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_view_rounded,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80), // Ancho máximo para el texto
                    child: Text(
                      'Todos',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.reports.where((r) => r.evidenceUrls.isNotEmpty).length}',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    // Añadir otras categorías con más reportes
    categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5).forEach((entry) {
        final category = entry.key;
        final count = entry.value;
        final color = _getCategoryColor(category);
        
        categoryWidgets.add(
          GestureDetector(
            onTap: () {
              setState(() {
                _bottomSheetCategory = category;
                _selectedCategory = category;
              });
              Navigator.pop(context);
              _showCategoryBottomSheet(context);
              _selectCategoryFromBottomSheet(category);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: color.withAlpha((0.2 * 255).toInt()), // Fondo con 20% de opacidad
                border: Border.all(
                  color: color,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80), // Ancho máximo para el texto
                        child: Text(
                          _getCategoryName(category),
                          style: TextStyle(
                            color: color.withAlpha((0.9 * 255).toInt()),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count',
                        style: TextStyle(
                          color: color.withAlpha((0.9 * 255).toInt()),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
    
    return categoryWidgets;
  }
  
  // Construir grid de todas las evidencias
  Widget _buildAllEvidenceGrid() {
    final reportsWithEvidence = widget.reports.where(
      (report) => report.evidenceUrls.isNotEmpty
    ).toList();
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: reportsWithEvidence.length,
      itemBuilder: (context, index) {
        final report = reportsWithEvidence[index];
        return _buildEvidenceGridItem(report);
      },
    );
  }
  
  // Construir grid de evidencias filtradas por categoría
  Widget _buildCategoryEvidenceGrid(ReportCategory category) {
    final reportsWithEvidence = widget.reports.where(
      (report) => report.evidenceUrls.isNotEmpty && report.category == category
    ).toList();
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: reportsWithEvidence.length,
      itemBuilder: (context, index) {
        final report = reportsWithEvidence[index];
        return _buildEvidenceGridItem(report);
      },
    );
  }
  
  // Construir item de evidencia para el grid
  Widget _buildEvidenceGridItem(Report report) {
    final evidenceUrl = report.evidenceUrls.first;
    final isVideo = _isVideo(evidenceUrl);
    
    return GestureDetector(
      onTap: () {
        // Cerrar bottom sheet y navegar a la evidencia seleccionada
        Navigator.pop(context);
        final filteredReports = _getFilteredReports();
        final index = filteredReports.indexOf(report);
        if (index != -1) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen o placeholder de video
            isVideo
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : Image.network(
                    evidenceUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
            
            // Gradiente inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color.fromRGBO(0, 0, 0, 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Información del reporte
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador de estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusName(report.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Título del reporte
                  Text(
                    report.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Indicador de video
            if (isVideo)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Verificar si una URL es de video
  bool _isVideo(String url) {
    return url.endsWith('.mp4') || 
           url.endsWith('.mov') || 
           url.endsWith('.avi') ||
           url.endsWith('.webm');
  }
  
  // Panel de filtro de estatus
  Widget _buildStatusFilterPanel() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return Positioned(
          right: 16 + 80 * _filterAnimation.value,
          top: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Opacity(
            opacity: _filterAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del panel
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtrar por estatus',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _toggleStatusFilter,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Lista de estatus
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: ReportStatus.values.map((status) {
                        final isSelected = _selectedStatus == status;
                        final statusColor = _getStatusColor(status);
                        return ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(_getStatusName(status)),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: statusColor)
                              : null,
                          onTap: () => _selectStatus(status),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
