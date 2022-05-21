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

from nautilus_trader.indicators.base.indicator cimport Indicator


cdef class LinearRegression(Indicator):
    cdef object _inputs
    
    cdef readonly int period
    """The window period.\n\n:returns: `int`"""
    cdef readonly double slope
    """The current slope.\n\n:returns: `double`"""
    cdef readonly double intercept
    """The current intercept.\n\n:returns: `double`"""
    cdef readonly double degree 
    """The current degree.\n\n:returns: `double`"""
    cdef readonly double cfo
    """The current cfo value.\n\n:returns: `double`"""
    cdef readonly double R2  
    """The current R2 value.\n\n:returns: `double`"""
    cdef readonly double value
    """The current value.\n\n:returns: `double`"""

    cpdef void update_raw(self, double close_price) except *
