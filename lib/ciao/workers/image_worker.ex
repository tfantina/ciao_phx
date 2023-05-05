defmodule Ciao.Workers.ImageWorker do
  @moduledoc """
  Worker for creating image variants.  When a user uploads an image we generally want to create a smaller version 
  or versions.  For example a user may upload a 4000x6000 image, but we want to make it a profile photo: 200x200.  
  Specific dimensions are handled when implmenting the `ImageCreators` behaviours eg:

  ```
  @variants ["200x200"]
  use Ciao.Images.ImageCreators, domain: "place", otp_app: :ciao, variants: @variants
  ```

  Anything passed into `:variants` will create a resize job for each for that size.
  When an image is created a `ImageVariant` is created - if an image has no `ImageVariants` 
  it's a good idea to call `new_resize_images/1` for that particular image.
  """
  alias Ciao.Images
  alias Ciao.Images.{ImageRecord, PlaceImages, PostImages}
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
  def new_resize_images(%{domain: "post", id: id}),
    do: new(%{"task" => "resize/post_pics", "id" => id})

  def new_resize_images(%{domain: "place", id: id}),
    do: new(%{"task" => "resize/place_pics", "id" => id})

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
