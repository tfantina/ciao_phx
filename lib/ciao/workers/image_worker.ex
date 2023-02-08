defmodule Ciao.Workers.ImageWorker do
  alias Ciao.Images
  alias Oban.Job
  use Oban.Worker, queue: :images

  @impl Oban.Worker
  def perform(%Job{args: %{"task" => "resize/profile_pic", "id" => id}}),
    do: Images.create_variants(id, :profile_pic)
end
