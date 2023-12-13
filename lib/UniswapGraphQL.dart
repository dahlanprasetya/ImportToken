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

  // TEST SECOND
  String getTokenDetailCommand = r"""
      query getTokenInfo($id: ID)
      {
        token(id: $id) 
        {
          symbol
          name
          decimals
          tokenDayData(orderBy: date, orderDirection: desc, first: 1){
            open
            priceUSD
            date
          }
        }
      } 
      """;
  Future<Map<String, String>> getPriceInfoNew(String address) async {

    QueryResult<Object?> queryResult = await (graphQLClient.query(QueryOptions(
        document: gql(getTokenDetailCommand), variables: {'id': address})));

    String currentTokenPrice = '0';
    String todayOpenPrice = '0';
    String currentRate = '0';
    Map<String, String> currentPriceandRate = {
      'currentPriceUSD': currentTokenPrice,
      'currentRate': currentRate
    };
    if (queryResult.data != null) {
      Object queryTokenData = queryResult.data?['token']['tokenDayData'][0];
      Map<String, dynamic> mapQueryTokenData =
          (queryTokenData as Map<String, dynamic>);
      // log("$queryTokenData ${mapQueryTokenData['open']}");
      currentTokenPrice = mapQueryTokenData['priceUSD'];
      todayOpenPrice = mapQueryTokenData['open'];
      currentRate = getRate(todayOpenPrice, currentTokenPrice);
      currentPriceandRate['currentPriceUSD'] = currentTokenPrice;
      currentPriceandRate['currentRate'] = currentRate;
    } else {
      throw Exception();
    }
    // return currentTokenPrice;
    return currentPriceandRate;
  }

  String getRate(String openPrice, currentPriceUSD) {
    double doubleOpenPrice = double.tryParse(openPrice) ?? 0.0;
    double doubleCurrentPrice = double.tryParse(currentPriceUSD) ?? 0.0;

    double rate =
        (doubleCurrentPrice - doubleOpenPrice) / doubleOpenPrice * 100;
    return rate.toString();
  }
}
