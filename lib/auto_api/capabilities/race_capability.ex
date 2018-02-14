# AutoAPI
# Copyright (C) 2018 High-Mobility GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.
#
# Please inquire about commercial licensing options at
# licensing@high-mobility.com
defmodule AutoApi.RaceCapability do
  @moduledoc """
  Basic settings for Race Capability

      iex> alias AutoApi.RaceCapability, as: R
      iex> R.identifier
      <<0x00, 0x57>>
      iex> R.name
      :race
      iex> R.description
      "Race"
      iex> R.command_name(0x00)
      :get_race_state
      iex> R.command_name(0x01)
      :race_state
      iex> length(R.properties)
      13
      iex> List.last(R.properties)
      {13, :brake_pedal_position}
  """

  @spec_file "specs/race.json"
  @type command_type :: :get_race_state | :race_state

  @command_module AutoApi.NotImplemented
  @state_module AutoApi.NotImplemented

  use AutoApi.Capability
end