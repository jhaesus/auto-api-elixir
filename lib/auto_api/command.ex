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
defmodule AutoApi.Command do
  @moduledoc """
  Command behavior for handling AutoApi commands
  """

  alias AutoApi.Capability

  @type execute_return_atom :: :state | :state_changed
  @callback execute(struct, binary) :: {execute_return_atom, struct}
  @callback state(struct) :: binary

  @type capability_name ::
          :door_locks
          | :charging
          | :diagnostics
          | :engine
          | :maintenance
          | :rooftop
          | :trunk_access
          | :vehicle_location
          | :hood
          | :rooftop_control

  @doc """
  Extracts commands meta data  including the capability that
  the command is using and exact command that is issued

      iex> AutoApi.Command.meta_data(<<0, 0x33, 0x00>>)
      %{message_id: :diagnostics, message_type: :get_diagnostics_state, module: AutoApi.DiagnosticsCapability}

      iex> binary_command = <<0x00, 0x23, 0x12, 0x01, 0x00>>
      iex> %{module: cap} = AutoApi.Command.meta_data(binary_command)
      %{message_id: :charging, message_type: :start_stop_charging, module: AutoApi.ChargingCapability}
      iex> base_state = cap.state.base
      %AutoApi.ChargingState{}
      iex> AutoApi.Command.execute(base_state, cap.command, binary_command)
      {:state_changed, %AutoApi.ChargingState{}}

      ie> binary_command = <<0x00, 0x20, 0x1, 0x01, 0x00, 0x00, 0x00>>
      ie> %{module: cap} = AutoApi.Command.meta_data(binary_command)
      ie> base_state = cap.state.base
      %AutoApi.DoorLocksState{}
      ie> AutoApi.Command.execute(base_state, cap.command, binary_command)
      {:state_changed, %AutoApi.DoorLocksState{}}
      ie> AutoApi.Command.to_bin(:door_locks, :get_lock_state, [])
      <<0x0, 0x20, 0x0>>
      ie> AutoApi.Command.to_bin(:door_locks, :lock_unlock_doors, [:lock])
      <<0x0, 0x20, 0x02, 0x01>>


  """
  @spec meta_data(binary) :: map()
  def meta_data(<<id::binary-size(2), type, _data::binary>>) do
    with capability_module when not is_nil(capability_module) <- Capability.get_by_id(id),
         capability_name <- apply(capability_module, :name, []),
         command_name <- apply(capability_module, :command_name, [type]) do
      %{message_id: capability_name, message_type: command_name, module: capability_module}
    else
      nil ->
        %{}
    end
  end

  @spec execute(map, atom, binary) :: {:state | :state_changed, map}
  def execute(struct, command, binary_command) do
    <<_::binary-size(2), sub_command::binary>> = binary_command
    command.execute(struct, sub_command)
  end

  @spec to_bin(capability_name, atom, list(any())) :: binary
  def to_bin(capability_name, action) do
    to_bin(capability_name, action, [])
  end

  def to_bin(capability_name, action, args) do
    if capability = Capability.get_by_name(capability_name) do
      command_bin = capability.command.to_bin(action, args)
      <<capability.identifier::binary, command_bin::binary>>
    else
      <<>>
    end
  end
end
