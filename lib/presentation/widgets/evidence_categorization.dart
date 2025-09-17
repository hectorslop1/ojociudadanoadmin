import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';

class EvidenceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const EvidenceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class EvidenceCategorization extends StatefulWidget {
  final String evidenceUrl;
  final List<EvidenceCategory> availableCategories;
  final List<String> initialCategories;
  final Function(List<String>) onCategoriesChanged;

  const EvidenceCategorization({
    super.key,
    required this.evidenceUrl,
    required this.availableCategories,
    required this.onCategoriesChanged,
    this.initialCategories = const [],
  });

  @override
  State<EvidenceCategorization> createState() => _EvidenceCategorizationState();
}

class _EvidenceCategorizationState extends State<EvidenceCategorization> {
  late List<String> _selectedCategories;
  final TextEditingController _newCategoryController = TextEditingController();
  bool _isAddingCategory = false;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.initialCategories);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
      widget.onCategoriesChanged(_selectedCategories);
    });
  }

  void _addCustomCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isNotEmpty) {
      setState(() {
        _selectedCategories.add(newCategory);
        _newCategoryController.clear();
        _isAddingCategory = false;
        widget.onCategoriesChanged(_selectedCategories);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorizar evidencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Previsualización de la evidencia
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildEvidencePreview(),
        ),
        const SizedBox(height: 16),
        
        // Categorías disponibles
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.availableCategories.map((category) {
              final isSelected = _selectedCategories.contains(category.id);
              return _buildCategoryChip(
                category: category,
                isSelected: isSelected,
                onTap: () => _toggleCategory(category.id),
              );
            }),
            
            // Botón para agregar categoría personalizada
            if (!_isAddingCategory)
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Personalizada'),
                onPressed: () {
                  setState(() {
                    _isAddingCategory = true;
                  });
                },
              ),
          ],
        ),
        
        // Campo para agregar categoría personalizada
        if (_isAddingCategory) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    hintText: 'Nueva categoría',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _addCustomCategory(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _addCustomCategory,
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isAddingCategory = false;
                    _newCategoryController.clear();
                  });
                },
                color: Colors.grey,
              ),
            ],
          ),
        ],
        
        // Categorías seleccionadas
        if (_selectedCategories.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Categorías seleccionadas:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedCategories.map((categoryId) {
              // Buscar la categoría en las disponibles
              final category = widget.availableCategories.firstWhere(
                (c) => c.id == categoryId,
                orElse: () => EvidenceCategory(
                  id: categoryId,
                  name: categoryId,
                  icon: Icons.label,
                  color: Colors.grey,
                ),
              );
              
              return Chip(
                avatar: Icon(
                  category.icon,
                  size: 16,
                  color: category.color,
                ),
                label: Text(category.name),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _toggleCategory(categoryId),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEvidencePreview() {
    final isVideo = widget.evidenceUrl.endsWith('.mp4') || 
                    widget.evidenceUrl.endsWith('.mov') || 
                    widget.evidenceUrl.endsWith('.avi');
    
    if (isVideo) {
      return Container(
        height: 120,
        width: double.infinity,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.movie_outlined,
            size: 40,
            color: Colors.white70,
          ),
        ),
      );
    } else {
      return Image.network(
        widget.evidenceUrl,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildCategoryChip({
    required EvidenceCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      avatar: Icon(
        category.icon,
        size: 16,
        color: isSelected ? Colors.white : category.color,
      ),
      label: Text(category.name),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: category.color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

// Categorías predefinidas para evidencias
class PredefinedEvidenceCategories {
  static const List<EvidenceCategory> categories = [
    EvidenceCategory(
      id: 'damage',
      name: 'Daño',
      icon: Icons.broken_image,
      color: Colors.red,
    ),
    EvidenceCategory(
      id: 'before',
      name: 'Antes',
      icon: Icons.arrow_back,
      color: Colors.orange,
    ),
    EvidenceCategory(
      id: 'after',
      name: 'Después',
      icon: Icons.arrow_forward,
      color: Colors.green,
    ),
    EvidenceCategory(
      id: 'location',
      name: 'Ubicación',
      icon: Icons.location_on,
      color: Colors.blue,
    ),
    EvidenceCategory(
      id: 'context',
      name: 'Contexto',
      icon: Icons.landscape,
      color: Colors.purple,
    ),
    EvidenceCategory(
      id: 'closeup',
      name: 'Primer plano',
      icon: Icons.zoom_in,
      color: Colors.teal,
    ),
    EvidenceCategory(
      id: 'panoramic',
      name: 'Panorámica',
      icon: Icons.panorama,
      color: Colors.indigo,
    ),
    EvidenceCategory(
      id: 'important',
      name: 'Importante',
      icon: Icons.star,
      color: AppColors.warning,
    ),
  ];
}
