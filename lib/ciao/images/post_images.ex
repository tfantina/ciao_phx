defmodule Ciao.Images.PostImages do
  @moduledoc """
  Uses ImageCreators module to upload post images and create variantsim
  """

  alias Ecto.{Multi, UUID}
  alias Ciao.Images
  alias Ciao.Images.{ImageRecord, ImageVariant}
  alias Ciao.Posts.Post
  alias Ciao.Repo
  alias Image

  import Ciao.EctoSupport
  @variants ["1000x1000", "200x200"]
  use Ciao.Images.ImageCreators, domain: "post", otp_app: :ciao, variants: @variants
end
