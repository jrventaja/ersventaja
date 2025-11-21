defmodule Ersventaja.Policies.OCR.PatternMatchers do
  @moduledoc """
  Extensible pattern matching system for extracting policy information from OCR text.

  This module provides a registry of pattern matchers for different insurers.
  Each matcher is responsible for extracting start_date, end_date, and customer_name
  from OCR text based on the insurer's document structure.

  ## Adding a New Pattern Matcher

  To add support for a new insurer:

  1. Create a new module in `Ersventaja.Policies.OCR.PatternMatchers` namespace
  2. Implement the `Ersventaja.Policies.OCR.PatternMatchers.Behaviour`
  3. Add the module to the `get_all_matchers/0` function below
  4. Write unit tests for the new matcher

  ### Example:

      defmodule Ersventaja.Policies.OCR.PatternMatchers.NewInsurer do
        @behaviour Ersventaja.Policies.OCR.PatternMatchers.Behaviour

        @date_pattern ~r/\b(\d{2}\/\d{2}\/\d{4})\b/
        @name_patterns [
          ~r/(?:Nome|Segurado)[\s:]+([A-ZÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÇ\s]+)/i
        ]

        def extract(text) do
          with {:ok, dates} <- extract_dates(text),
               {:ok, customer_name} <- extract_customer_name(text) do
            {:ok, %{start_date: dates.start_date, end_date: dates.end_date, customer_name: customer_name}}
          else
            {:error, reason} -> {:error, reason}
          end
        end

        # Implement date and name extraction logic...
      end
  """

  @type extraction_result :: {:ok, %{start_date: Date.t(), end_date: Date.t(), customer_name: String.t()}}
                           | {:error, String.t()}

  @doc """
  Extracts policy information from OCR text by trying all registered pattern matchers.

  Returns the first successful extraction or an error if no matcher succeeds.
  """
  def extract_info(text) when is_binary(text) do
    matchers = get_all_matchers()

    Enum.reduce_while(matchers, {:error, "No pattern matcher could extract information"}, fn matcher, _acc ->
      case matcher.extract(text) do
        {:ok, info} -> {:halt, {:ok, info}}
        {:error, _reason} -> {:cont, {:error, "No pattern matcher could extract information"}}
      end
    end)
  end

  def extract_info(_), do: {:error, "Invalid text input"}

  # Registry of pattern matchers
  # Add new matchers here as they are created
  defp get_all_matchers do
    [
      Ersventaja.Policies.OCR.PatternMatchers.PortoSeguro,
      Ersventaja.Policies.OCR.PatternMatchers.Mapfre,
      Ersventaja.Policies.OCR.PatternMatchers.HDI
    ]
  end
end
