defmodule Ciao.Images do
  @moduledoc """
  Module for creating and managing images.
  Images are used throughout the site and in varying contexts however they all
  live under the Images umbrella.  If this ever becomes unmanagable these functions
  should be extracted into behaviours and composed in seperate modules.
  """
  alias __MODULE__
  alias Ciao.Accounts.User
  alias Ecto.{Multi, UUID}
  alias Ciao.Images.{ImageRecord, ImageVariant, ProfilePics}
  alias Ciao.Repo
  alias Image, as: Img

  @multi Multi.new()

  use Ciao.Query, for: ImageRecord
end
