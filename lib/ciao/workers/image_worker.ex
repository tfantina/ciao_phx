defmodule Ciao.Workers.ImageWorker do
  alias Ciao.Images.{ImageRecord, PostImages}
  alias Ciao.Images
  alias Oban.Job
  use Oban.Worker, queue: :images

  @impl Oban.Worker
  def perform(%Job{args: %{"task" => "resize/profile_pic", "id" => id}}),
    do: Images.create_variants(id, :profile_pic)

  def perform(%Job{args: %{"task" => "resize", "id" => id}}),
    do: queue_resize_jobs(id)

  def perform(%Job{args: %{"task" => "resize/post_pic", "id" => id, "size" => size}}),
    do: PostImages.create_variant(id, size)

  #
  # Initialize jobs
  #
  def new_resize_images(image), do: new(%{"task" => "resize", "id" => image.id})

  def new_resize_image(image, size),
    do: new(%{"task" => "resize/post_pic", "id" => image.id, "size" => size})

  #
  # Handlers 
  #
  defp queue_resize_jobs(id) do
    case Images.get(id) do
      %ImageRecord{domain: "post"} = image ->
        sizes = PostImages.variants()
        Enum.each(sizes, &(new_resize_image(image, &1) |> Oban.insert()))

      _ ->
        :ok
    end
  end
end
