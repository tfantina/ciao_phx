defmodule Ciao.Workers.ImageWorker do
  alias Ciao.Images.{ImageRecord, PostImages, PlaceImages}
  alias Ciao.Images
  alias Oban.Job
  use Oban.Worker, queue: :images

  @impl Oban.Worker
  def perform(%Job{args: %{"task" => "resize/post_pics", "id" => id}}),
    do: queue_resize_jobs(id)

  def perform(%Job{args: %{"task" => "resize/place_pics", "id" => id}}),
    do: queue_resize_jobs(id)

  def perform(%Job{args: %{"task" => "resize/post_pic", "id" => id, "size" => size}}),
    do: PostImages.create_variant(id, size)

    def perform(%Job{args: %{"task" => "resize/place_pic", "id" => id, "size" => size}}),
    do: PlaceImages.create_variant(id, size)
    
  #
  # Initialize jobs
  #
  def new_resize_images(%{domain: "post", id: id} ), do: new(%{"task" => "resize/post_pics", "id" => id})

  def new_resize_images(%{domain: "place", id: id}), do: new(%{"task" => "resize/place_pics", "id" => id})

  def new_resize_image(%{domain: "post"} = image, size),
    do: new(%{"task" => "resize/post_pic", "id" => image.id, "size" => size})

  def new_resize_image(%{domain: "place"} = image, size),
    do: new(%{"task" => "resize/place_pic", "id" => image.id, "size" => size})

  #
  # Handlers
  #
  defp queue_resize_jobs(id) do
    case Images.get(id) do
      %ImageRecord{domain: "post"} = image ->
        sizes = PostImages.variants()
        Enum.each(sizes, &(new_resize_image(image, &1) |> Oban.insert()))

       %ImageRecord{domain: "place"} = image ->
        sizes = PlaceImages.variants()
        Enum.each(sizes, &(new_resize_image(image, &1) |> Oban.insert()))

      res ->
        :ok
    end
  end
end
