# AutoAPI
# The MIT License
#
# Copyright (c) 2018- High-Mobility GmbH (https://high-mobility.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
defmodule AutoApi.CrashState do
  @moduledoc """
  Crash state
  """

  alias AutoApi.{CommonData, State}

  use AutoApi.State, spec_file: "crash.json"

  @type crash_type :: :pedestrian | :non_pedestrian
  @type tipped_state :: :tipped_over | :not_tipped
  @type incident :: %{
          location: :front | :lateral | :rear,
          severity: :very_high | :high | :medium | :low | :unknown,
          repairs: :unknown | :needed | :not_needed
        }
  @type impact_zone ::
          :pedestrian_protection
          | :rollover
          | :rear_passenger_side
          | :rear_driver_side
          | :side_passenger_side
          | :side_driver_side
          | :front_passenger_side
          | :front_driver_side
  @type crash_status :: :normal | :restraints_engaged | :airbag_triggered

  @type t :: %__MODULE__{
          incidents: State.multiple_property(incident),
          type: State.property(crash_type),
          tipped_state: State.property(tipped_state),
          automatic_ecall: State.property(CommonData.enabled_state()),
          severity: State.property(integer()),
          impact_zone: State.multiple_property(impact_zone),
          status: State.property(crash_status)
        }

  @doc """
  Build state based on binary value

  iex> bin = <<2, 0, 4, 1, 0, 1, 0>>
  iex> AutoApi.CrashState.from_bin(bin)
  %AutoApi.CrashState{type: %AutoApi.Property{data: :pedestrian}}
  """
  @spec from_bin(binary) :: __MODULE__.t()
  def from_bin(bin) do
    parse_bin_properties(bin, %__MODULE__{})
  end

  @doc """
  Parse state to bin

    iex> state = %AutoApi.CrashState{type: %AutoApi.Property{data: :pedestrian}}
    iex> AutoApi.CrashState.to_bin(state)
    <<2, 0, 4, 1, 0, 1, 0>>
  """
  @spec to_bin(__MODULE__.t()) :: binary
  def to_bin(%__MODULE__{} = state) do
    parse_state_properties(state)
  end
end
