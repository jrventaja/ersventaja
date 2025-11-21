defmodule Ersventaja.Policies.OCR.PatternMatchers.Behaviour do
  @moduledoc """
  Behaviour for pattern matchers.

  Each pattern matcher must implement the `extract/1` function that takes OCR text
  and returns policy information.
  """

  @type extraction_result :: {:ok, %{start_date: Date.t(), end_date: Date.t(), customer_name: String.t()}}
                           | {:error, String.t()}

  @doc """
  Extracts policy information from OCR text.

  Returns `{:ok, info}` on success or `{:error, reason}` on failure.
  """
  @callback extract(String.t()) :: extraction_result
end
