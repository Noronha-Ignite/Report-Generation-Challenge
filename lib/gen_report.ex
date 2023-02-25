defmodule GenReport do
  alias GenReport.Parser
  alias GenReport.Utils

  @initial_report_body %{
    "all_hours" => %{},
    "hours_per_month" => %{},
    "hours_per_year" => %{}
  }

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(filename) do
    filename
    |> Parser.fetch_file()
    |> Enum.reduce(@initial_report_body, &include_line_in_report/2)
  end

  def build_by_many(filename_list) do
    filename_list
    |> Task.async_stream(&build/1)
    |> Enum.reduce(@initial_report_body, fn {:ok, content}, report_acc ->
      merge_report_list(content, report_acc)
    end)
  end

  defp merge_report_list(report_to_be_merged, report_acc) do
    all_hours_acc = report_acc["all_hours"]
    hours_per_month_acc = report_acc["hours_per_month"]
    hours_per_year_acc = report_acc["hours_per_year"]

    all_hours_to_be_merged = report_to_be_merged["all_hours"]
    hours_per_month_to_be_merged = report_to_be_merged["hours_per_month"]
    hours_per_year_to_be_merged = report_to_be_merged["hours_per_year"]

    new_all_hours = Utils.merge_map_with_sum(all_hours_to_be_merged, all_hours_acc)

    new_hours_per_month =
      Utils.merge_deep_map_with_sum(hours_per_month_to_be_merged, hours_per_month_acc)

    new_hours_per_year =
      Utils.merge_deep_map_with_sum(hours_per_year_to_be_merged, hours_per_year_acc)

    Utils.build_report_body(new_all_hours, new_hours_per_month, new_hours_per_year)
  end

  defp include_line_in_report([name, hours, _day, month, year], report_acc) do
    all_hours_acc = report_acc["all_hours"]
    hours_per_month_acc = report_acc["hours_per_month"]
    hours_per_year_acc = report_acc["hours_per_year"]

    new_all_hours = Utils.merge_map_with_sum(%{name => hours}, all_hours_acc)

    new_hours_per_month =
      Utils.merge_deep_map_with_sum(
        %{month => hours},
        name,
        hours_per_month_acc
      )

    new_hours_per_year = Utils.merge_deep_map_with_sum(%{year => hours}, name, hours_per_year_acc)

    Utils.build_report_body(new_all_hours, new_hours_per_month, new_hours_per_year)
  end
end
