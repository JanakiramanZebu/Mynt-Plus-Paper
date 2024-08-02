import '../api_key_generate_api.dart';
import '../auth_api.dart';
import '../bond_api.dart';
import '../change_password_api.dart';
import '../fund_api.dart';
import '../index_api.dart';
import '../ipo_api.dart';
import '../market_watch_api.dart';
import '../notification_api.dart';
import '../order_api.dart';
import '../portfolio_api.dart';
import '../stocks_api.dart';
import '../user_profile_api.dart';
import 'api_core.dart';

class ApiExporter
    with
        ApiCore,
        AuthApi,
        ChangePasswordApi,
        IndexApi,
        MarketWatchApi,
        PortfolioAPI,
        FundApi,
        NotificationApi,
        BondApi,
        OrderAPI,
        StocksAPI,
        UserProfileAPI,
        GenerateApiKey,
        IPOApi
        {}
