defmodule Ersventaja.Policies.OCR.PatternMatchersTest do
  use ExUnit.Case, async: true

  alias Ersventaja.Policies.OCR.PatternMatchers

  describe "extract_info/1" do
    test "extracts info using PortoSeguro matcher" do
      text = """
      APÓLICE DE SEGURO
      Porto Seguro

      Nome: Flavio Takao Inouye

      Vigência:
      Início: 01/12/2024
      Fim: 01/12/2025

      Outras informações...
      """

      assert {:ok, info} = PatternMatchers.extract_info(text)
      assert info.start_date == ~D[2024-12-01]
      assert info.end_date == ~D[2025-12-01]
      assert info.customer_name == "Flavio Takao Inouye"
    end

    test "extracts info using Mapfre matcher" do
      text = """
      SEGURO
      MAPFRE

      Segurado: VIVIANE ANTUNES DE OLIVEIRA RESTANHO

      Período de vigência:
      De 11/12/2024 até 11/12/2025

      Informações adicionais...
      """

      assert {:ok, info} = PatternMatchers.extract_info(text)
      assert info.start_date == ~D[2024-12-11]
      assert info.end_date == ~D[2025-12-11]
      assert String.contains?(info.customer_name, "VIVIANE")
      assert String.contains?(info.customer_name, "RESTANHO")
    end

    test "extracts info using HDI matcher" do
      text = """
      APÓLICE DE SEGURO
      HDI Seguros

      Cliente: ANDRE MENDES BRUNHARO

      Data de início: 07/12/2024
      Data de término: 07/12/2025

      Mais informações...
      """

      assert {:ok, info} = PatternMatchers.extract_info(text)
      assert info.start_date == ~D[2024-12-07]
      assert info.end_date == ~D[2025-12-07]
      assert String.contains?(info.customer_name, "ANDRE")
      assert String.contains?(info.customer_name, "BRUNHARO")
    end

    test "returns error when no matcher can extract info" do
      text = "Random text without any policy information"

      assert {:error, _reason} = PatternMatchers.extract_info(text)
    end

    test "returns error for invalid input" do
      assert {:error, "Invalid text input"} = PatternMatchers.extract_info(123)
      assert {:error, "Invalid text input"} = PatternMatchers.extract_info(nil)
    end
  end
end
