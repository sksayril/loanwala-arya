import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loan_application_data.dart';

class LoanDataService {
  static const String baseUrl = 'https://datahive.skystar.co.in';
  static const String loanDataEndpoint = '/loan-data';

  // Singleton instance
  static final LoanDataService _instance = LoanDataService._internal();
  factory LoanDataService() => _instance;
  LoanDataService._internal();

  // Store loan application data
  LoanApplicationData _loanData = LoanApplicationData();

  // Get current loan data
  LoanApplicationData get loanData => _loanData;

  // Update loan details
  void updateLoanDetails({
    String? loanType,
    double? loanAmount,
    int? tenure,
    double? interestRate,
    double? emi,
  }) {
    _loanData.loanType = loanType ?? _loanData.loanType;
    _loanData.loanAmount = loanAmount ?? _loanData.loanAmount;
    _loanData.tenure = tenure ?? _loanData.tenure;
    _loanData.interestRate = interestRate ?? _loanData.interestRate;
    _loanData.emi = emi ?? _loanData.emi;
  }

  // Update personal details
  void updatePersonalDetails({
    String? name,
    String? email,
    String? mobile,
    String? pan,
    String? employmentType,
  }) {
    _loanData.name = name ?? _loanData.name;
    _loanData.email = email ?? _loanData.email;
    _loanData.mobile = mobile ?? _loanData.mobile;
    _loanData.pan = pan ?? _loanData.pan;
    _loanData.employmentType = employmentType ?? _loanData.employmentType;
  }

  // Update CIBIL check details
  void updateCibilDetails({
    String? cibilName,
    String? cibilPhone,
    String? cibilPan,
    String? dateOfBirth,
  }) {
    _loanData.cibilName = cibilName ?? _loanData.cibilName;
    _loanData.cibilPhone = cibilPhone ?? _loanData.cibilPhone;
    _loanData.cibilPan = cibilPan ?? _loanData.cibilPan;
    _loanData.dateOfBirth = dateOfBirth ?? _loanData.dateOfBirth;
  }

  // Update KYC details
  void updateKycDetails({
    String? aadhaar,
    String? address,
  }) {
    _loanData.aadhaar = aadhaar ?? _loanData.aadhaar;
    _loanData.address = address ?? _loanData.address;
  }

  // Update bank details
  void updateBankDetails({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    _loanData.bankName = bankName ?? _loanData.bankName;
    _loanData.accountNumber = accountNumber ?? _loanData.accountNumber;
    _loanData.ifscCode = ifscCode ?? _loanData.ifscCode;
  }

  // Submit loan data to API
  Future<Map<String, dynamic>> submitLoanData() async {
    try {
      if (_loanData.name == null || _loanData.name!.isEmpty) {
        throw Exception('Name is required');
      }

      final uri = Uri.parse('$baseUrl$loanDataEndpoint');
      
      // Prepare request body as per API specification
      final requestBody = {
        'name': _loanData.name,
        'loanData': [_loanData.toLoanDataJson()],
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return {
            'success': true,
            'message': 'Loan data submitted successfully',
            'data': responseData,
          };
        } catch (e) {
          return {
            'success': true,
            'message': 'Loan data submitted successfully',
            'data': {'response': response.body},
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to submit loan data. Status: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting loan data: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Submit CIBIL check data to API
  Future<Map<String, dynamic>> submitCibilData({
    required String name,
    required String phone,
    required String pan,
    required String dateOfBirth,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$loanDataEndpoint');
      
      // Prepare request body for CIBIL data
      final requestBody = {
        'name': name,
        'loanData': [{
          'cibilName': name,
          'cibilPhone': phone,
          'cibilPan': pan,
          'dateOfBirth': dateOfBirth,
          'type': 'cibil_check', // Indicate this is CIBIL check data
        }],
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return {
            'success': true,
            'message': 'CIBIL data submitted successfully',
            'data': responseData,
          };
        } catch (e) {
          return {
            'success': true,
            'message': 'CIBIL data submitted successfully',
            'data': {'response': response.body},
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to submit CIBIL data. Status: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error submitting CIBIL data: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Clear all data (useful for reset)
  void clearData() {
    _loanData = LoanApplicationData();
  }
}
