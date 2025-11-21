defmodule Ersventaja.Policies.OCR.PatternMatchers.PortoSeguro do
  @moduledoc """
  Pattern matcher for Porto Seguro insurance policies.

  Expected format:
  - start_date: 01/12/2024
  - end_date: 01/12/2025
  - customer_name: Flavio Takao Inouye
  """

  @behaviour Ersventaja.Policies.OCR.PatternMatchers.Behaviour

  @date_pattern ~r/\b(\d{2}\/\d{2}\/\d{4})\b/
  @name_patterns [
    # Look for patterns like "Nome:", "Segurado:", "Cliente:", followed by name (more specific)
    ~r/(?:Nome|Segurado|Cliente|Tomador)[\s:]+([A-ZÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÇ][A-ZÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÇa-záéíóúàèìòùâêîôûãõç\s]{3,}?)(?:\n|CPF|Vigência|Data|Período|$)/i,
    # Look for all caps names with at least 3 words (common in insurance documents)
    ~r/^([A-ZÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÇ]{2,}(?:\s+[A-ZÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÇ]{2,}){2,})(?:\s|$|CPF|Vigência|Data)/m
  ]

  def extract(text) do
    with {:ok, dates} <- extract_dates(text),
         {:ok, customer_name} <- extract_customer_name(text) do
      {:ok, %{start_date: dates.start_date, end_date: dates.end_date, customer_name: customer_name}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_dates(text) do
    # Try to find dates with specific labels first (Início, Fim, etc.)
    start_date_pattern = ~r/(?:Início|Inicio|Data de Início|Data de Inicio|Vigência de|Vigencia de)[\s:]+(\d{2}\/\d{2}\/\d{4})/i
    end_date_pattern = ~r/(?:Fim|Término|Termino|Data de Término|Data de Termino|Vigência até|Vigencia até)[\s:]+(\d{2}\/\d{2}\/\d{4})/i

    start_date_str = Regex.run(start_date_pattern, text) |> extract_date_match()
    end_date_str = Regex.run(end_date_pattern, text) |> extract_date_match()

    cond do
      start_date_str != nil and end_date_str != nil ->
        # Found labeled dates
        with {:ok, start_date} <- parse_date(start_date_str),
             {:ok, end_date} <- parse_date(end_date_str) do
          {:ok, %{start_date: start_date, end_date: end_date}}
        else
          _ -> fallback_date_extraction(text)
        end

      true ->
        # Fallback to finding all dates and using earliest/latest
        fallback_date_extraction(text)
    end
  end

  defp extract_date_match(nil), do: nil
  defp extract_date_match([_, date | _]), do: date
  defp extract_date_match(_), do: nil

  defp fallback_date_extraction(text) do
    # Find all dates in the text
    all_dates =
      Regex.scan(@date_pattern, text)
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

  defp extract_customer_name(text) do
    # Try multiple patterns
    name =
      Enum.reduce_while(@name_patterns, nil, fn pattern, _acc ->
        case Regex.run(pattern, text) do
          [_, captured_name | _] ->
            cleaned_name = String.trim(captured_name)
            # Filter out common document headers and ensure it looks like a name
            is_valid_name = String.length(cleaned_name) > 5 and
                            not String.contains?(cleaned_name, "APÓLICE") and
                            not String.contains?(cleaned_name, "SEGURO") and
                            not String.contains?(cleaned_name, "SEGURADORA")

            if is_valid_name do
              {:halt, cleaned_name}
            else
              {:cont, nil}
            end

          _ ->
            {:cont, nil}
        end
      end)

    case name do
      nil -> {:error, "Could not extract customer name"}
      name -> {:ok, name}
    end
  end

  defp parse_date(date_str) do
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
end
