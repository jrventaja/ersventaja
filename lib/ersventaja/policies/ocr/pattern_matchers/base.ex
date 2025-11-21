defmodule Ersventaja.Policies.OCR.PatternMatchers.Base do
  @moduledoc """
  Base module providing common functionality for pattern matchers.

  This module contains shared helper functions that can be used by all
  pattern matcher implementations to reduce code duplication.
  """

  @doc """
  Parses a date string in DD/MM/YYYY format to a Date struct.

  ## Examples

      iex> parse_date("01/12/2024")
      {:ok, ~D[2024-12-01]}

      iex> parse_date("31/12/2024")
      {:ok, ~D[2024-12-31]}

      iex> parse_date("invalid")
      {:error, "Date format not DD/MM/YYYY"}
  """
  def parse_date(date_str) do
    case String.split(date_str, "/") do
      [day, month, year] ->
        try do
          day_int = String.to_integer(day)
          month_int = String.to_integer(month)
          year_int = String.to_integer(year)

          case Date.new(year_int, month_int, day_int) do
            {:ok, date} -> {:ok, date}
            {:error, _} -> {:error, "Invalid date"}
          end
        rescue
          _ -> {:error, "Invalid date format"}
        end

      _ ->
        {:error, "Date format not DD/MM/YYYY"}
    end
  end

  @doc """
  Extracts dates from text using a date pattern and returns the earliest and latest dates.

  ## Examples

      iex> extract_dates("Start: 01/12/2024 End: 01/12/2025", ~r/\b(\d{2}\/\d{2}\/\d{4})\b/)
      {:ok, %{start_date: ~D[2024-12-01], end_date: ~D[2025-12-01]}}
  """
  def extract_dates(text, date_pattern) do
    # Find all dates in the text
    all_dates =
      Regex.scan(date_pattern, text)
      |> Enum.map(fn [full_match | _] -> full_match end)
      |> Enum.uniq()

    case all_dates do
      [] ->
        {:error, "Could not find any dates in text"}

      dates when length(dates) >= 2 ->
        # Parse all dates and sort them chronologically
        parsed_dates =
          dates
          |> Enum.map(&parse_date/1)
          |> Enum.filter(fn result -> match?({:ok, _}, result) end)
          |> Enum.map(fn {:ok, date} -> date end)
          |> Enum.sort()

        case parsed_dates do
          [start_date, end_date | _] ->
            {:ok, %{start_date: start_date, end_date: end_date}}

          _ ->
            {:error, "Could not parse at least two valid dates"}
        end

      _ ->
        {:error, "Could not find two dates in text"}
    end
  end

  @doc """
  Extracts customer name from text using multiple name patterns.

  Tries each pattern in order and returns the first successful match.
  """
  def extract_customer_name(text, name_patterns) do
    name =
      Enum.reduce_while(name_patterns, nil, fn pattern, _acc ->
        case Regex.run(pattern, text) do
          [_, captured_name | _] ->
            cleaned_name = String.trim(captured_name)
            if String.length(cleaned_name) > 5, do: {:halt, cleaned_name}, else: {:cont, nil}

          _ ->
            {:cont, nil}
        end
      end)

    case name do
      nil -> {:error, "Could not extract customer name"}
      name -> {:ok, name}
    end
  end
end
