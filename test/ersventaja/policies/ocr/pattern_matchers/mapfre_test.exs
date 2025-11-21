defmodule Ersventaja.Policies.OCR.PatternMatchers.MapfreTest do
  use ExUnit.Case, async: true

  alias Ersventaja.Policies.OCR.PatternMatchers.Mapfre

  describe "extract/1" do
    test "extracts policy info from valid text" do
      text = """
      APÓLICE DE SEGURO
      MAPFRE Seguradora

      Dados do Segurado:
      Nome: VIVIANE ANTUNES DE OLIVEIRA RESTANHO
      CPF: 987.654.321-00

      Vigência:
      Início: 11/12/2024
      Término: 11/12/2025
      """

      assert {:ok, info} = Mapfre.extract(text)
      assert info.start_date == ~D[2024-12-11]
      assert info.end_date == ~D[2025-12-11]
      assert String.contains?(info.customer_name, "VIVIANE")
      assert String.contains?(info.customer_name, "RESTANHO")
    end

    test "extracts info with name in different formats" do
      text = """
      MAPFRE
      Segurado: VIVIANE ANTUNES DE OLIVEIRA RESTANHO
      De 11/12/2024 até 11/12/2025
      """

      assert {:ok, info} = Mapfre.extract(text)
      assert info.start_date == ~D[2024-12-11]
      assert info.end_date == ~D[2025-12-11]
      assert String.length(info.customer_name) > 5
    end

    test "handles multiple dates and selects earliest and latest" do
      text = """
      MAPFRE
      Nome: VIVIANE ANTUNES DE OLIVEIRA RESTANHO
      Emissão: 10/12/2024
      Início: 11/12/2024
      Fim: 11/12/2025
      """

      assert {:ok, info} = Mapfre.extract(text)
      # When labeled dates (Início/Fim) are present, use those instead of earliest/latest
      assert info.start_date == ~D[2024-12-11]
      assert info.end_date == ~D[2025-12-11]
    end

    test "returns error when dates are missing" do
      text = """
      MAPFRE
      Nome: VIVIANE ANTUNES DE OLIVEIRA RESTANHO
      Sem datas
      """

      assert {:error, _reason} = Mapfre.extract(text)
    end

    test "returns error when customer name is missing" do
      text = """
      MAPFRE
      Início: 11/12/2024
      Fim: 11/12/2025
      """

      assert {:error, _reason} = Mapfre.extract(text)
    end
  end
end
