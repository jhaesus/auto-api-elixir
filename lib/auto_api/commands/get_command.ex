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
defmodule AutoApi.GetCommand do
  @moduledoc """
  Abstraction for a `get` command in AutoApi (id `0x00`).

  The `struct` contains two fields:

  * `capability` specifies the capability of the command as a Capability module
  * `properties` specifies which properties are requested. An empty list indicates all properties
  """

  @behaviour AutoApi.Command

  @version AutoApi.version()
  @identifier 0x00

  @type properties :: list(AutoApi.Capability.property())

  @type t :: %__MODULE__{
          capability: AutoApi.Capability.t(),
          properties: properties,
          version: AutoApi.version()
        }

  @enforce_keys [:capability, :properties]
  defstruct [:capability, :properties, version: @version]

  @doc """
  Returns the identifier of the command.

  # Example

  iex> #{__MODULE__}.identifier()
  0x00
  """
  @impl true
  @spec identifier() :: byte()
  def identifier(), do: @identifier

  @doc """
  Creates a new GetCommand structure with the given `capability` and `properties`.

  # Example

      iex> capability = AutoApi.ClimateCapability
      iex> properties = [:hvac_state, :defogging_state]
      iex> #{__MODULE__}.new(capability, properties)
      %#{__MODULE__}{capability: AutoApi.ClimateCapability, properties: [:hvac_state, :defogging_state]}
  """
  @spec new(AutoApi.Capability.t(), properties()) :: t()
  def new(capability, properties) do
    %__MODULE__{capability: capability, properties: properties}
  end

  @doc """
  Transforms a GetCommand struct into a binary format.

  If the command is somehow invalid, it returns an error.

  # Examples

  iex> # Request the door locks state
  iex> command = %#{__MODULE__}{capability: AutoApi.DoorsCapability, properties: [:locks_state]}
  iex> #{__MODULE__}.to_bin(command)
  <<12, 0, 32, 0, 6>>

  iex> # Request all properties for race state
  iex> command = %#{__MODULE__}{capability: AutoApi.RaceCapability, properties: []}
  iex> #{__MODULE__}.to_bin(command)
  <<12, 0, 87, 0>>
  """
  @impl true
  @spec to_bin(t()) :: binary()
  def to_bin(%__MODULE__{capability: capability, properties: properties}) do
    preamble = <<@version, capability.identifier()::binary, @identifier>>

    Enum.reduce(properties, preamble, &(&2 <> <<capability.property_id(&1)::8>>))
  end

  @doc """
  Parses a command binary and returns a GetCommand struct

  ## Examples

      iex> #{__MODULE__}.from_bin(<<0x0C, 0x00, 0x33, 0x00, 0x01, 0x04>>)
      %#{__MODULE__}{capability: AutoApi.DiagnosticsCapability, properties: [:mileage, :engine_rpm], version: 12}
  """
  @impl true
  @spec from_bin(binary) :: t()
  def from_bin(<<@version, capability_id::binary-size(2), @identifier, properties::binary>>) do
    capability = AutoApi.Capability.get_by_id(capability_id)

    property_names =
      properties
      |> :binary.bin_to_list()
      |> Enum.map(&capability.property_name/1)

    new(capability, property_names)
  end
end
