import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:developer';

class UniSwapGraphQL {
  late final HttpLink _httpLink;
  get httpLink => _httpLink;
  late Link _link;
  get link => _link;
  late final _graphQLClient;
  get graphQLClient => _graphQLClient;
  late ValueNotifier<GraphQLClient> _clientNotifier;
  get clientNotifier => _clientNotifier;

  String httplink =
      'https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3';

  UniSwapGraphQL() {
    _httpLink = HttpLink(httplink);
    _link = _httpLink.concat(_httpLink);
    _graphQLClient = GraphQLClient(
      link: _link,
      cache: GraphQLCache(
          store: InMemoryStore(),
          partialDataPolicy: PartialDataCachePolicy.accept),
    );
    _clientNotifier = ValueNotifier(
      GraphQLClient(
        link: _link,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
  }

  String queryCommand = r"""
    query getTokenInfo($id: ID) {
      token(id: $id) {
        symbol
        name
        decimals
        tokenDayData(orderBy: date, orderDirection: desc, first: 2) {
          open
          priceUSD
          date
          low
        }
      }
    } 
  """;

  Future<Map<String, String>?> getUniswapV3Data(String address) async {
    final QueryResult<Object?> queryResult = await graphQLClient.query(
      QueryOptions(
        document: gql(queryCommand),
        variables: {'id': address},
      ),
    );

    final Map<String, dynamic>? tokenData = queryResult.data?['token'];
    if (tokenData != null) {
      final currentPrice = tokenData['tokenDayData'][0]['priceUSD'];
      final previousPrice = tokenData['tokenDayData'][1]['priceUSD'];
      final currentRate = calculateRate(previousPrice, currentPrice);
      final Map<String, String> uniswapV3Data = {
        'currentPriceUSD': currentPrice,
        'currentRate': currentRate,
        'name': tokenData['name'],
        'symbol': tokenData['symbol'],
        'decimals': tokenData['decimals'],
      };
      return uniswapV3Data;
    }
    return null;
  }

  String calculateRate(String prevPrice, String currentPrice) {
    final double doublePreviousPrice = double.tryParse(prevPrice) ?? 0.0;
    final double doubleCurrentPrice = double.tryParse(currentPrice) ?? 0.0;

    double rate =
        (doubleCurrentPrice - doublePreviousPrice) / doublePreviousPrice * 100;
    return rate.toString();
  }
}
