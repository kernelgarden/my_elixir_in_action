defmodule FilterTest do

  def extract_user(user) do
    case Enum.filter(["login", "email", "password"], &(not Map.has_key?(user, &1))) do
      [] -> {:ok}
      missing_fields -> {:error, {:missing_fileds, missing_fields}}
    end
  end
end
