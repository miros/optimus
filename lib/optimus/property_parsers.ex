defmodule Optimus.PropertyParsers do
  def build_parser(_name, :integer) do
    {:ok, &integer_parser/1}
  end

  def build_parser(_name, :float) do
    {:ok, &float_parser/1}
  end

  def build_parser(_name, :string) do
    {:ok, &string_parser/1}
  end

  def build_parser(_name, nil) do
    {:ok, &string_parser/1}
  end

  def build_parser(_name, fun) when is_function(fun, 1), do: {:ok, fun}
  def build_parser(name, _), do: {:error, "value of #{inspect name} property is expected to be a function of arity 1 or one of the following: :integer, :float, :string or nil"}

  defp integer_parser(value) when is_binary(value) do
    case Integer.parse(value) do
      {n, ""} -> {:ok, n}
      _ -> {:error, "should be integer"}
    end
  end

  defp float_parser(value) when is_binary(value) do
    try do
      case Float.parse(value) do
        {v, ""} -> {:ok, v}
        _ -> {:error, "should be float"}
      end
    rescue
      ArgumentError -> {:error, "should be valid float"}
    end
  end

  defp string_parser(value) when is_binary(value), do: {:ok, value}

  def build_string_strict(_name, value) when is_binary(value), do: {:ok, value}
  def build_string_strict(name, _), do: {:error, "value of #{inspect name} property is expected to be String"}

  def build_string(name, value, default \\ "")
  def build_string(_name, nil, default), do: {:ok, default}
  def build_string(_name, value, _default) when is_binary(value), do: {:ok, value}
  def build_string(name, _value, _default), do: {:error, "value of #{inspect name} property is expected to be String or nil"}

  def build_bool(_name, nil, default), do: {:ok, default}
  def build_bool(_name, value, _default) when is_boolean(value), do: {:ok, value}
  def build_bool(name, _value, _default), do: {:error, "value of #{inspect name} property is expected to be Boolean or nil"}

  def build_short(_name, nil), do: {:ok, nil}
  def build_short(name, value) when is_binary(value) do
    trimmed_value = String.trim_leading(value, "-")
    if trimmed_value =~ ~r{\A[A-Za-z]\z} do
      {:ok, "-" <> trimmed_value}
    else
      {:error, "value of #{inspect name} property is expected to be \"-X\" or \"X\" where X is a single letter character"}
    end
  end
  def build_short(name, _), do: {:error, "value of #{inspect name} property is expected to be String or nil"}

  def build_long(_name, nil), do: {:ok, nil}
  def build_long(name, value) when is_binary(value)  do
    trimmed_value = String.trim_leading(value, "-")
    if trimmed_value =~ ~r{\A[^\s]+\z} do
      {:ok, "--" <> trimmed_value}
    else
      {:error, "value of #{inspect name} property is expected to be --XX...X or XX...X where XX...X is a sequence of characters whithout spaces"}
    end
  end
  def build_long(name, _), do: {:error, "value of #{inspect name} property is expected to be String or nil"}

end