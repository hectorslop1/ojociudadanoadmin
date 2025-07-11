import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_colors.dart';
import 'package:ojo_ciudadano_admin/domain/entities/administrator.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_state.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_event.dart' as theme_events;
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_state.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/change_password_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _positionController;
  bool _isDarkMode = false;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _departmentController = TextEditingController();
    _positionController = TextEditingController();
    
    // Cargar datos del administrador actual
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _loadAdministratorData(authState.administrator);
      _isDarkMode = authState.administrator.isDarkThemeEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _loadAdministratorData(Administrator administrator) {
    _nameController.text = administrator.name;
    _emailController.text = administrator.email;
    // Los campos phone, department y position no existen en la entidad Administrator
    // pero mantenemos los controladores para la interfaz de usuario
    _phoneController.text = '';
    _departmentController.text = '';
    _positionController.text = '';
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Obtener el administrador actual
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final currentAdmin = authState.administrator;
        
        // Enviar evento para actualizar el perfil
        context.read<AuthBloc>().add(
          UpdateProfileEvent(
            name: _nameController.text,
            profileImageUrl: currentAdmin.profileImageUrl,
          ),
        );
      }

      // Desactivar modo edición
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _toggleTheme() {
    // No necesitamos actualizar el estado local aquí, ya que el BlocBuilder se encargará de eso
    final newThemeValue = !_isDarkMode;
    
    // Enviar evento para actualizar el tema al ThemeBloc
    context.read<ThemeBloc>().add(
      theme_events.UpdateThemeEvent(isDarkTheme: newThemeValue),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el estado actual del tema desde el ThemeBloc
    final themeState = context.watch<ThemeBloc>().state;
    final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkTheme : false;
    
    // Sincronizar el estado local con el estado del tema
    if (_isDarkMode != isDarkMode) {
      _isDarkMode = isDarkMode;
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } else if (state is ThemeUpdated) {
          setState(() {
            _isDarkMode = state.isDarkTheme;
            _isLoading = false;
          });
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado del perfil
                _buildProfileHeader(),
                const SizedBox(height: 24),

                // Formulario de datos personales
                _buildProfileForm(),
                const SizedBox(height: 24),

                // Configuraciones adicionales
                _buildSettingsSection(),
                const SizedBox(height: 24),

                // Botón de cerrar sesión
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Avatar del usuario
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primaryDark.withValues(alpha: 0.2),
                backgroundImage: _getProfileImage(),
                child: _getProfileImage() == null ? Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.primary
                      : AppColors.primaryDark,
                ) : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.primary
                          : AppColors.primaryDark,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Nombre y correo
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Botón de editar perfil
          OutlinedButton.icon(
            onPressed: _isLoading ? null : _toggleEditMode,
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            label: Text(_isEditing ? 'Cancelar' : 'Editar Perfil'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para obtener la imagen de perfil del administrador
  ImageProvider? _getProfileImage() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.administrator.profileImageUrl != null) {
      return NetworkImage(authState.administrator.profileImageUrl!);
    }
    return null;
  }

  // Método para obtener el nombre del rol del administrador
  String _getRoleName() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      switch (authState.administrator.role) {
        case AdministratorRole.superAdmin:
          return 'Super Administrador';
        case AdministratorRole.admin:
          return 'Administrador';
        case AdministratorRole.supervisor:
          return 'Supervisor';
      }
    }
    return 'Usuario';
  }

  // Método para construir la sección de configuraciones
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuraciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Cambiar contraseña
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Cambiar Contraseña'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showChangePasswordDialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          tileColor: Colors.grey.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 8),
        
        // Cambiar tema
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            bool isDarkMode = false;
            if (state is ThemeLoaded) {
              isDarkMode = state.isDarkTheme;
            }
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SwitchListTile(
                title: const Text(
                  'Tema Oscuro',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  isDarkMode ? 'Activado' : 'Desactivado',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
                value: isDarkMode,
                onChanged: (value) => _toggleTheme(),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                      ? AppColors.actionButton.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? AppColors.actionButton : AppColors.primary,
                    size: 20,
                  ),
                ),
                activeColor: AppColors.actionButton,
                activeTrackColor: AppColors.actionButton.withValues(alpha: 0.5),
                inactiveThumbColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.primary
                    : AppColors.primaryDark,
                inactiveTrackColor: Colors.grey[400],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nombre completo
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Correo electrónico
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!value.contains('@')) {
                return 'Por favor ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Rol del administrador
          TextFormField(
            controller: TextEditingController(text: _getRoleName()),
            decoration: const InputDecoration(
              labelText: 'Rol',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.admin_panel_settings),
            ),
            enabled: false,
          ),
          const SizedBox(height: 24),
          
          // Botón de guardar
          if (_isEditing)
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
