import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/background_controller.dart';

class CommandHelper extends StatelessWidget {
  const CommandHelper({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 200,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        onPressed: () => _showCommands(context),
        child: const Icon(Icons.help_outline),
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showCommands(BuildContext context) {
    final controller = Get.find<BackgroundController>(tag: 'background');
    final themes = controller.availableThemes.keys.toList();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Comandos Disponibles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildCommandItem(
              'Cambiar Color',
              'cambia el color a [tema]',
              Icons.palette,
              () => Navigator.pop(context),
            ),
            _buildCommandItem(
              'Nuevo Chat',
              'nuevo chat',
              Icons.refresh,
              () => Navigator.pop(context),
            ),
            _buildCommandItem(
              'Ver Temas',
              'temas disponibles',
              Icons.color_lens,
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Temas disponibles:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: themes.map((theme) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    theme,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandItem(String title, String command, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        command,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
