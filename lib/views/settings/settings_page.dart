import 'package:flutter/material.dart';
import '../../shared/utils/ui_helper.dart';
import '../../shared/constants/app_constants.dart';
import '../../utils/html_capture_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => UIHelper.navigateBack(context: context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 정보 섹션
            _AppInfoSection(),
            
            SizedBox(height: AppConstants.paddingL),
            Divider(),
            SizedBox(height: AppConstants.paddingL),
            
            // HTML 캡처 설정 섹션
            HtmlCaptureSettingsWidget(),
            
            SizedBox(height: AppConstants.paddingL),
            Divider(),
            SizedBox(height: AppConstants.paddingL),
            
            // 고급 설정 섹션
            _AdvancedSettingsSection(),
          ],
        ),
      ),
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: AppConstants.iconM,
                ),
                const SizedBox(width: AppConstants.paddingS),
                const Text(
                  '앱 정보',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            _InfoRow('앱 이름', AppConstants.appName),
            _InfoRow('버전', AppConstants.appVersion),
            _InfoRow('Bundle ID', AppConstants.bundleId),
            _InfoRow('서버 주소', AppConstants.apiUrl),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.fontM,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingS),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppConstants.fontM,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedSettingsSection extends StatelessWidget {
  const _AdvancedSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).primaryColor,
                  size: AppConstants.iconM,
                ),
                const SizedBox(width: AppConstants.paddingS),
                const Text(
                  '고급 설정',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('캐시 삭제'),
              subtitle: const Text('임시 저장된 데이터를 삭제합니다'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearCacheDialog(context),
            ),
            
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('설정 초기화'),
              subtitle: const Text('모든 설정을 기본값으로 되돌립니다'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showResetSettingsDialog(context),
            ),
            
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('디버그 정보'),
              subtitle: const Text('개발자용 디버그 정보를 확인합니다'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDebugInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) async {
    final confirmed = await UIHelper.showConfirmDialog(
      context: context,
      title: '캐시 삭제',
      content: '임시 저장된 모든 데이터를 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
    );

    if (confirmed) {
      // TODO: 실제 캐시 삭제 로직 구현
      UIHelper.showSuccessSnack('캐시가 삭제되었습니다.', context: context);
    }
  }

  void _showResetSettingsDialog(BuildContext context) async {
    final confirmed = await UIHelper.showConfirmDialog(
      context: context,
      title: '설정 초기화',
      content: '모든 설정을 기본값으로 되돌리시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '초기화',
      cancelText: '취소',
    );

    if (confirmed) {
      try {
        await HtmlCaptureSettings.resetSettings();
        UIHelper.showSuccessSnack('설정이 초기화되었습니다.', context: context);
      } catch (e) {
        UIHelper.showErrorSnack('설정 초기화에 실패했습니다.', context: context);
      }
    }
  }

  void _showDebugInfo(BuildContext context) {
    UIHelper.showDialogBox(
      context: context,
      title: '디버그 정보',
      content: '앱 이름: ${AppConstants.appName}\n'
          '버전: ${AppConstants.appVersion}\n'
          '빌드 모드: ${const bool.fromEnvironment('dart.vm.product') ? 'Release' : 'Debug'}\n'
          '서버: ${AppConstants.apiUrl}\n'
          '플랫폼: ${Theme.of(context).platform.name}',
    );
  }
}

// HTML 캡처 설정 위젯 (기존 코드를 그대로 사용)
class HtmlCaptureSettingsWidget extends StatefulWidget {
  const HtmlCaptureSettingsWidget({super.key});

  @override
  State<HtmlCaptureSettingsWidget> createState() => _HtmlCaptureSettingsWidgetState();
}

class _HtmlCaptureSettingsWidgetState extends State<HtmlCaptureSettingsWidget> {
  CaptureMode _currentMode = CaptureMode.productSections;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    try {
      final mode = await HtmlCaptureSettings.getCaptureMode();
      if (mounted) {
        setState(() {
          _currentMode = mode;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ HTML 캡처 설정 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateCaptureMode(CaptureMode mode) async {
    try {
      await HtmlCaptureSettings.setCaptureMode(mode);
      if (mounted) {
        setState(() {
          _currentMode = mode;
        });
        
        // 사용자에게 변경 확인 메시지 표시
        UIHelper.showSuccessSnack(
          'HTML 캡처 모드가 "${mode.displayName}"으로 변경되었습니다',
          context: context,
          seconds: 2,
        );
        
        // 디버그 로그
        await HtmlCaptureSettings.printCurrentSettings();
      }
    } catch (e) {
      print('❌ HTML 캡처 설정 저장 실패: $e');
      if (mounted) {
        UIHelper.showErrorSnack(
          '설정 저장에 실패했습니다',
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.web, color: Colors.blue),
                const SizedBox(width: AppConstants.paddingS),
                const Text(
                  'HTML 캡처 설정',
                  style: TextStyle(
                    fontSize: AppConstants.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            const Text(
              '주문 버튼 클릭 시 서버로 전송할 HTML 데이터 범위를 선택하세요.',
              style: TextStyle(
                fontSize: AppConstants.fontM,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // 핵심 정보만 옵션
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentMode == CaptureMode.productSections
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: RadioListTile<CaptureMode>(
                value: CaptureMode.productSections,
                groupValue: _currentMode,
                onChanged: _isLoading ? null : (value) {
                  if (value != null) {
                    _updateCaptureMode(value);
                  }
                },
                title: Row(
                  children: [
                    const Icon(Icons.list_alt, size: 20, color: Colors.green),
                    const SizedBox(width: AppConstants.paddingS),
                    Text(
                      CaptureMode.productSections.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: const Text(
                        '권장',
                        style: TextStyle(
                          fontSize: AppConstants.fontXS,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  CaptureMode.productSections.description,
                  style: const TextStyle(fontSize: AppConstants.fontS),
                ),
                activeColor: Colors.blue,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingS),
            
            // 전체 HTML 옵션
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentMode == CaptureMode.fullHtml
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: RadioListTile<CaptureMode>(
                value: CaptureMode.fullHtml,
                groupValue: _currentMode,
                onChanged: _isLoading ? null : (value) {
                  if (value != null) {
                    _updateCaptureMode(value);
                  }
                },
                title: Row(
                  children: [
                    const Icon(Icons.code, size: 20, color: Colors.orange),
                    const SizedBox(width: AppConstants.paddingS),
                    Text(
                      CaptureMode.fullHtml.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                subtitle: Text(
                  CaptureMode.fullHtml.description,
                  style: const TextStyle(fontSize: AppConstants.fontS),
                ),
                activeColor: Colors.blue,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // 현재 설정 표시
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingS),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: Text(
                      '현재 설정: ${_currentMode.displayName}',
                      style: TextStyle(
                        fontSize: AppConstants.fontS,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}