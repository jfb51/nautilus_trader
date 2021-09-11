# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
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

from decimal import Decimal
from typing import Optional

from libc.stdint cimport int64_t

from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.core.message cimport Event
from nautilus_trader.core.uuid cimport UUID4
from nautilus_trader.model.c_enums.order_side cimport OrderSide
from nautilus_trader.model.c_enums.order_side cimport OrderSideParser
from nautilus_trader.model.c_enums.position_side cimport PositionSide
from nautilus_trader.model.c_enums.position_side cimport PositionSideParser
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.events.order cimport OrderFilled
from nautilus_trader.model.identifiers cimport AccountId
from nautilus_trader.model.identifiers cimport ClientOrderId
from nautilus_trader.model.identifiers cimport PositionId
from nautilus_trader.model.objects cimport Money
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity
from nautilus_trader.model.position cimport Position


cdef class PositionEvent(Event):
    """
    The abstract base class for all position events.

    Warnings
    --------
    This class should not be used directly, but through a concrete subclass.
    """

    def __init__(
        self,
        TraderId trader_id not None,
        StrategyId strategy_id not None,
        InstrumentId instrument_id not None,
        PositionId position_id not None,
        AccountId account_id not None,
        ClientOrderId from_order not None,
        OrderSide entry,
        PositionSide side,
        net_qty not None: Decimal,
        Quantity quantity not None,
        Quantity peak_qty not None,
        Quantity last_qty not None,
        Price last_px not None,
        Currency currency not None,
        avg_px_open not None: Decimal,
        avg_px_close: Optional[Decimal],
        realized_points not None: Decimal,
        realized_return not None: Decimal,
        Money realized_pnl not None,
        Money unrealized_pnl not None,
        UUID4 event_id not None,
        int64_t ts_opened,
        int64_t ts_closed,
        int64_t duration_ns,
        int64_t ts_event,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``PositionEvent`` class.

        Parameters
        ----------
        trader_id : TraderId
            The trader ID.
        strategy_id : StrategyId
            The strategy ID.
        instrument_id : InstrumentId
            The instrument ID.
        position_id : PositionId
            The position IDt.
        account_id : AccountId
            The strategy ID.
        from_order : ClientOrderId
            The client order ID for the order which initially opened the position.
        entry : OrderSide
            The position entry order side.
        side : PositionSide
            The current position side.
        net_qty : Decimal
            The current net quantity (positive for ``LONG``, negative for ``SHORT``).
        quantity : Quantity
            The current open quantity.
        peak_qty : Quantity
            The peak directional quantity reached by the position.
        last_qty : Quantity
            The last fill quantity for the position.
        last_px : Price
            The last fill price for the position (not average price).
        currency : Currency
            The position quote currency.
        avg_px_open : Decimal
            The average open price.
        avg_px_close : Decimal, optional
            The average close price.
        realized_points : Decimal
            The realized points for the position.
        realized_return : Decimal
            The realized return for the position.
        realized_pnl : Money
            The realized PnL for the position.
        unrealized_pnl : Money
            The unrealized PnL for the position.
        event_id : UUID4
            The event ID.
        ts_opened : int64
            The UNIX timestamp (nanoseconds) when the position opened event occurred.
        ts_closed : int64
            The UNIX timestamp (nanoseconds) when the position closed event occurred.
        duration_ns : int64
            The total open duration (nanoseconds), will be 0 if still open.
        ts_event : int64
            The UNIX timestamp (nanoseconds) when the event occurred.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        """
        super().__init__(event_id, ts_event, ts_init)

        self.trader_id = trader_id
        self.strategy_id = strategy_id
        self.instrument_id = instrument_id
        self.position_id = position_id
        self.account_id = account_id
        self.from_order = from_order
        self.entry = entry
        self.side = side
        self.net_qty = net_qty
        self.quantity = quantity
        self.peak_qty = peak_qty
        self.last_qty = last_qty
        self.last_px = last_px
        self.currency = currency
        self.avg_px_open = avg_px_open
        self.avg_px_close = avg_px_close
        self.realized_points = realized_points
        self.realized_return = realized_return
        self.realized_pnl = realized_pnl
        self.unrealized_pnl = unrealized_pnl
        self.ts_opened = ts_opened
        self.ts_closed = ts_closed
        self.duration_ns = duration_ns

    def __str__(self) -> str:
        return (f"{type(self).__name__}("
                f"instrument_id={self.instrument_id.value}, "
                f"position_id={self.position_id.value}, "
                f"account_id={self.account_id.value}, "
                f"from_order={self.from_order.value}, "
                f"strategy_id={self.strategy_id.value}, "
                f"entry={OrderSideParser.to_str(self.entry)}, "
                f"side={PositionSideParser.to_str(self.side)}, "
                f"net_qty={self.net_qty}, "
                f"quantity={self.quantity.to_str()}, "
                f"peak_qty={self.peak_qty.to_str()}, "
                f"currency={self.currency.code}, "
                f"avg_px_open={self.avg_px_open}, "
                f"avg_px_close={self.avg_px_close}, "
                f"realized_points={self.realized_points}, "
                f"realized_return={self.realized_return:.5f}, "
                f"realized_pnl={self.realized_pnl}, "
                f"unrealized_pnl={self.unrealized_pnl}, "
                f"ts_opened={self.ts_opened}, "
                f"ts_last={self.ts_event}, "
                f"ts_closed={self.ts_closed}, "
                f"duration_ns={self.duration_ns})")

    def __repr__(self) -> str:
        return (f"{type(self).__name__}("
                f"trader_id={self.trader_id.value}, "
                f"strategy_id={self.strategy_id.value}, "
                f"instrument_id={self.instrument_id.value}, "
                f"position_id={self.position_id.value}, "
                f"account_id={self.account_id.value}, "
                f"from_order={self.from_order.value}, "
                f"strategy_id={self.strategy_id.value}, "
                f"entry={OrderSideParser.to_str(self.entry)}, "
                f"side={PositionSideParser.to_str(self.side)}, "
                f"net_qty={self.net_qty}, "
                f"quantity={self.quantity.to_str()}, "
                f"peak_qty={self.peak_qty.to_str()}, "
                f"currency={self.currency.code}, "
                f"avg_px_open={self.avg_px_open}, "
                f"avg_px_close={self.avg_px_close}, "
                f"realized_points={self.realized_points}, "
                f"realized_return={self.realized_return:.5f}, "
                f"realized_pnl={self.realized_pnl}, "
                f"unrealized_pnl={self.unrealized_pnl}, "
                f"ts_opened={self.ts_opened}, "
                f"ts_last={self.ts_event}, "
                f"ts_closed={self.ts_closed}, "
                f"duration_ns={self.duration_ns}, "
                f"event_id={self.id})")


cdef class PositionOpened(PositionEvent):
    """
    Represents an event where a position has been opened.
    """

    def __init__(
        self,
        TraderId trader_id not None,
        StrategyId strategy_id not None,
        InstrumentId instrument_id not None,
        PositionId position_id not None,
        AccountId account_id not None,
        ClientOrderId from_order not None,
        OrderSide entry,
        PositionSide side,
        net_qty not None: Decimal,
        Quantity quantity not None,
        Quantity peak_qty not None,
        Quantity last_qty not None,
        Price last_px not None,
        Currency currency not None,
        avg_px_open not None: Decimal,
        Money realized_pnl not None,
        UUID4 event_id not None,
        int64_t ts_event,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``PositionOpened`` class.

        Parameters
        ----------
        trader_id : TraderId
            The trader ID.
        strategy_id : StrategyId
            The strategy ID.
        instrument_id : InstrumentId
            The instrument ID.
        position_id : PositionId
            The position IDt.
        account_id : AccountId
            The strategy ID.
        from_order : ClientOrderId
            The client order ID for the order which initially opened the position.
        strategy_id : StrategyId
            The strategy ID associated with the event.
        entry : OrderSide
            The position entry order side.
        side : PositionSide
            The current position side.
        net_qty : Decimal
            The current net quantity (positive for ``LONG``, negative for ``SHORT``).
        quantity : Quantity
            The current open quantity.
        peak_qty : Quantity
            The peak directional quantity reached by the position.
        last_qty : Quantity
            The last fill quantity for the position.
        last_px : Price
            The last fill price for the position (not average price).
        currency : Currency
            The position quote currency.
        avg_px_open : Decimal
            The average open price.
        realized_pnl : Money
            The realized PnL for the position.
        event_id : UUID4
            The event ID.
        ts_event : int64
            The UNIX timestamp (nanoseconds) when the position opened event occurred.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        """
        assert side != PositionSide.FLAT  # Design-time check: position side matches event
        super().__init__(
            trader_id,
            strategy_id,
            instrument_id,
            position_id,
            account_id,
            from_order,
            entry,
            side,
            net_qty,
            quantity,
            peak_qty,
            last_qty,
            last_px,
            currency,
            avg_px_open,
            None,
            Decimal(0),
            Decimal(0),
            realized_pnl,
            Money(0, realized_pnl.currency),
            event_id,
            ts_event,
            0,
            0,
            ts_event,
            ts_init,
        )

    @staticmethod
    cdef PositionOpened create_c(
        Position position,
        OrderFilled fill,
        UUID4 event_id,
        int64_t ts_init,
    ):
        Condition.not_none(position, "position")
        Condition.not_none(fill, "fill")
        Condition.not_none(event_id, "event_id")

        return PositionOpened(
            trader_id=position.trader_id,
            strategy_id=position.strategy_id,
            instrument_id=position.instrument_id,
            position_id=position.id,
            account_id=position.account_id,
            from_order=position.from_order,
            entry=position.entry,
            side=position.side,
            net_qty=position.net_qty,
            quantity=position.quantity,
            peak_qty=position.peak_qty,
            last_qty=fill.last_qty,
            last_px=fill.last_px,
            currency=position.quote_currency,
            avg_px_open=position.avg_px_open,
            realized_pnl=position.realized_pnl,
            event_id=event_id,
            ts_event=position.ts_opened,
            ts_init=ts_init,
        )

    @staticmethod
    cdef PositionOpened from_dict_c(dict values):
        Condition.not_none(values, "values")
        return PositionOpened(
            trader_id=TraderId(values["trader_id"]),
            strategy_id=StrategyId(values["strategy_id"]),
            instrument_id=InstrumentId.from_str_c(values["instrument_id"]),
            position_id=PositionId(values["position_id"]),
            account_id=AccountId.from_str_c(values["account_id"]),
            from_order=ClientOrderId(values["from_order"]),
            entry=OrderSideParser.from_str(values["entry"]),
            side=PositionSideParser.from_str(values["side"]),
            net_qty=Decimal(values["net_qty"]),
            quantity=Quantity.from_str_c(values["quantity"]),
            peak_qty=Quantity.from_str_c(values["peak_qty"]),
            last_qty=Quantity.from_str_c(values["last_qty"]),
            last_px=Price.from_str_c(values["last_px"]),
            currency=Currency.from_str_c(values["currency"]),
            avg_px_open=Decimal(values["avg_px_open"]),
            realized_pnl=Money.from_str_c(values["realized_pnl"]),
            event_id=UUID4(values["event_id"]),
            ts_event=values["ts_event"],
            ts_init=values["ts_init"],
        )

    @staticmethod
    cdef dict to_dict_c(PositionOpened obj):
        Condition.not_none(obj, "obj")
        return {
            "type": type(obj).__name__,
            "trader_id": obj.trader_id.value,
            "strategy_id": obj.strategy_id.value,
            "instrument_id": obj.instrument_id.value,
            "position_id": obj.position_id.value,
            "account_id": obj.account_id.value,
            "from_order": obj.from_order.value,
            "entry": OrderSideParser.to_str(obj.entry),
            "side": PositionSideParser.to_str(obj.side),
            "net_qty": str(obj.net_qty),
            "quantity": str(obj.quantity),
            "peak_qty": str(obj.peak_qty),
            "last_qty": str(obj.last_qty),
            "last_px": str(obj.last_px),
            "currency": obj.currency.code,
            "avg_px_open": str(obj.avg_px_open),
            "realized_pnl": obj.realized_pnl.to_str(),
            "duration_ns": obj.duration_ns,
            "event_id": obj.id.value,
            "ts_event": obj.ts_event,
            "ts_init": obj.ts_init,
        }

    @staticmethod
    def create(
        Position position,
        OrderFilled fill,
        UUID4 event_id,
        int64_t ts_init,
    ):
        """
        Return a position opened event from the given params.

        Parameters
        ----------
        position : Position
            The position for the event.
        fill : OrderFilled
            The order fill for the event.
        event_id : UUID4
            The event ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        Returns
        -------
        PositionOpened

        """
        return PositionOpened.create_c(position, fill, event_id, ts_init)

    @staticmethod
    def from_dict(dict values) -> PositionOpened:
        """
        Return a position opened event from the given dict values.

        Parameters
        ----------
        values : dict[str, object]
            The values for initialization.

        Returns
        -------
        PositionOpened

        """
        return PositionOpened.from_dict_c(values)

    @staticmethod
    def to_dict(PositionOpened obj):
        """
        Return a dictionary representation of this object.

        Returns
        -------
        dict[str, object]

        """
        return PositionOpened.to_dict_c(obj)


cdef class PositionChanged(PositionEvent):
    """
    Represents an event where a position has changed.
    """

    def __init__(
        self,
        TraderId trader_id not None,
        StrategyId strategy_id not None,
        InstrumentId instrument_id not None,
        PositionId position_id not None,
        AccountId account_id not None,
        ClientOrderId from_order not None,
        OrderSide entry,
        PositionSide side,
        net_qty not None: Decimal,
        Quantity quantity not None,
        Quantity peak_qty not None,
        Quantity last_qty not None,
        Price last_px not None,
        Currency currency not None,
        avg_px_open not None: Decimal,
        avg_px_close: Optional[Decimal],
        realized_points not None: Decimal,
        realized_return not None: Decimal,
        Money realized_pnl not None,
        Money unrealized_pnl not None,
        UUID4 event_id not None,
        int64_t ts_opened,
        int64_t ts_event,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``PositionChanged`` class.

        Parameters
        ----------
        trader_id : TraderId
            The trader ID.
        strategy_id : StrategyId
            The strategy ID.
        instrument_id : InstrumentId
            The instrument ID.
        position_id : PositionId
            The position IDt.
        account_id : AccountId
            The strategy ID.
        from_order : ClientOrderId
            The client order ID for the order which initially opened the position.
        strategy_id : StrategyId
            The strategy ID associated with the event.
        entry : OrderSide
            The position entry order side.
        side : PositionSide
            The current position side.
        net_qty : Decimal
            The current net quantity (positive for ``LONG``, negative for ``SHORT``).
        quantity : Quantity
            The current open quantity.
        peak_qty : Quantity
            The peak directional quantity reached by the position.
        last_qty : Quantity
            The last fill quantity for the position.
        last_px : Price
            The last fill price for the position (not average price).
        currency : Currency
            The position quote currency.
        avg_px_open : Decimal
            The average open price.
        avg_px_close : Decimal, optional
            The average close price.
        realized_points : Decimal
            The realized points for the position.
        realized_return : Decimal
            The realized return for the position.
        realized_pnl : Money
            The realized PnL for the position.
        unrealized_pnl : Money
            The unrealized PnL for the position.
        event_id : UUID4
            The event ID.
        ts_opened : int64
            The UNIX timestamp (nanoseconds) when the position opened event occurred.
        ts_event : int64
            The UNIX timestamp (nanoseconds) when the position changed event occurred.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        """
        assert side != PositionSide.FLAT  # Design-time check: position side matches event
        super().__init__(
            trader_id,
            strategy_id,
            instrument_id,
            position_id,
            account_id,
            from_order,
            entry,
            side,
            net_qty,
            quantity,
            peak_qty,
            last_qty,
            last_px,
            currency,
            avg_px_open,
            avg_px_close,
            realized_points,
            realized_return,
            realized_pnl,
            unrealized_pnl,
            event_id,
            ts_opened,
            0,
            0,
            ts_event,
            ts_init,
        )

    @staticmethod
    cdef PositionChanged create_c(
        Position position,
        OrderFilled fill,
        UUID4 event_id,
        int64_t ts_init,
    ):
        Condition.not_none(position, "position")
        Condition.not_none(fill, "fill")
        Condition.not_none(event_id, "event_id")

        return PositionChanged(
            trader_id=position.trader_id,
            strategy_id=position.strategy_id,
            instrument_id=position.instrument_id,
            position_id=position.id,
            account_id=position.account_id,
            from_order=position.from_order,
            entry=position.entry,
            side=position.side,
            net_qty=position.net_qty,
            quantity=position.quantity,
            peak_qty=position.peak_qty,
            last_qty=fill.last_qty,
            last_px=fill.last_px,
            currency=position.quote_currency,
            avg_px_open=position.avg_px_open,
            avg_px_close=position.avg_px_close,
            realized_points=position.realized_points,
            realized_return=position.realized_return,
            realized_pnl=position.realized_pnl,
            unrealized_pnl=position.unrealized_pnl(fill.last_px),
            event_id=event_id,
            ts_opened=position.ts_opened,
            ts_event=position.last_event_c().ts_event,
            ts_init=ts_init,
        )

    @staticmethod
    cdef PositionChanged from_dict_c(dict values):
        Condition.not_none(values, "values")
        avg_px_close_value = values["avg_px_close"]
        avg_px_close: Optional[Decimal] = Decimal(avg_px_close_value) if avg_px_close_value else None
        return PositionChanged(
            trader_id=TraderId(values["trader_id"]),
            strategy_id=StrategyId(values["strategy_id"]),
            instrument_id=InstrumentId.from_str_c(values["instrument_id"]),
            position_id=PositionId(values["position_id"]),
            account_id=AccountId.from_str_c(values["account_id"]),
            from_order=ClientOrderId(values["from_order"]),
            entry=OrderSideParser.from_str(values["entry"]),
            side=PositionSideParser.from_str(values["side"]),
            net_qty=Decimal(values["net_qty"]),
            quantity=Quantity.from_str_c(values["quantity"]),
            peak_qty=Quantity.from_str_c(values["peak_qty"]),
            last_qty=Quantity.from_str_c(values["last_qty"]),
            last_px=Price.from_str_c(values["last_px"]),
            currency=Currency.from_str_c(values["currency"]),
            avg_px_open=Decimal(values["avg_px_open"]),
            avg_px_close=avg_px_close,
            realized_points=Decimal(values["realized_points"]),
            realized_return=Decimal(values["realized_return"]),
            realized_pnl=Money.from_str_c(values["realized_pnl"]),
            unrealized_pnl=Money.from_str_c(values["unrealized_pnl"]),
            event_id=UUID4(values["event_id"]),
            ts_opened=values["ts_opened"],
            ts_event=values["ts_event"],
            ts_init=values["ts_init"],
        )

    @staticmethod
    cdef dict to_dict_c(PositionChanged obj):
        Condition.not_none(obj, "obj")
        return {
            "type": type(obj).__name__,
            "trader_id": obj.trader_id.value,
            "strategy_id": obj.strategy_id.value,
            "instrument_id": obj.instrument_id.value,
            "position_id": obj.position_id.value,
            "account_id": obj.account_id.value,
            "from_order": obj.from_order.value,
            "entry": OrderSideParser.to_str(obj.entry),
            "side": PositionSideParser.to_str(obj.side),
            "net_qty": str(obj.net_qty),
            "quantity": str(obj.quantity),
            "peak_qty": str(obj.peak_qty),
            "last_qty": str(obj.last_qty),
            "last_px": str(obj.last_px),
            "currency": obj.currency.code,
            "avg_px_open": str(obj.avg_px_open),
            "avg_px_close": str(obj.avg_px_close) if obj.avg_px_close else None,
            "realized_points": str(obj.realized_points),
            "realized_return": f"{obj.realized_return:.5f}",
            "realized_pnl": obj.realized_pnl.to_str(),
            "unrealized_pnl": obj.unrealized_pnl.to_str(),
            "event_id": obj.id.value,
            "ts_opened": obj.ts_opened,
            "ts_event": obj.ts_event,
            "ts_init": obj.ts_init,
        }

    @staticmethod
    def create(
        Position position,
        OrderFilled fill,
        UUID4 event_id,
        int64_t ts_init,
    ):
        """
        Return a position changed event from the given params.

        Parameters
        ----------
        position : Position
            The position for the event.
        fill : OrderFilled
            The order fill for the event.
        event_id : UUID4
            The event ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        Returns
        -------
        PositionChanged

        """
        return PositionChanged.create_c(position, fill, event_id, ts_init)

    @staticmethod
    def from_dict(dict values) -> PositionChanged:
        """
        Return a position changed event from the given dict values.

        Parameters
        ----------
        values : dict[str, object]
            The values for initialization.

        Returns
        -------
        PositionChanged

        """
        return PositionChanged.from_dict_c(values)

    @staticmethod
    def to_dict(PositionChanged obj):
        """
        Return a dictionary representation of this object.

        Returns
        -------
        dict[str, object]

        """
        return PositionChanged.to_dict_c(obj)


cdef class PositionClosed(PositionEvent):
    """
    Represents an event where a position has been closed.
    """

    def __init__(
        self,
        TraderId trader_id not None,
        StrategyId strategy_id not None,
        InstrumentId instrument_id not None,
        PositionId position_id not None,
        AccountId account_id not None,
        ClientOrderId from_order not None,
        OrderSide entry,
        PositionSide side,
        net_qty not None: Decimal,
        Quantity quantity not None,
        Quantity peak_qty not None,
        Quantity last_qty not None,
        Price last_px not None,
        Currency currency not None,
        avg_px_open not None: Decimal,
        avg_px_close not None: Decimal,
        realized_points not None: Decimal,
        realized_return not None: Decimal,
        Money realized_pnl not None,
        UUID4 event_id not None,
        int64_t ts_opened,
        int64_t ts_closed,
        int64_t duration_ns,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``PositionClosed`` class.

        Parameters
        ----------
        trader_id : TraderId
            The trader ID.
        strategy_id : StrategyId
            The strategy ID.
        instrument_id : InstrumentId
            The instrument ID.
        position_id : PositionId
            The position IDt.
        account_id : AccountId
            The strategy ID.
        from_order : ClientOrderId
            The client order ID for the order which initially opened the position.
        strategy_id : StrategyId
            The strategy ID associated with the event.
        entry : OrderSide
            The position entry order side.
        side : PositionSide
            The current position side.
        net_qty : Decimal
            The current net quantity (positive for ``LONG``, negative for ``SHORT``).
        quantity : Quantity
            The current open quantity.
        peak_qty : Quantity
            The peak directional quantity reached by the position.
        last_qty : Quantity
            The last fill quantity for the position.
        last_px : Price
            The last fill price for the position (not average price).
        currency : Currency
            The position quote currency.
        avg_px_open : Decimal
            The average open price.
        avg_px_close : Decimal
            The average close price.
        realized_points : Decimal
            The realized points for the position.
        realized_return : Decimal
            The realized return for the position.
        realized_pnl : Money
            The realized PnL for the position.
        event_id : UUID4
            The event ID.
        ts_opened : int64
            The UNIX timestamp (nanoseconds) when the position opened event occurred.
        ts_closed : int64
            The UNIX timestamp (nanoseconds) when the position closed event occurred.
        duration_ns : int64
            The total open duration (nanoseconds).
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        """
        assert side == PositionSide.FLAT  # Design-time check: position side matches event
        super().__init__(
            trader_id,
            strategy_id,
            instrument_id,
            position_id,
            account_id,
            from_order,
            entry,
            side,
            net_qty,
            quantity,
            peak_qty,
            last_qty,
            last_px,
            currency,
            avg_px_open,
            avg_px_close,
            realized_points,
            realized_return,
            realized_pnl,
            Money(0, realized_pnl.currency),  # No further unrealized PnL
            event_id,
            ts_opened,
            ts_closed,
            duration_ns,
            ts_closed,  # ts_event = ts_closed
            ts_init,
        )

    @staticmethod
    cdef PositionClosed create_c(
        Position position,
        OrderFilled fill,
        UUID4 event_id,
        int64_t ts_init,
    ):
        Condition.not_none(position, "position")
        Condition.not_none(fill, "fill")
        Condition.not_none(event_id, "event_id")

        return PositionClosed(
            trader_id=position.trader_id,
            strategy_id=position.strategy_id,
            instrument_id=position.instrument_id,
            position_id=position.id,
            account_id=position.account_id,
            from_order=position.from_order,
            entry=position.entry,
            side=position.side,
            net_qty=position.net_qty,
            quantity=position.quantity,
            peak_qty=position.peak_qty,
            last_qty=fill.last_qty,
            last_px=fill.last_px,
            currency=position.quote_currency,
            avg_px_open=position.avg_px_open,
            avg_px_close=position.avg_px_close,
            realized_points=position.realized_points,
            realized_return=position.realized_return,
            realized_pnl=position.realized_pnl,
            event_id=event_id,
            ts_opened=position.ts_opened,
            ts_closed=position.ts_closed,
            duration_ns=position.duration_ns,
            ts_init=ts_init,
        )

    @staticmethod
    cdef PositionClosed from_dict_c(dict values):
        Condition.not_none(values, "values")
        return PositionClosed(
            trader_id=TraderId(values["trader_id"]),
            strategy_id=StrategyId(values["strategy_id"]),
            instrument_id=InstrumentId.from_str_c(values["instrument_id"]),
            position_id=PositionId(values["position_id"]),
            account_id=AccountId.from_str_c(values["account_id"]),
            from_order=ClientOrderId(values["from_order"]),
            entry=OrderSideParser.from_str(values["entry"]),
            side=PositionSideParser.from_str(values["side"]),
            net_qty=Decimal(values["net_qty"]),
            quantity=Quantity.from_str_c(values["quantity"]),
            peak_qty=Quantity.from_str_c(values["peak_qty"]),
            last_qty=Quantity.from_str_c(values["last_qty"]),
            last_px=Price.from_str_c(values["last_px"]),
            currency=Currency.from_str_c(values["currency"]),
            avg_px_open=Decimal(values["avg_px_open"]),
            avg_px_close=Decimal(values["avg_px_close"]),
            realized_points=Decimal(values["realized_points"]),
            realized_return=Decimal(values["realized_return"]),
            realized_pnl=Money.from_str_c(values["realized_pnl"]),
            event_id=UUID4(values["event_id"]),
            ts_opened=values["ts_opened"],
            ts_closed=values["ts_closed"],
            duration_ns=values["duration_ns"],
            ts_init=values["ts_init"],
        )

    @staticmethod
    cdef dict to_dict_c(PositionClosed obj):
        Condition.not_none(obj, "obj")
        return {
            "type": type(obj).__name__,
            "trader_id": obj.trader_id.value,
            "strategy_id": obj.strategy_id.value,
            "instrument_id": obj.instrument_id.value,
            "position_id": obj.position_id.value,
            "account_id": obj.account_id.value,
            "from_order": obj.from_order.value,
            "entry": OrderSideParser.to_str(obj.entry),
            "side": PositionSideParser.to_str(obj.side),
            "net_qty": str(obj.net_qty),
            "quantity": str(obj.quantity),
            "peak_qty": str(obj.peak_qty),
            "last_qty": str(obj.last_qty),
            "last_px": str(obj.last_px),
            "currency": obj.currency.code,
            "avg_px_open": str(obj.avg_px_open),
            "avg_px_close": str(obj.avg_px_close) if obj.avg_px_close else None,
            "realized_points": str(obj.realized_points),
            "realized_return": f"{obj.realized_return:.5f}",
            "realized_pnl": obj.realized_pnl.to_str(),
            "event_id": obj.id.value,
            "ts_opened": obj.ts_opened,
            "ts_closed": obj.ts_closed,
            "duration_ns": obj.duration_ns,
            "ts_init": obj.ts_init,
        }

    @staticmethod
    def create(
        Position position,
        OrderFilled fill,
        UUID4 event_id,
        int64_t ts_init,
    ):
        """
        Return a position closed event from the given params.

        Parameters
        ----------
        position : Position
            The position for the event.
        fill : OrderFilled
            The order fill for the event.
        event_id : UUID4
            The event ID.
        ts_init : int64
            The UNIX timestamp (nanoseconds) when the object was initialized.

        Returns
        -------
        PositionClosed

        """
        return PositionClosed.create_c(position, fill, event_id, ts_init)

    @staticmethod
    def from_dict(dict values) -> PositionClosed:
        """
        Return a position closed event from the given dict values.

        Parameters
        ----------
        values : dict[str, object]
            The values for initialization.

        Returns
        -------
        PositionClosed

        """
        return PositionClosed.from_dict_c(values)

    @staticmethod
    def to_dict(PositionClosed obj):
        """
        Return a dictionary representation of this object.

        Returns
        -------
        dict[str, object]

        """
        return PositionClosed.to_dict_c(obj)