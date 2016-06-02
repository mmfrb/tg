defmodule Client.Proxy do

  def generate_function({{host, port}, {functionName, args_checker}}) do
    fn args ->
      if length(args) != length(args_checker) do
        {:error, :invalid_number_of_arguments}
      else
        if type_check(args, args_checker) do
          {:ok, Client.Requestor.invoke({host, port}, functionName, args)}
        else
          {:error, :invalid_argument_types}
        end
      end
    end
  end

  defp type_check([], []), do: true
  defp type_check([], [_hd | _]), do: false
  defp type_check([_hd | _], []), do: false
  defp type_check([arg | tail_args], [arg_checker | tail_args_checker]) do
    arg_checker.(arg) && type_check(tail_args, tail_args_checker)
  end
end