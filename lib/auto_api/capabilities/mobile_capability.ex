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
defmodule AutoApi.MobileCapability do
  @moduledoc """
  Basic settings for Mobile Capability

      iex> alias AutoApi.MobileCapability, as: M
      iex> M.identifier
      <<0x00, 0x66>>
      iex> M.name
      :mobile
      iex> M.description
      "Mobile"
      iex> M.command_name(0x00)
      :get_mobile_state
      iex> M.command_name(0x01)
      :mobile_state
      iex> length(M.properties)
      1
  """

  @spec_file "specs/mobile.json"
  @type command_type :: :get_mobile_state | :mobile_state

  @command_module AutoApi.NotImplemented
  @state_module AutoApi.NotImplemented

  use AutoApi.Capability
end