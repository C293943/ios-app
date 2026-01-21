import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/common/glass_container.dart';

/// 个人信息页面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedVoice = '默认女声';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '个人信息',
          style: GoogleFonts.notoSerifSc(
            color: AppTheme.warmYellow,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.warmYellow),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MysticBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          children: [
            // 用户编号
            _buildProfileItem(
              icon: Icons.person_outline,
              label: '用户编号',
              value: 'USR20250121001',
            ),
            const SizedBox(height: 12),

            // 用户等级
            _buildProfileItem(
              icon: Icons.star_outline,
              label: '用户等级',
              value: 'VIP 0',
            ),
            const SizedBox(height: 12),

            // 档案
            _buildProfileItem(
              icon: Icons.description_outlined,
              label: '档案',
              value: '查看详情',
              onTap: () => _showArchiveDialog(context),
            ),
            const SizedBox(height: 12),

            // 会员充值
            _buildProfileItem(
              icon: Icons.card_giftcard,
              label: '会员充值',
              value: '前往充值',
              onTap: () => _showRechargeDialog(context),
            ),
            const SizedBox(height: 12),

            // 语音选择
            _buildProfileItem(
              icon: Icons.volume_up_outlined,
              label: '语音选择',
              value: _selectedVoice,
              onTap: () => _showVoiceDialog(context),
            ),
            const SizedBox(height: 12),

            // 用户反馈
            _buildProfileItem(
              icon: Icons.feedback_outlined,
              label: '用户反馈',
              value: '提交反馈',
              onTap: () => _showFeedbackDialog(context),
            ),
            const SizedBox(height: 12),

            // 隐私协议
            _buildProfileItem(
              icon: Icons.privacy_tip_outlined,
              label: '隐私协议',
              value: '查看',
              onTap: () => _showPrivacyDialog(context),
            ),
            const SizedBox(height: 12),

            // 充值协议
            _buildProfileItem(
              icon: Icons.receipt_outlined,
              label: '充值协议',
              value: '查看',
              onTap: () => _showRechargeAgreementDialog(context),
            ),
            const SizedBox(height: 12),

            // 用户协议
            _buildProfileItem(
              icon: Icons.description,
              label: '用户协议',
              value: '查看',
              onTap: () => _showUserAgreementDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GlassContainer(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.warmYellow, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.notoSerifSc(
                      color: AppTheme.warmYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.notoSerifSc(
                    color: AppTheme.fluorescentCyan,
                    fontSize: 13,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios,
                    color: AppTheme.fluorescentCyan,
                    size: 14,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          '档案信息',
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogItem('姓名', '未设置'),
              _buildDialogItem('性别', '未设置'),
              _buildDialogItem('出生地', '未设置'),
              _buildDialogItem('出生时间', '-- -- -- --:--'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '关闭',
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          '会员充值',
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: Text(
          '充值功能开发中...',
          style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '确定',
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showVoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          '语音选择',
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVoiceOption('默认女声'),
            _buildVoiceOption('温柔女声'),
            _buildVoiceOption('磁性男声'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '确定',
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceOption(String voice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Radio<String>(
            value: voice,
            groupValue: _selectedVoice,
            onChanged: (value) {
              setState(() => _selectedVoice = value ?? '默认女声');
              Navigator.pop(context);
            },
            activeColor: AppTheme.fluorescentCyan,
          ),
          Text(
            voice,
            style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          '用户反馈',
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
          decoration: InputDecoration(
            hintText: '请输入您的反馈意见...',
            hintStyle: GoogleFonts.notoSerifSc(
              color: AppTheme.fluorescentCyan.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppTheme.fluorescentCyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '提交',
              style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    _showAgreementDialog(context, '隐私协议', _getPrivacyContent());
  }

  void _showRechargeAgreementDialog(BuildContext context) {
    _showAgreementDialog(context, '充值协议', _getRechargeAgreementContent());
  }

  void _showUserAgreementDialog(BuildContext context) {
    _showAgreementDialog(context, '用户协议', _getUserAgreementContent());
  }

  void _showAgreementDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.voidBackground.withValues(alpha: 0.9),
        title: Text(
          title,
          style: GoogleFonts.notoSerifSc(color: AppTheme.warmYellow),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.fluorescentCyan,
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '关闭',
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrivacyContent() {
    return '''隐私政策

本应用尊重并保护用户的隐私。我们承诺：

1. 数据收集
   - 仅收集必要的个人信息
   - 不会未经同意收集敏感信息

2. 数据使用
   - 仅用于提供服务
   - 不会用于商业目的

3. 数据保护
   - 采用加密技术保护数据
   - 定期进行安全审计

4. 用户权利
   - 有权查看个人数据
   - 有权要求删除数据

如有疑问，请联系我们。''';
  }

  String _getRechargeAgreementContent() {
    return '''充值协议

1. 充值说明
   - 充值金额为虚拟货币
   - 不支持退款

2. 充值方式
   - 支持多种支付方式
   - 实时到账

3. 充值权益
   - 获得相应虚拟货币
   - 享受会员权益

4. 免责声明
   - 因网络问题导致的充值延迟不承担责任
   - 用户自行保管账户信息

5. 其他
   - 本协议最终解释权归本应用所有
   - 保留修改权利''';
  }

  String _getUserAgreementContent() {
    return '''用户协议

1. 服务条款
   - 本应用提供占卜、命理等娱乐服务
   - 仅供娱乐参考，不作为决策依据

2. 用户责任
   - 用户应遵守法律法规
   - 不得进行违法违规操作

3. 知识产权
   - 所有内容版权归本应用所有
   - 未经许可不得转载

4. 免责声明
   - 本应用不对服务结果负责
   - 用户自行承担使用风险

5. 服务变更
   - 保留随时修改或终止服务的权利
   - 将提前通知用户

6. 联系方式
   - 如有问题，请通过反馈功能联系我们''';
  }

  Widget _buildDialogItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.notoSerifSc(
              color: AppTheme.warmYellow,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSerifSc(color: AppTheme.fluorescentCyan),
            ),
          ),
        ],
      ),
    );
  }
}
