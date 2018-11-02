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
defmodule AutoApi.HoodCapability do
  @moduledoc """
  Basic settings for HoodCapability

      iex> alias AutoApi.HoodCapability, as: H
      iex> H.identifier
      <<0x00, 0x67>>
      iex> H.capability_size
      1
      iex> H.name
      :hood
      iex> H.description
      "Hood"
      iex> H.command_name(0x00)
      :get_hood_state
      iex> H.command_name(0x01)
      :hood_state
      iex> length(H.properties)
      0
  """

  @spec_file "specs/hood.json"
  @type command_type ::
          :get_hood_state
          | :hood_state

  @command_module AutoApi.NotImplemented
  @state_module AutoApi.NotImplemented
  use AutoApi.Capability
end