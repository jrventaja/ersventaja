defmodule Ersventaja.Policies.OCR.PatternMatchers.HDITest do
  use ExUnit.Case, async: true

  alias Ersventaja.Policies.OCR.PatternMatchers.HDI

  describe "extract/1" do
    test "extracts policy info from valid text" do
      text = """
      APÓLICE DE SEGURO
      HDI Seguros

      Dados do Cliente:
      Nome: ANDRE MENDES BRUNHARO
      CPF: 111.222.333-44

      Período de Vigência:
      Data de Início: 07/12/2024
      Data de Término: 07/12/2025
      """

      assert {:ok, info} = HDI.extract(text)
      assert info.start_date == ~D[2024-12-07]
      assert info.end_date == ~D[2025-12-07]
      assert String.contains?(info.customer_name, "ANDRE")
      assert String.contains?(info.customer_name, "BRUNHARO")
    end

    test "extracts info with name in different formats" do
      text = """
      HDI Seguros
      Cliente: ANDRE MENDES BRUNHARO
      De 07/12/2024 a 07/12/2025
      """

      assert {:ok, info} = HDI.extract(text)
      assert info.start_date == ~D[2024-12-07]
      assert info.end_date == ~D[2025-12-07]
      assert String.length(info.customer_name) > 5
    end

    test "handles multiple dates and selects earliest and latest" do
      text = """
      HDI Seguros
      Nome: ANDRE MENDES BRUNHARO
      Emissão: 05/12/2024
      Início: 07/12/2024
      Fim: 07/12/2025
      """

      assert {:ok, info} = HDI.extract(text)
      # When labeled dates (Início/Fim) are present, use those instead of earliest/latest
      assert info.start_date == ~D[2024-12-07]
      assert info.end_date == ~D[2025-12-07]
    end

    test "returns error when dates are missing" do
      text = """
      HDI Seguros
      Nome: ANDRE MENDES BRUNHARO
      Sem datas
      """

      assert {:error, _reason} = HDI.extract(text)
    end

    test "returns error when customer name is missing" do
      text = """
      HDI Seguros
      Início: 07/12/2024
      Fim: 07/12/2025
      """

      assert {:error, _reason} = HDI.extract(text)
    end
  end
end
