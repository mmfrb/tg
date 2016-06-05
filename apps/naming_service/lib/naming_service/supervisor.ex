defmodule NamingService.Supervisor do
  use Supervisor

  def start_link(port) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup, port)
    result
  end

  def start_workers(sup, port) do
    {:ok, stash} =
      Supervisor.start_child(sup, worker(NamingService.Stash, []))
    Supervisor.start_child(sup, supervisor(NamingService.SubSupervisor, [stash]))
    {:ok, invoker_sup} = Supervisor.start_child(sup, supervisor(Task.Supervisor, []))
    Supervisor.start_child(sup, worker(Task, [InvocationLayer.Invoker, :invoke, [port, invoker_sup]]))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end