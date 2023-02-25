defmodule GenReport.Utils do
  def merge_map_with_sum(map_to_be_merged, map_acc) do
    Map.merge(map_to_be_merged, map_acc, fn _key, value1, value2 -> value1 + value2 end)
  end

  def merge_deep_map_with_sum(map_to_be_merged, map_acc) do
    Map.merge(map_to_be_merged, map_acc, fn _key, map1, map2 ->
      merge_map_with_sum(map1, map2)
    end)
  end

  def merge_deep_map_with_sum(map_to_be_merged, deep_key, map_acc) do
    case map_acc[deep_key] do
      nil ->
        Map.put(map_acc, deep_key, map_to_be_merged)

      _ ->
        Map.replace!(map_acc, deep_key, merge_map_with_sum(map_to_be_merged, map_acc[deep_key]))
    end
  end

  def build_report_body(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
