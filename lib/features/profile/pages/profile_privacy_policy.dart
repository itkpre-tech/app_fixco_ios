import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../navigation/bottom_bar.dart';

import '../widgets/glass_card.dart';
import '../widgets/profile_title_bar.dart';

class ProfilePrivacyPolicy extends StatefulWidget {
  const ProfilePrivacyPolicy({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<ProfilePrivacyPolicy> createState() =>
      _ProfilePrivacyPolicyState();
}

class _ProfilePrivacyPolicyState
    extends State<ProfilePrivacyPolicy> {

  Future<void> _refresh() async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isArabic = context.locale.languageCode == 'ar';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: isDark
          ? const Color(0xFF111318)
          : Colors.white,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: RefreshIndicator(
          color: isDark ? Colors.white : Colors.black,
          backgroundColor:
          isDark
              ? const Color(0xFF1A1C22)
              : Colors.white,

          onRefresh: _refresh,

          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            slivers: [
              SliverToBoxAdapter(
                child: ProfileTitleBar(
                  title: 'Privacy Policy'.tr(),
                  isDark: isDark,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    80 +
                        MediaQuery.of(context)
                            .padding
                            .bottom,
                  ),

                  child: GlassCard(
                    isDark: isDark,
                    borderRadius: 28,
                    padding:
                    const EdgeInsets.all(22),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          isArabic
                              ? 'سياسة الخصوصية – تطبيق Fixco'
                              : 'Privacy Policy – Fixco Mobile Application',

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          isArabic
                              ? 'آخر تحديث: 13 مايو 2026'
                              : 'Last Updated: May 13, 2026',

                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w500,
                            color: isDark
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _section(
                          isDark,
                          'Introduction'.tr(),
                          isArabic
                              ? 'في شركة Fixed Company، نحن نقدر خصوصيتك ونلتزم بحماية معلوماتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وتخزين ومشاركة وحماية معلوماتك عند استخدام تطبيقنا أو خدماتنا.'
                              : 'At Fixed Company, we value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, share, and protect your information when you use our mobile application, website, and related services.',
                        ),

                        _section(
                          isDark,
                          '1. Information We Collect'.tr(),
                          isArabic
                              ? 'قد نقوم بجمع معلومات شخصية مثل الاسم الكامل ورقم الهاتف والبريد الإلكتروني والعنوان ومعلومات الحساب وبيانات الدفع.'
                              : 'We may collect personal information such as your full name, phone number, email address, address details, account login information, and payment-related information.',
                        ),

                        _section(
                          isDark,
                          '2. Location Information'.tr(),
                          isArabic
                              ? 'بإذن منك، قد نقوم بجمع معلومات الموقع لتحسين الخدمات والوظائف داخل التطبيق.'
                              : 'With your permission, we may collect precise or approximate location information to improve service delivery and provide location-based functionality.',
                        ),

                        _section(
                          isDark,
                          '3. How We Use Your Information'.tr(),
                          isArabic
                              ? 'نستخدم معلوماتك لتقديم الخدمات وإدارة الحسابات وتحسين تجربة المستخدم وإرسال الإشعارات.'
                              : 'Your information may be used to provide services, improve user experience, process payments, send notifications, and maintain security.',
                        ),

                        _section(
                          isDark,
                          '4. Payment Information'.tr(),
                          isArabic
                              ? 'جميع المدفوعات تتم عبر بوابات دفع آمنة ولا نقوم بتخزين بيانات البطاقات.'
                              : 'All payment transactions are processed through secure payment gateways. We do not store full credit card details on our servers.',
                        ),

                        _section(
                          isDark,
                          '5. Sharing of Information'.tr(),
                          isArabic
                              ? 'قد نشارك المعلومات مع مزودي الخدمات والجهات القانونية عند الحاجة.'
                              : 'We may share information with authorized employees, contractors, payment processors, and legal authorities when required.',
                        ),

                        _section(
                          isDark,
                          '6. International Data Transfers'.tr(),
                          isArabic
                              ? 'قد يتم نقل بياناتك وتخزينها في دول خارج بلدك.'
                              : 'Your information may be transferred to and stored in countries outside your country of residence.',
                        ),

                        _section(
                          isDark,
                          '7. Advertising & Third-Party Services'.tr(),
                          isArabic
                              ? 'قد نستخدم خدمات إعلانية وخدمات طرف ثالث لتحسين التطبيق.'
                              : 'We may use third-party services for analytics, advertising, and functionality improvement.',
                        ),

                        _section(
                          isDark,
                          '8. Data Security'.tr(),
                          isArabic
                              ? 'نطبق إجراءات أمنية مناسبة لحماية معلوماتك من الوصول غير المصرح به.'
                              : 'We implement commercially reasonable security measures to protect your information against unauthorized access.',
                        ),

                        _section(
                          isDark,
                          '9. Data Retention'.tr(),
                          isArabic
                              ? 'نحتفظ ببياناتك طالما كان حسابك نشطًا أو حسب الحاجة لتقديم الخدمات.'
                              : 'We retain your data as long as your account is active or as needed to provide services.',
                        ),

                        _section(
                          isDark,
                          '10. Your Rights'.tr(),
                          isArabic
                              ? 'يمكنك طلب الوصول إلى بياناتك أو تعديلها أو حذفها وفقًا للقوانين المعمول بها.'
                              : 'You may request access, correction, deletion, or restriction of your personal information.',
                        ),

                        _section(
                          isDark,
                          '11. Children’s Privacy'.tr(),
                          isArabic
                              ? 'لا نقوم بجمع معلومات عن الأطفال تحت سن 13 عامًا عن قصد.'
                              : 'We do not knowingly collect personal information from children under 13 years of age.',
                        ),

                        _section(
                          isDark,
                          '12. Sanctions & Restricted Countries'.tr(),
                          isArabic
                              ? 'نلتزم بجميع القوانين واللوائح الدولية المتعلقة بالعقوبات.'
                              : 'We comply with all applicable international sanctions and trade restrictions.',
                        ),

                        _section(
                          isDark,
                          '13. Changes to This Privacy Policy'.tr(),
                          isArabic
                              ? 'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر وسنخطرك بأي تغييرات جوهرية.'
                              : 'We may update this Privacy Policy from time to time and will notify you of any material changes.',
                        ),

                        _section(
                          isDark,
                          '14. Contact Us'.tr(),
                          isArabic
                              ? 'شركة Fixed Company\n\nالبريد الإلكتروني: info@getkp.com\nالهاتف: +971 503455855\nالإمارات العربية المتحدة'
                              : 'Fixed Company\n\nEmail: info@getkp.com\nPhone: +971 503455855\nUnited Arab Emirates',
                        ),

                        _section(
                          isDark,
                          '15. Consent'.tr(),
                          isArabic
                              ? 'باستخدامك لتطبيق Fixco فإنك توافق على سياسة الخصوصية هذه.'
                              : 'By using the Fixed Company App, you acknowledge that you have read and agreed to this Privacy Policy.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomBar(
          currentIndex: 4,
          onTap: (index) {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _section(
      bool isDark,
      String title,
      String content,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            content,

            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}