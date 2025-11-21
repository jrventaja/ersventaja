defmodule Ersventaja.PolicyOCRFixtures do
  @moduledoc """
  Fixtures for OCR policy tests using real PDF files.

  These fixtures contain base64-encoded PDF files from actual insurance policies.
  """

  @fixtures_dir Path.join([__DIR__, "..", "..", "fixtures", "pdfs"])

  @doc """
  Returns base64-encoded Porto Seguro PDF.
  Expected values:
  - start_date: 01/12/2024
  - end_date: 01/12/2025
  - customer_name: Flavio Takao Inouye
  """
  def porto_seguro_pdf_base64 do
    read_pdf_base64("porto_seguro.pdf")
  end

  @doc """
  Returns base64-encoded Mapfre PDF.
  Expected values:
  - start_date: 11/12/2024
  - end_date: 11/12/2025
  - customer_name: VIVIANE ANTUNES DE OLIVEIRA RESTANHO
  """
  def mapfre_pdf_base64 do
    read_pdf_base64("mapfre.pdf")
  end

  @doc """
  Returns base64-encoded HDI PDF.
  Expected values:
  - start_date: 07/12/2024
  - end_date: 07/12/2025
  - customer_name: ANDRE MENDES BRUNHARO
  """
  def hdi_pdf_base64 do
    read_pdf_base64("hdi.pdf")
  end

  @doc """
  Returns base64-encoded bonus PDF (may be harder to read).
  """
  def bonus_pdf_base64 do
    read_pdf_base64("bonus.pdf")
  end

  # Private helper to read PDF and encode to base64
  defp read_pdf_base64(filename) do
    pdf_path = Path.join(@fixtures_dir, filename)

    case File.read(pdf_path) do
      {:ok, content} ->
        Base.encode64(content)

      {:error, _reason} ->
        # Fallback: try to read from the original location
        original_path = "/mnt/c/Users/jrobe/Downloads/pdfs/#{filename}"
        case File.read(original_path) do
          {:ok, content} -> Base.encode64(content)
          {:error, reason} -> raise "Could not read PDF file #{filename}: #{inspect(reason)}"
        end
    end
  end
end
