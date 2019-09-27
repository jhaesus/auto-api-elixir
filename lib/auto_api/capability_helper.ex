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
defmodule AutoApi.CapabilityHelper do
  @moduledoc false

  require Logger

  def extract_state_properties(specs) do
    properties = extract_property_data(specs)

    case Map.get(specs, "state") do
      nil ->
        []

      "all" ->
        Map.values(properties)

      prop_ids when is_list(prop_ids) ->
        Enum.map(prop_ids, &Map.get(properties, &1))
    end
  end

  def extract_setters_data(specs) do
    properties = extract_property_data(specs)

    specs
    |> Map.get("setters", [])
    |> Enum.map(fn spec ->
      {
        String.to_atom(spec["name"]),
        {
          parse_properties(spec["mandatory"], properties),
          parse_properties(spec["optional"], properties),
          parse_constants(spec["constants"], properties)
        }
      }
    end)
  end

  defp extract_property_data(%{"properties" => properties}) do
    properties
    |> Enum.map(fn %{"id" => id, "name" => name} -> {id, String.to_atom(name)} end)
    |> Enum.into(%{})
  end

  defp parse_properties(nil, _), do: []

  defp parse_properties(property_ids, properties) do
    Enum.map(property_ids, &Map.get(properties, &1))
  end

  defp parse_constants(nil, _), do: []

  defp parse_constants(constants, properties) do
    Enum.map(constants, fn %{"property_id" => id, "value" => value} ->
      {
        Map.get(properties, id),
        :binary.list_to_bin(value)
      }
    end)
  end

  def inject_constants(data, constants, properties) do
    constants_data =
      constants
      |> Enum.map(fn {name, value} ->
        id = Keyword.get(properties, name)
        value_size = byte_size(value)

        <<id::8, value_size + 3::integer-16, 0x01, value_size::integer-16, value::binary>>
      end)
      |> :binary.list_to_bin()

    data <> constants_data
  end

  def reject_extra_properties(properties, allowed_properties) do
    Enum.reject(properties, fn {name, _} ->
      unless name in allowed_properties do
        Logger.warn(
          "Ignoring #{name} as it's not in the list of allowed properties for the setter: #{
            inspect allowed_properties
          }"
        )
      end
    end)
  end

  def raise_for_missing_properties(properties, mandatory_properties) do
    property_names = Enum.map(properties, &elem(&1, 0))
    missing_properties = mandatory_properties -- property_names

    case missing_properties do
      [] ->
        properties

      _ ->
        raise ArgumentError,
          message: "Missing properties for setter: #{inspect missing_properties}"
    end
  end

  def split_binary_properties(<<id, size::integer-16, data::binary-size(size), rest::binary>>) do
    [{id, data} | split_binary_properties(rest)]
  end

  def split_binary_properties(<<>>), do: []

  def get_state_properties(%state_module{} = state, properties) do
    stripped_state = Map.take(state, properties)

    struct(state_module, stripped_state)
  end

  def set_state_properties(state, properties) do
    # Multiple properties need to be replaced not appended
    state
    |> trim_multiple_properties(Keyword.keys(properties))
    |> update_properties(properties)
  end

  defp trim_multiple_properties(%state_module{} = state, properties) do
    properties
    |> Enum.filter(&state_module.capability().multiple?/1)
    |> Enum.reduce(state, &Map.put(&2, &1, []))
  end

  defp update_properties(state, properties) do
    Enum.reduce(properties, state, &update_property/2)
  end

  defp update_property({name, value}, %state_module{} = state) do
    Map.update!(state, name, fn existing_value ->
      if state_module.capability().multiple?(name) do
        existing_value ++ [value]
      else
        value
      end
    end)
  end
end
