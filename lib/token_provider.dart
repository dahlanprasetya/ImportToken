// token_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'token.dart';
import 'token_database_provider.dart';

// token_provider.dart
// token_provider.dart
class TokenProvider extends ChangeNotifier {
  final String _rpcUrl =
      'https://ethereum.publicnode.com'; // Replace with your Infura project ID
  late Web3Client _client;
  late TokenDatabaseProvider _databaseProvider;

  List<Token> _tokens = [];

  List<Token> get tokens => _tokens;

  TokenProvider() {
    _client = Web3Client(_rpcUrl, Client());
    _databaseProvider = TokenDatabaseProvider();
    _initializeTokens();
  }

  Future<void> _initializeTokens() async {
    await _databaseProvider.open();
    _tokens = await _databaseProvider.getTokens();
    notifyListeners();
  }

  bool isValidEthereumAddress(String input) {
    final RegExp regex = RegExp(r'^0x[0-9a-fA-F]{40}$');
    return regex.hasMatch(input);
  }

  Future<void> addToken(String address) async {
    // Validate the Ethereum address
    if (!isValidEthereumAddress(address)) {
      print('Invalid Ethereum address');
      return;
    }

    // Check if the token already exists in the database
    final tokenExisted = await _databaseProvider.checkTokenByAddress(address);
    if (tokenExisted) {
      print('Token with address $address already exists.');
      return;
    }

    // Fetch token details using web3dart
    final tokenDetails = await _fetchTokenDetails(address);

    if (tokenDetails != null) {
      final Token token = Token(
        id: 0,
        name: tokenDetails['name'],
        symbol: tokenDetails['symbol'],
        address: address,
        decimals: tokenDetails['decimals'],
        logoURI: tokenDetails['logoURI'],
        currentPriceUSD: tokenDetails['currentPriceUSD'],
        changePercent24hr: tokenDetails['changePercent24hr'],
      );

      // Add the token to the provider
      _tokens.add(token);
      notifyListeners();

      // Insert the token into the database
      await _databaseProvider.insertToken(token);
    } else {
      print('Failed to fetch token details.');
    }
  }

  Future<void> deleteToken(int id) async {
    _tokens.removeWhere((t) => t.id == id);
    notifyListeners();

    // Delete the token from the database
    await _databaseProvider.deleteToken(id);
  }

  Future<Map<String, dynamic>?> _fetchTokenDetails(String address) async {
    final apiUrl =
        'https://api.coingecko.com/api/v3/coins/ethereum/contract/$address';
    const apiUrlUniswap = 'https://gateway.ipfs.io/ipns/tokens.uniswap.org';
    const apiUrlUniswapExtended = 'https://extendedtokens.uniswap.org/';

    final response = await http.get(Uri.parse(apiUrl));
    final responseUniswap = await http.get(Uri.parse(apiUrlUniswap));
    final responseUniswapExtended =
        await http.get(Uri.parse(apiUrlUniswapExtended));

    // Parse the JSON string
    Map<String, dynamic> data = json.decode(response.body);
    Map<String, dynamic> jsonDataUniswap = json.decode(responseUniswap.body);
    Map<String, dynamic> jsonDataUniswapExtended =
        json.decode(responseUniswapExtended.body);

    // Find the token with the specified address in jsonDataUniswap
    Map<String, dynamic>? tokenData = jsonDataUniswap['tokens'].firstWhere(
      (token) =>
          token['address'].toString().toLowerCase() == address.toLowerCase(),
      orElse: () => null,
    );

    // If the token is not found in jsonDataUniswap, try jsonDataUniswapExtended
    tokenData ??= jsonDataUniswapExtended['tokens'].firstWhere(
      (token) =>
          token['address'].toString().toLowerCase() == address.toLowerCase(),
      orElse: () => null,
    );

    if (tokenData != null) {
      // Create a Token object from the token data
      Token token = Token.fromJson(tokenData);
      return {
        'name': token.name,
        'symbol': token.symbol,
        'decimals': token.decimals,
        'logoURI': token.logoURI,
        'currentPriceUSD': '',
        'changePercent24hr': '',
      };
    } else {
      return null;
    }
  }
}