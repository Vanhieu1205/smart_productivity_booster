import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_event.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../../theme/app_theme.dart';

/// Placeholder cho màn hình Cài đặt (chỉ theme + ngôn ngữ — khớp [SettingsBloc] hiện tại)
class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final isDarkMode = state.isDarkMode;
          final languageCode = state.languageCode;
          return ListView(
            children: [
              _sectionHeader('Giao diện'),
              SwitchListTile(
                title: const Text('Chế độ tối'),
                subtitle: const Text('Bật/tắt Dark Mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: isDarkMode,
                onChanged: (value) =>
                    context.read<SettingsBloc>().add(ToggleDarkMode(value)),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Ngôn ngữ'),
                trailing: DropdownButton<String>(
                  value: languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (code) {
                    if (code != null) {
                      context.read<SettingsBloc>().add(ChangeLanguage(code));
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
