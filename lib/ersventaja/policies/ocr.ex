defmodule Ersventaja.Policies.OCR do
  @moduledoc """
  Module for extracting policy information from PDF files using OCR.

  This module handles base64 encoded PDF files, extracts text using Tesseract OCR,
  and parses the text to extract policy information such as start_date, end_date,
  and customer_name using extensible pattern matchers for different insurers.
  """

  alias Ersventaja.Policies.OCR.PatternMatchers

  @doc """
  Extracts policy information from a base64 encoded PDF file.

  ## Parameters
  - `encoded_file`: Base64 encoded PDF file content

  ## Returns
  - `{:ok, %{start_date: Date.t(), end_date: Date.t(), customer_name: String.t()}}` on success
  - `{:error, reason}` on failure

  ## Examples

      iex> extract_policy_info("base64_encoded_pdf_content")
      {:ok, %{start_date: ~D[2024-12-01], end_date: ~D[2025-12-01], customer_name: "John Doe"}}
  """
  def extract_policy_info(encoded_file) when is_binary(encoded_file) do
    with {:ok, pdf_content} <- decode_base64(encoded_file),
         {:ok, temp_file} <- save_temp_file(pdf_content),
         {:ok, text} <- extract_text(temp_file),
         {:ok, info} <- parse_policy_info(text) do
      File.rm(temp_file)
      {:ok, info}
    else
      {:error, _reason} = error ->
        error
    end
  end

  def extract_policy_info(_), do: {:error, :invalid_input}

  # Private functions

  defp decode_base64(encoded) do
    case Base.decode64(encoded) do
      {:ok, decoded} -> {:ok, decoded}
      :error -> {:error, :invalid_base64}
    end
  end

  defp save_temp_file(content) do
    temp_file = System.tmp_dir!() |> Path.join("policy_#{:rand.uniform(1_000_000)}.pdf")

    case File.write(temp_file, content) do
      :ok -> {:ok, temp_file}
      {:error, reason} -> {:error, {:file_write_error, reason}}
    end
  end

  defp extract_text(file_path) do
    try do
      # Use Portuguese language for better OCR accuracy with PT-BR dates
      text = TesseractOcr.read(file_path, %{lang: 'por'})
      {:ok, text}
    rescue
      e -> {:error, {:ocr_error, Exception.message(e)}}
    catch
      :exit, reason -> {:error, {:ocr_exit, reason}}
    end
  end

  defp parse_policy_info(text) do
    case PatternMatchers.extract_info(text) do
      {:ok, info} -> {:ok, info}
      {:error, reason} -> {:error, {:parsing_error, reason}}
    end
  end
end
