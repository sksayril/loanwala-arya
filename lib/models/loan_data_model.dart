class LoanDataModel {
  // CIBIL Screen Data
  String? cibilName;
  String? cibilPhone;
  String? cibilPan;
  String? cibilDob;

  // Customize Loan Screen Data
  double? loanAmount;
  int? tenure;
  String? loanType;

  // Personal Details Screen Data
  String? personalName;
  String? personalMobile;
  String? personalPan;
  String? employmentType;

  // KYC Screen Data
  String? aadhaarNumber;
  String? kycPan;
  String? address;

  // Bank Details Screen Data
  String? bankName;
  String? accountNumber;
  String? ifscCode;

  LoanDataModel({
    this.cibilName,
    this.cibilPhone,
    this.cibilPan,
    this.cibilDob,
    this.loanAmount,
    this.tenure,
    this.loanType,
    this.personalName,
    this.personalMobile,
    this.personalPan,
    this.employmentType,
    this.aadhaarNumber,
    this.kycPan,
    this.address,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
  });

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'cibilData': {
        'name': cibilName,
        'phone': cibilPhone,
        'pan': cibilPan,
        'dob': cibilDob,
      },
      'loanDetails': {
        'loanAmount': loanAmount,
        'tenure': tenure,
        'loanType': loanType,
      },
      'personalDetails': {
        'name': personalName,
        'mobile': personalMobile,
        'pan': personalPan,
        'employmentType': employmentType,
      },
      'kycData': {
        'aadhaarNumber': aadhaarNumber,
        'pan': kycPan,
        'address': address,
      },
      'bankDetails': {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
      },
    };
  }

  // Get the primary name (from personal details or CIBIL)
  String? get primaryName {
    return personalName ?? cibilName;
  }

  // Clear all data
  void clear() {
    cibilName = null;
    cibilPhone = null;
    cibilPan = null;
    cibilDob = null;
    loanAmount = null;
    tenure = null;
    loanType = null;
    personalName = null;
    personalMobile = null;
    personalPan = null;
    employmentType = null;
    aadhaarNumber = null;
    kycPan = null;
    address = null;
    bankName = null;
    accountNumber = null;
    ifscCode = null;
  }
}
