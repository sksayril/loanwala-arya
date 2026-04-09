import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/disclaimer_service.dart';
import 'home_screen.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _isHindi = false;

  static const String _englishBody = '''
This application does not provide any loans directly. We are not a lender, NBFC, or financial institution. Our platform is designed only to provide guidance, information, and assistance regarding loan options available from third-party financial service providers.

All loan approvals, interest rates, terms, and disbursements are handled solely by the respective third-party lenders. We do not have any control over their policies, decisions, or processes.

Users are advised to carefully review all terms and conditions, privacy policies, and eligibility criteria of the respective lenders before applying for any loan.

We do not guarantee loan approval and are not responsible for any financial loss, damages, or issues arising from the use of third-party services.

By using this app, you agree that you are solely responsible for your financial decisions.''';

  static const String _hindiBody = '''
यह ऐप किसी भी प्रकार का लोन सीधे प्रदान नहीं करता है। हम कोई बैंक, एनबीएफसी (NBFC) या वित्तीय संस्था नहीं हैं। यह प्लेटफ़ॉर्म केवल उपयोगकर्ताओं को विभिन्न थर्ड-पार्टी लोन प्रदाताओं के बारे में जानकारी और मार्गदर्शन प्रदान करने के लिए बनाया गया है।

लोन से संबंधित सभी प्रक्रियाएँ जैसे स्वीकृति (Approval), ब्याज दर (Interest Rate), शर्तें (Terms & Conditions) और राशि का वितरण (Disbursement) संबंधित थर्ड-पार्टी लेंडर्स द्वारा ही नियंत्रित और संचालित किए जाते हैं। इन प्रक्रियाओं पर हमारा कोई नियंत्रण नहीं है।

उपयोगकर्ताओं को सलाह दी जाती है कि वे किसी भी लोन के लिए आवेदन करने से पहले संबंधित लेंडर की सभी शर्तों, नियमों और प्राइवेसी पॉलिसी को ध्यानपूर्वक पढ़ें और समझें।

हम किसी भी लोन की स्वीकृति की गारंटी नहीं देते हैं और न ही किसी प्रकार के वित्तीय नुकसान, हानि या समस्या के लिए जिम्मेदार हैं, जो थर्ड-पार्टी सेवाओं के उपयोग से उत्पन्न हो सकती है।

इस ऐप का उपयोग करके आप यह स्वीकार करते हैं कि आपके सभी वित्तीय निर्णय आपकी स्वयं की जिम्मेदारी होंगे।''';

  Future<void> _onAgree() async {
    await DisclaimerService.setDisclaimerAccepted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isHindi ? 'अस्वीकरण' : 'Disclaimer';
    final toggleLabel = _isHindi ? 'English' : 'हिंदी';
    final bodyStyle = _isHindi
        ? GoogleFonts.notoSansDevanagari(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFF1A1A1A),
          )
        : GoogleFonts.inter(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFF1A1A1A),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: () => setState(() => _isHindi = !_isHindi),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7BFA),
                    side: const BorderSide(color: Color(0xFF2E7BFA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(
                    toggleLabel,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _isHindi ? _hindiBody : _englishBody,
                      style: bodyStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _onAgree,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3B5D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isHindi ? 'सहमत' : 'Agree',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
