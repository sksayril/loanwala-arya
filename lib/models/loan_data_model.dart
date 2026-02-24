class LoanDataModel {
  // Loan Details
  double? loanAmount;
  int? tenure;
  String? loanType;
  
  // Personal Details
  String? name;
  String? email;
  String? mobile;
  String? pan;
  String? employmentType;
  String? dateOfBirth;
  
  // KYC Details
  String? aadhaar;
  String? address;
  
  // Bank Details
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  
  LoanDataModel({
    this.loanAmount,
    this.tenure,
    this.loanType,
    this.name,
    this.email,
    this.mobile,
    this.pan,
    this.employmentType,
    this.dateOfBirth,
    this.aadhaar,
    this.address,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'loanAmount': loanAmount,
      'tenure': tenure,
      'loanType': loanType,
      'name': name,
      'email': email,
      'mobile': mobile,
      'pan': pan,
      'employmentType': employmentType,
      'dateOfBirth': dateOfBirth,
      'aadhaar': aadhaar,
      'address': address,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
    };
  }
  
  // Convert to loanData array format for API
  List<Map<String, dynamic>> toLoanDataArray() {
    final data = <String, dynamic>{};
    
    if (loanAmount != null) data['loanAmount'] = loanAmount;
    if (tenure != null) data['tenure'] = tenure;
    if (loanType != null) data['loanType'] = loanType;
    if (email != null) data['email'] = email;
    if (mobile != null) data['mobile'] = mobile;
    if (pan != null) data['pan'] = pan;
    if (employmentType != null) data['employmentType'] = employmentType;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
    if (aadhaar != null) data['aadhaar'] = aadhaar;
    if (address != null) data['address'] = address;
    if (bankName != null) data['bankName'] = bankName;
    if (accountNumber != null) data['accountNumber'] = accountNumber;
    if (ifscCode != null) data['ifscCode'] = ifscCode;
    
    return [data];
  }
}
