defmodule Ciao.Images.PostImages do
  @moduledoc false

  alias Ecto.{Multi, UUID}
  alias Ciao.Images
  alias Ciao.Images.{ImageRecord, ImageVariant}
  alias Ciao.Repo
  alias Image

  import Ciao.EctoSupport
  # use Ciao.Storage, otp_app: :ciao
  use Ciao.Storage.Images, domain: "post", otp_app: :ciao
end
