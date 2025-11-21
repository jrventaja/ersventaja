defmodule Ersventaja.Policies.OCR.PatternMatchers.PortoSeguroTest do
  use ExUnit.Case, async: true

  alias Ersventaja.Policies.OCR.PatternMatchers.PortoSeguro

  describe "extract/1" do
    test "extracts policy info from valid text" do
      text = """
      APÓLICE DE SEGURO
      Porto Seguro Seguradora S.A.

      Dados do Segurado:
      Nome: Flavio Takao Inouye
      CPF: 123.456.789-00

      Vigência da Apólice:
      Data de Início: 01/12/2024
      Data de Término: 01/12/2025

      Valor do Prêmio: R$ 1.500,00
      """

      assert {:ok, info} = PortoSeguro.extract(text)
      assert info.start_date == ~D[2024-12-01]
      assert info.end_date == ~D[2025-12-01]
      assert info.customer_name == "Flavio Takao Inouye"
    end

    test "extracts info with name in different formats" do
      text = """
      Porto Seguro
      Segurado: FLAVIO TAKAO INOUYE
      Início: 01/12/2024
      Fim: 01/12/2025
      """

      assert {:ok, info} = PortoSeguro.extract(text)
      assert info.start_date == ~D[2024-12-01]
      assert info.end_date == ~D[2025-12-01]
      assert String.length(info.customer_name) > 5
    end

    test "handles multiple dates and selects earliest and latest" do
      text = """
      Porto Seguro
      Nome: Flavio Takao Inouye
      Emissão: 15/11/2024
      Início: 01/12/2024
      Fim: 01/12/2025
      Vencimento: 01/12/2025
      """

      assert {:ok, info} = PortoSeguro.extract(text)
      # When labeled dates (Início/Fim) are present, use those instead of earliest/latest
      assert info.start_date == ~D[2024-12-01]
      assert info.end_date == ~D[2025-12-01]
    end

    test "returns error when dates are missing" do
      text = """
      Porto Seguro
      Nome: Flavio Takao Inouye
      Sem datas no documento
      """

      assert {:error, _reason} = PortoSeguro.extract(text)
    end

    test "returns error when customer name is missing" do
      text = """
      Porto Seguro
      Início: 01/12/2024
      Fim: 01/12/2025
      """

      assert {:error, _reason} = PortoSeguro.extract(text)
    end

    test "returns error when only one date is found" do
      text = """
      Porto Seguro
      Nome: Flavio Takao Inouye
      Data: 01/12/2024
      """

      assert {:error, _reason} = PortoSeguro.extract(text)
    end
  end
end
