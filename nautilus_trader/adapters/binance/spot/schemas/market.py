# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2022 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from typing import List, Optional

import msgspec

from nautilus_trader.adapters.binance.common.enums import BinanceExchangeFilterType
from nautilus_trader.adapters.binance.common.enums import BinanceRateLimitInterval
from nautilus_trader.adapters.binance.common.enums import BinanceRateLimitType
from nautilus_trader.adapters.binance.common.enums import BinanceSymbolFilterType
from nautilus_trader.adapters.binance.spot.enums import BinanceSpotOrderType
from nautilus_trader.adapters.binance.spot.enums import BinanceSpotPermissions


class BinanceExchangeFilter(msgspec.Struct):
    """Response 'inner struct' from `Binance` GET /fapi/v1/exchangeInfo."""

    filterType: BinanceExchangeFilterType
    maxNumOrders: Optional[int] = None
    maxNumAlgoOrders: Optional[int] = None


class BinanceSymbolFilter(msgspec.Struct):
    """Response 'inner struct' from `Binance` GET /fapi/v1/exchangeInfo."""

    filterType: BinanceSymbolFilterType
    minPrice: Optional[str] = None
    maxPrice: Optional[str] = None
    tickSize: Optional[str] = None
    multiplierUp: Optional[str] = None
    multiplierDown: Optional[str] = None
    avgPriceMins: Optional[int] = None
    bidMultiplierUp: Optional[str] = None
    bidMultiplierDown: Optional[str] = None
    askMultiplierUp: Optional[str] = None
    askMultiplierDown: Optional[str] = None
    minQty: Optional[str] = None
    maxQty: Optional[str] = None
    stepSize: Optional[str] = None
    minNotional: Optional[str] = None
    applyToMarket: Optional[bool] = None
    limit: Optional[int] = None
    maxNumOrders: Optional[int] = None
    maxNumAlgoOrders: Optional[int] = None
    maxNumIcebergOrders: Optional[int] = None
    maxPosition: Optional[str] = None


class BinanceRateLimit(msgspec.Struct):
    """Response 'inner struct' from `Binance` GET /fapi/v1/exchangeInfo."""

    rateLimitType: BinanceRateLimitType
    interval: BinanceRateLimitInterval
    intervalNum: int
    limit: int


class BinanceSpotSymbolInfo(msgspec.Struct):
    """Response 'inner struct' from `Binance` Spot GET /fapi/v1/exchangeInfo."""

    symbol: str
    status: str
    baseAsset: str
    baseAssetPrecision: int
    quoteAsset: str
    quotePrecision: int
    quoteAssetPrecision: int
    orderTypes: List[BinanceSpotOrderType]
    icebergAllowed: bool
    ocoAllowed: bool
    quoteOrderQtyMarketAllowed: bool
    allowTrailingStop: bool
    isSpotTradingAllowed: bool
    isMarginTradingAllowed: bool
    filters: List[BinanceSymbolFilter]
    permissions: List[BinanceSpotPermissions]


class BinanceSpotExchangeInfo(msgspec.Struct):
    """Response from `Binance` Spot GET /fapi/v1/exchangeInfo."""

    timezone: str
    serverTime: int
    rateLimits: List[BinanceRateLimit]
    exchangeFilters: List[BinanceExchangeFilter]
    symbols: List[BinanceSpotSymbolInfo]


class BinanceSpotTrade(msgspec.Struct):
    """Response from `Binance` Spot GET /fapi/v1/historicalTrades."""

    id: int
    price: str
    qty: str
    quoteQty: str
    time: int
    isBuyerMaker: bool
    isBestMatch: bool