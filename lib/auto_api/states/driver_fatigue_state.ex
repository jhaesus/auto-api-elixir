defmodule AutoApi.DriverFatigueState do
  @moduledoc """
  Capabilities state

  This is a minimal implementation that has low-level capability and
  property binary IDs in the struct as well. A future implementation
  will translate those into modules and property names.
  """

  alias AutoApi.PropertyComponent

  defstruct detected_fatigue_level: nil,
            timestamp: nil

  use AutoApi.State, spec_file: "specs/driver_fatigue.json"

  @type fatigue_level :: %PropertyComponent{
          data: :light | :pause_recommended | :action_needed | :car_ready_to_take_over
        }

  @type t :: %__MODULE__{
          detected_fatigue_level: fatigue_level | nil,
          timestamp: DateTime.t() | nil
        }

  @doc """
  Build state based on binary value

  ## Examples

      iex> bin = <<1, 0, 4, 1, 0, 1, 1>>
      iex> AutoApi.DriverFatigueState.from_bin(bin)
      %AutoApi.DriverFatigueState{detected_fatigue_level: %AutoApi.PropertyComponent{data: :pause_recommended}}

  """
  @spec from_bin(binary) :: __MODULE__.t()
  def from_bin(binary) do
    parse_bin_properties(binary, %__MODULE__{})
  end

  @doc """
  Parse state to bin

  ## Examples

      iex> state = %AutoApi.DriverFatigueState{detected_fatigue_level: %AutoApi.PropertyComponent{data: :pause_recommended}}
      iex> AutoApi.DriverFatigueState.to_bin(state)
      <<1, 0, 4, 1, 0, 1, 1>>

  """
  @spec to_bin(__MODULE__.t()) :: binary
  def to_bin(%__MODULE__{} = state) do
    parse_state_properties(state)
  end
end