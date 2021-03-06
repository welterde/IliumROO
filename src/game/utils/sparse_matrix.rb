#  This file is part of Ilium MUD.
#
#  Ilium MUD is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Ilium MUD is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Ilium MUD.  If not, see <http://www.gnu.org/licenses/>.

class SparseMatrix
  def initialize
    @data ||= {}
  end

  def [](first_dimension, second_dimension, third_dimension)
    @data[[first_demension, second_dimension, third_dimension]]
  end

  def []=(first_dimension, second_dimension, third_dimension, new_value)
    @data[[first_dimension, second_dimension, third_dimension]] = new_value
  end
end