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
defmodule AutoApi.EngineStartStopCapability do
  @moduledoc """
  Basic settings for Vehicle Status Capability

      iex> alias AutoApi.EngineStartStopCapability, as: SS
      iex> SS.identifier
      <<0x00, 0x63>>
      iex> SS.name
      :engine_start_stop
      iex> SS.description
      "Engine Start-Stop"
      iex> SS.properties
      [{1, :status}]
  """

  @type command_type ::
          :get_start_stop_state | :start_stop_state | :activate_deactivate_start_stop

  @command_module AutoApi.NotImplemented
  @state_module AutoApi.EngineStartStopState

  use AutoApi.Capability, spec_file: "specs/engine_start_stop.json"
end